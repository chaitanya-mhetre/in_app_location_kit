import 'package:flutter/material.dart';

import '../config/in_app_location_config.dart';
import '../config/in_app_location_strings.dart';
import '../config/in_app_location_theme.dart';
import '../dialogs/location_settings_dialog.dart';
import '../models/location_fix_result.dart';
import '../models/location_flow_failure.dart';
import '../models/location_flow_result.dart';
import '../service/in_app_location_kit.dart';
import '../service/location_kit_base.dart';
import '../storage/location_storage.dart';
import 'location_flow_controller.dart';

/// Full-screen onboarding (Khaugalli [LocationPermissionScreen] equivalent).
class InAppLocationPermissionScreen extends StatefulWidget {
  const InAppLocationPermissionScreen({
    super.key,
    required this.onSuccess,
    this.onManualEntry,
    this.onFailure,
    this.kit,
    this.config,
    this.storage,
    this.strings = const InAppLocationStrings(),
    this.theme = const InAppLocationTheme(),
    this.autoDetectIfReady = true,
    this.successDelay = const Duration(milliseconds: 1800),
    this.header,
    this.footer,
    this.settingsDialogBuilder = showDefaultLocationSettingsDialog,
  });

  final void Function(LocationFixResult result) onSuccess;
  final VoidCallback? onManualEntry;
  final void Function(LocationFlowFailure failure)? onFailure;
  final LocationKitBase? kit;
  final InAppLocationConfig? config;
  final LocationStorage? storage;
  final InAppLocationStrings strings;
  final InAppLocationTheme theme;
  final bool autoDetectIfReady;
  final Duration successDelay;
  final Widget? header;
  final Widget? footer;
  final SettingsDialogBuilder settingsDialogBuilder;

  @override
  State<InAppLocationPermissionScreen> createState() =>
      _InAppLocationPermissionScreenState();
}

class _InAppLocationPermissionScreenState
    extends State<InAppLocationPermissionScreen> {
  late final LocationFlowController _controller;
  bool _initialCheckDone = false;
  bool? _locationAlreadyOn;
  bool _isEnabling = false;
  String? _fetchedAddress;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialCheckDone) {
      _initialCheckDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkStatus());
    }
  }

  Future<void> _checkStatus() async {
    final kit = widget.kit ?? InAppLocationKit(config: widget.config);
    final gps = await kit.isGpsEnabled();
    final perm = await kit.hasPermission();
    final canFetch = gps && perm;
    if (!mounted) return;
    setState(() => _locationAlreadyOn = canFetch);
    if (canFetch && widget.autoDetectIfReady) {
      await _fetch();
    }
  }

  Future<void> _fetch() async {
    setState(() => _isEnabling = true);
    final result = await _controller.runFetch(
      context: context,
      persistOnSuccess: widget.storage != null,
    );
    if (!mounted) return;
    setState(() => _isEnabling = false);
    if (result is LocationFlowSuccess) {
      setState(
        () => _fetchedAddress =
            result.fix.formattedAddress ?? widget.strings.usingLocation,
      );
      await Future<void>.delayed(widget.successDelay);
      if (mounted) widget.onSuccess(result.fix);
    } else if (result is LocationFlowError) {
      widget.onFailure?.call(result.failure);
    }
  }

  Future<void> _allowLocation() async => _fetch();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final merged = widget.theme.mergeWith(theme);
    final busy = _isEnabling;

    Widget body;
    if (_fetchedAddress != null) {
      body = _successBody(merged);
    } else if (_locationAlreadyOn == null) {
      body = _checkingBody();
    } else if (_locationAlreadyOn!) {
      body = _fetchingBody();
    } else {
      body = _promptBody(merged, busy);
    }

    final wrapped = widget.theme.permissionScreenBuilder?.call(context, body) ??
        SafeArea(child: body);

    return Theme(
      data: merged,
      child: Scaffold(
        backgroundColor: widget.theme.scaffoldBackgroundColor ??
            merged.scaffoldBackgroundColor,
        body: Column(
          children: [
            if (widget.header != null) widget.header!,
            Expanded(child: wrapped),
            if (widget.footer != null) widget.footer!,
          ],
        ),
      ),
    );
  }

  Widget _checkingBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.theme.loadingIndicatorBuilder?.call(context) ??
              const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(widget.strings.checkingLocation),
        ],
      ),
    );
  }

  Widget _fetchingBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.theme.loadingIndicatorBuilder?.call(context) ??
              const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            widget.strings.fetchingLocation,
            style: widget.theme.titleStyle,
          ),
        ],
      ),
    );
  }

  Widget _successBody(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text(widget.strings.usingLocation, style: widget.theme.titleStyle),
            const SizedBox(height: 12),
            Text(
              _fetchedAddress!,
              textAlign: TextAlign.center,
              style: widget.theme.bodyStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _promptBody(ThemeData theme, bool busy) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.theme.illustration ??
              Icon(Icons.location_on, size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: 40),
          Text(
            widget.strings.permissionTitle,
            textAlign: TextAlign.center,
            style: widget.theme.titleStyle ??
                theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.strings.permissionBody,
            textAlign: TextAlign.center,
            style: widget.theme.bodyStyle ?? theme.textTheme.bodyMedium,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: busy ? null : _allowLocation,
              style: widget.theme.elevatedButtonStyle(theme),
              child: busy
                  ? widget.theme.loadingIndicatorBuilder?.call(context) ??
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                  : Text(
                      busy
                          ? widget.strings.turningOnLocationButton
                          : widget.strings.allowLocationButton,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.onManualEntry != null)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: busy ? null : widget.onManualEntry,
                style: widget.theme.outlinedButtonStyle(theme),
                child: Text(widget.strings.manualEntryButton),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
