import 'package:uuid/uuid.dart';

/// 즐겨찾기 위치 모델
class FavoriteLocation {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime createdAt;
  final String? weatherIcon; // 현재 날씨 아이콘 (선택적)
  final double? currentTemp; // 현재 온도 (선택적)

  FavoriteLocation({
    String? id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    DateTime? createdAt,
    this.weatherIcon,
    this.currentTemp,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// JSON에서 객체 생성
  factory FavoriteLocation.fromJson(Map<String, dynamic> json) {
    return FavoriteLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      weatherIcon: json['weatherIcon'] as String?,
      currentTemp: json['currentTemp'] as double?,
    );
  }

  /// 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'weatherIcon': weatherIcon,
      'currentTemp': currentTemp,
    };
  }

  /// 업데이트된 객체 생성 (불변성 유지)
  FavoriteLocation copyWith({
    String? name,
    double? latitude,
    double? longitude,
    String? address,
    String? weatherIcon,
    double? currentTemp,
  }) {
    return FavoriteLocation(
      id: id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      createdAt: createdAt,
      weatherIcon: weatherIcon ?? this.weatherIcon,
      currentTemp: currentTemp ?? this.currentTemp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteLocation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FavoriteLocation{id: $id, name: $name, lat: $latitude, lon: $longitude}';
  }
} 