import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../config/in_app_location_strings.dart';
import '../config/in_app_location_theme.dart';
import '../models/location_fix_result.dart';
import '../models/location_flow_result.dart';
import '../service/in_app_location_kit.dart';
import '../service/location_kit_base.dart';
import 'maps_availability.dart';
import 'maps_unavailable_placeholder.dart';

/// Map pin picker (Khaugalli SetLocationScreen-style).
///
/// Set [mapsEnabled] to `false` (or omit [googleMapsApiKey]) when the host app
/// has not configured a native Google Maps API key — avoids a hard crash.
class InAppLocationMapScreen extends StatefulWidget {
  const InAppLocationMapScreen({
    super.key,
    required this.onConfirm,
    this.kit,
    this.initialPosition,
    this.strings = const InAppLocationStrings(),
    this.theme = const InAppLocationTheme(),
    this.appBarTitle = 'Set location',
    this.googleMapsApiKey,
    this.mapsEnabled = true,
    this.mapsSetupHint,
  });

  final void Function(LocationFixResult result) onConfirm;
  final LocationKitBase? kit;
  final LatLng? initialPosition;
  final InAppLocationStrings strings;
  final InAppLocationTheme theme;
  final String appBarTitle;

  /// If set, [mapsEnabled] is derived from [MapsAvailability.isConfigured].
  final String? googleMapsApiKey;

  /// When `false`, shows [MapsUnavailablePlaceholder] instead of [GoogleMap].
  final bool mapsEnabled;
  final String? mapsSetupHint;

  bool get _shouldShowMap {
    if (!mapsEnabled) return false;
    if (googleMapsApiKey != null) {
      return MapsAvailability.isConfigured(googleMapsApiKey!);
    }
    return mapsEnabled;
  }

  @override
  State<InAppLocationMapScreen> createState() => _InAppLocationMapScreenState();
}

class _InAppLocationMapScreenState extends State<InAppLocationMapScreen> {
  GoogleMapController? _mapController;
  late LatLng _position;
  String _addressLine = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition ?? const LatLng(18.9389, 72.8258);
    if (widget._shouldShowMap) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
    } else {
      _loading = false;
    }
  }

  Future<void> _loadInitial() async {
    final kit = widget.kit ?? InAppLocationKit();
    final result = await kit.fetchCurrentLocation();
    if (!mounted) return;
    if (result is LocationFlowSuccess) {
      _position = LatLng(result.fix.latitude, result.fix.longitude);
      _addressLine = result.fix.formattedAddress ?? '';
      _mapController?.animateCamera(CameraUpdate.newLatLng(_position));
    }
    setState(() => _loading = false);
    if (_addressLine.isEmpty) await _reverseGeocode(_position);
  }

  Future<void> _reverseGeocode(LatLng pos) async {
    try {
      final marks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (marks.isEmpty) return;
      final p = marks.first;
      setState(() {
        _addressLine =
            '${p.name}, ${p.subLocality}, ${p.locality}, ${p.postalCode}';
      });
    } catch (_) {}
  }

  void _onCameraIdle(LatLng target) {
    _position = target;
    _reverseGeocode(target);
  }

  void _confirm() {
    widget.onConfirm(
      LocationFixResult(
        latitude: _position.latitude,
        longitude: _position.longitude,
        formattedAddress: _addressLine.isEmpty ? null : _addressLine,
        detectedAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget._shouldShowMap) {
      return MapsUnavailablePlaceholder(
        strings: widget.strings,
        theme: widget.theme,
        appBarTitle: widget.appBarTitle,
        setupHint: widget.mapsSetupHint,
      );
    }

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.appBarTitle)),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _position,
              zoom: 16,
            ),
            onMapCreated: (c) => _mapController = c,
            onCameraIdle: () async {
              final c = _mapController;
              if (c == null) return;
              try {
                final region = await c.getVisibleRegion();
                final center = LatLng(
                  (region.northeast.latitude + region.southwest.latitude) / 2,
                  (region.northeast.longitude + region.southwest.longitude) / 2,
                );
                _onCameraIdle(center);
              } catch (_) {}
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          const Center(
            child: Icon(Icons.location_pin, size: 48, color: Colors.red),
          ),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_addressLine.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _addressLine,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loading ? null : _confirm,
                  style: widget.theme.elevatedButtonStyle(theme),
                  child: Text(widget.strings.mapConfirmButton),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
