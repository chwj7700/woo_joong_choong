import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/favorite_location_model.dart';
import '../../providers/favorite_locations_provider.dart';
import '../../utils/weather_icons.dart';
import 'add_favorite_screen.dart';
import 'favorite_detail_screen.dart';

/// 즐겨찾기 목록 화면
class FavoriteListScreen extends StatelessWidget {
  const FavoriteListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('즐겨찾기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddFavoriteScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<FavoriteLocationsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.locations.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildFavoriteList(context, provider);
        },
      ),
    );
  }

  /// 빈 상태 위젯 생성
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.star_border,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            '즐겨찾기한 장소가 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '자주 확인하는 장소를 즐겨찾기에 추가해보세요',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('장소 추가하기'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddFavoriteScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 즐겨찾기 목록 위젯 생성
  Widget _buildFavoriteList(
      BuildContext context, FavoriteLocationsProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.refreshWeatherInfo(),
      child: ReorderableListView.builder(
        itemCount: provider.locations.length,
        onReorder: (oldIndex, newIndex) {
          provider.reorderLocations(oldIndex, newIndex);
        },
        itemBuilder: (context, index) {
          final location = provider.locations[index];
          return _buildFavoriteItem(context, location, provider);
        },
      ),
    );
  }

  /// 즐겨찾기 항목 위젯 생성
  Widget _buildFavoriteItem(BuildContext context, FavoriteLocation location,
      FavoriteLocationsProvider provider) {
    return Dismissible(
      key: Key(location.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('즐겨찾기 삭제'),
              content: Text('\'${location.name}\'을(를) 즐겨찾기에서 삭제하시겠습니까?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('삭제'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        provider.removeLocation(location.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('\'${location.name}\'이(가) 삭제되었습니다'),
            action: SnackBarAction(
              label: '실행 취소',
              onPressed: () {
                provider.addLocation(location);
              },
            ),
          ),
        );
      },
      child: Card(
        key: Key(location.id),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: _buildWeatherIcon(location),
          title: Text(
            location.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: location.address != null
              ? Text(
                  location.address!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (location.currentTemp != null)
                Text(
                  '${location.currentTemp!.toStringAsFixed(1)}°',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FavoriteDetailScreen(location: location),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 날씨 아이콘 위젯 생성
  Widget _buildWeatherIcon(FavoriteLocation location) {
    if (location.weatherIcon == null) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.location_on,
          color: Colors.grey,
        ),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.asset(
          WeatherIcons.getIconPath(location.weatherIcon!),
          width: 32,
          height: 32,
        ),
      ),
    );
  }
} 