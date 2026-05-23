import 'package:flutter/material.dart';

import '../config/in_app_location_strings.dart';
import '../config/in_app_location_theme.dart';
import '../models/location_fix_result.dart';
import '../models/location_flow_result.dart';
import '../service/in_app_location_kit.dart';
import '../service/location_kit_base.dart';
import '../storage/location_storage.dart';

/// Khaugalli-style interstitial: spinner + address line, then callback.
class InAppLocationLoadingScreen extends StatefulWidget {
  const InAppLocationLoadingScreen({
    super.key,
    required this.mode,
    required this.onComplete,
    this.onManualFallback,
    this.kit,
    this.storage,
    this.strings = const InAppLocationStrings(),
    this.theme = const InAppLocationTheme(),
  });

  /// `gps` fetches device location; `manual` only validates cached storage.
  final String mode;
  final void Function(LocationFixResult? result) onComplete;
  final VoidCallback? onManualFallback;
  final LocationKitBase? kit;
  final LocationStorage? storage;
  final InAppLocationStrings strings;
  final InAppLocationTheme theme;

  @override
  State<InAppLocationLoadingScreen> createState() =>
      _InAppLocationLoadingScreenState();
}

class _InAppLocationLoadingScreenState
    extends State<InAppLocationLoadingScreen> {
  String _line = '';
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _line = widget.strings.fetchingLocation;
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    if (_finished) return;
    final kit = widget.kit ?? InAppLocationKit();
    final mode = widget.mode;

    if (mode == 'gps') {
      final result = await kit.fetchCurrentLocation();
      if (!mounted) return;
      if (result is LocationFlowSuccess) {
        if (widget.storage != null) {
          await widget.storage!.save(result.fix);
        }
        setState(() => _line = result.fix.formattedAddress ?? _line);
        _finished = true;
        widget.onComplete(result.fix);
        return;
      }
      _finished = true;
      widget.onManualFallback?.call();
      widget.onComplete(null);
      return;
    }

    if (mode == 'manual' && widget.storage != null) {
      final cached = await widget.storage!.load();
      if (!mounted) return;
      if (cached != null &&
          (cached.formattedAddress?.isNotEmpty ?? false)) {
        setState(
          () => _line = cached.formattedAddress ?? widget.strings.fetchingLocation,
        );
        _finished = true;
        widget.onComplete(cached);
        return;
      }
      _finished = true;
      widget.onManualFallback?.call();
      widget.onComplete(null);
      return;
    }

    _finished = true;
    widget.onComplete(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kitTheme = widget.theme.mergeWith(theme);
    final subtitle = widget.mode == 'gps'
        ? widget.strings.findingNearYou
        : widget.strings.settingUpLocation;

    return Theme(
      data: kitTheme,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 56,
                    color: kitTheme.colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _line,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: widget.theme.titleStyle ??
                        theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: widget.theme.bodyStyle ??
                        theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 36),
                  widget.theme.loadingIndicatorBuilder?.call(context) ??
                      CircularProgressIndicator(
                        color: kitTheme.colorScheme.primary,
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
