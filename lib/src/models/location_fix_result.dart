import 'package:geocoding/geocoding.dart';

/// Successful location resolution: coordinates plus optional address fields.
class LocationFixResult {
  const LocationFixResult({
    required this.latitude,
    required this.longitude,
    this.formattedAddress,
    this.city,
    this.stateName,
    this.postalCode,
    this.country,
    this.placemark,
    this.detectedAt,
  });

  final double latitude;
  final double longitude;
  final String? formattedAddress;
  final String? city;
  final String? stateName;
  final String? postalCode;
  final String? country;
  final Placemark? placemark;
  final DateTime? detectedAt;

  LocationFixResult copyWith({
    double? latitude,
    double? longitude,
    String? formattedAddress,
    String? city,
    String? stateName,
    String? postalCode,
    String? country,
    Placemark? placemark,
    DateTime? detectedAt,
  }) {
    return LocationFixResult(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      city: city ?? this.city,
      stateName: stateName ?? this.stateName,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      placemark: placemark ?? this.placemark,
      detectedAt: detectedAt ?? this.detectedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        if (formattedAddress != null) 'formattedAddress': formattedAddress,
        if (city != null) 'city': city,
        if (stateName != null) 'stateName': stateName,
        if (postalCode != null) 'postalCode': postalCode,
        if (country != null) 'country': country,
        if (detectedAt != null) 'detectedAt': detectedAt!.toIso8601String(),
      };

  factory LocationFixResult.fromJson(Map<String, dynamic> json) {
    return LocationFixResult(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      formattedAddress: json['formattedAddress'] as String?,
      city: json['city'] as String?,
      stateName: json['stateName'] as String?,
      postalCode: json['postalCode'] as String?,
      country: json['country'] as String?,
      detectedAt: json['detectedAt'] != null
          ? DateTime.tryParse(json['detectedAt'] as String)
          : null,
    );
  }
}
