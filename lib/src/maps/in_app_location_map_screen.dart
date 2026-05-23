import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../config/in_app_location_strings.dart';
import '../config/in_app_location_theme.dart';
import '../models/location_fix_result.dart';
import '../models/location_flow_result.dart';
import '../service/in_app_location_kit.dart';
import '../service/location_kit_base.dart';

/// Map pin picker (Khaugalli SetLocationScreen-style).
class InAppLocationMapScreen extends StatefulWidget {
  const InAppLocationMapScreen({
    super.key,
    required this.onConfirm,
    this.kit,
    this.initialPosition,
    this.strings = const InAppLocationStrings(),
    this.theme = const InAppLocationTheme(),
    this.appBarTitle = 'Set location',
  });

  final void Function(LocationFixResult result) onConfirm;
  final LocationKitBase? kit;
  final LatLng? initialPosition;
  final InAppLocationStrings strings;
  final InAppLocationTheme theme;
  final String appBarTitle;

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
    _position = widget.initialPosition ??
        const LatLng(18.9389, 72.8258);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
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
              final region = await c.getVisibleRegion();
              final center = LatLng(
                (region.northeast.latitude + region.southwest.latitude) / 2,
                (region.northeast.longitude + region.southwest.longitude) / 2,
              );
              _onCameraIdle(center);
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
