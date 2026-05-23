import 'package:flutter/material.dart';

import '../config/in_app_location_config.dart';
import '../config/in_app_location_strings.dart';
import '../dialogs/location_settings_dialog.dart';
import '../models/location_fix_result.dart';
import '../models/location_flow_failure.dart';
import '../models/location_flow_result.dart';
import '../models/location_flow_step.dart';
import '../service/in_app_location_kit.dart';
import '../service/location_kit_base.dart';
import '../storage/location_storage.dart';

/// Imperative helper used by buttons and screens.
class LocationFlowController {
  LocationFlowController({
    LocationKitBase? kit,
    InAppLocationConfig? config,
    this.storage,
    this.strings = const InAppLocationStrings(),
    this.settingsDialogBuilder = showDefaultLocationSettingsDialog,
  }) : kit = kit ?? InAppLocationKit(config: config);

  final LocationKitBase kit;
  final LocationStorage? storage;
  final InAppLocationStrings strings;
  final SettingsDialogBuilder settingsDialogBuilder;

  LocationFlowStep step = LocationFlowStep.idle;
  bool isBusy = false;
  LocationFixResult? lastSuccess;
  LocationFlowFailure? lastFailure;

  Future<LocationFlowResult> runFetch({
    required BuildContext context,
    bool requestGpsIfDisabled = true,
    bool persistOnSuccess = true,
    bool showSettingsDialogOnFailure = true,
  }) async {
    isBusy = true;
    lastFailure = null;
    step = LocationFlowStep.checking;

    final result = await kit.fetchCurrentLocation(
      requestGpsIfDisabled: requestGpsIfDisabled,
    );

    isBusy = false;
    step = kit.currentStep;

    if (result is LocationFlowSuccess) {
      lastSuccess = result.fix;
      if (persistOnSuccess && storage != null) {
        await storage!.save(result.fix);
      }
      return result;
    }

    if (result is LocationFlowError) {
      lastFailure = result.failure;
      if (showSettingsDialogOnFailure && context.mounted) {
        final dialogType = dialogTypeForFailure(result.failure);
        if (dialogType != null) {
          final open = await settingsDialogBuilder(context, dialogType, strings);
          if (open == true && context.mounted) {
            await kit.openAppSettings();
          }
        }
      }
    }

    return result;
  }

  /// Khaugalli-style: request GPS via kit.ensureReady path inside fetch.
  Future<LocationFlowResult> runWithGpsPrompt({
    required BuildContext context,
    bool persistOnSuccess = true,
  }) =>
      runFetch(
        context: context,
        requestGpsIfDisabled: true,
        persistOnSuccess: persistOnSuccess,
      );
}
