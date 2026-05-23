import 'package:flutter/material.dart';

import '../config/in_app_location_config.dart';
import '../config/in_app_location_strings.dart';
import '../config/in_app_location_theme.dart';
import '../dialogs/location_settings_dialog.dart';
import '../models/location_fix_result.dart';
import '../models/location_flow_failure.dart';
import '../models/location_flow_result.dart';
import '../service/location_kit_base.dart';
import '../storage/location_storage.dart';
import 'location_flow_controller.dart';

/// One-tap "Use current location" with loading state and error snackbars.
class InAppLocationButton extends StatefulWidget {
  const InAppLocationButton({
    super.key,
    required this.onLocation,
    this.onFailure,
    this.kit,
    this.config,
    this.storage,
    this.strings = const InAppLocationStrings(),
    this.theme = const InAppLocationTheme(),
    this.label,
    this.icon,
    this.showErrorSnackBar = true,
    this.settingsDialogBuilder = showDefaultLocationSettingsDialog,
  });

  final void Function(LocationFixResult result) onLocation;
  final void Function(LocationFlowFailure failure)? onFailure;
  final LocationKitBase? kit;
  final InAppLocationConfig? config;
  final LocationStorage? storage;
  final InAppLocationStrings strings;
  final InAppLocationTheme theme;
  final Widget? label;
  final Widget? icon;
  final bool showErrorSnackBar;
  final SettingsDialogBuilder settingsDialogBuilder;

  @override
  State<InAppLocationButton> createState() => _InAppLocationButtonState();
}

class _InAppLocationButtonState extends State<InAppLocationButton> {
  late final LocationFlowController _controller;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _controller = LocationFlowController(
      kit: widget.kit,
      config: widget.config,
      storage: widget.storage,
      strings: widget.strings,
      settingsDialogBuilder: widget.settingsDialogBuilder,
    );
  }

  Future<void> _tap() async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await _controller.runWithGpsPrompt(
      context: context,
      persistOnSuccess: widget.storage != null,
    );
    if (!mounted) return;
    setState(() => _busy = false);

    if (result is LocationFlowSuccess) {
      widget.onLocation(result.fix);
      return;
    }
    if (result is LocationFlowError) {
      widget.onFailure?.call(result.failure);
      if (widget.showErrorSnackBar) {
        final msg = result.failure.message ?? result.failure.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultLabel = _busy
        ? widget.strings.turningOnLocationButton
        : widget.strings.useCurrentLocationButton;

    return ElevatedButton.icon(
      onPressed: _busy ? null : _tap,
      style: widget.theme.elevatedButtonStyle(theme),
      icon: _busy
          ? SizedBox(
              width: 20,
              height: 20,
              child: widget.theme.loadingIndicatorBuilder?.call(context) ??
                  const CircularProgressIndicator(strokeWidth: 2),
            )
          : widget.icon ?? const Icon(Icons.my_location),
      label: widget.label ?? Text(defaultLabel),
    );
  }
}
