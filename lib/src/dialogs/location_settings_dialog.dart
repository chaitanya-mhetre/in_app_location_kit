import 'package:flutter/material.dart';

import '../config/in_app_location_strings.dart';
import '../models/location_flow_failure.dart';

enum LocationSettingsDialogType {
  gpsOff,
  permissionDeniedForever,
}

/// Shows default Material dialogs; replace via [SettingsDialogBuilder].
typedef SettingsDialogBuilder = Future<bool?> Function(
  BuildContext context,
  LocationSettingsDialogType type,
  InAppLocationStrings strings,
);

Future<bool?> showDefaultLocationSettingsDialog(
  BuildContext context,
  LocationSettingsDialogType type,
  InAppLocationStrings strings,
) {
  final title = type == LocationSettingsDialogType.gpsOff
      ? strings.gpsOffDialogTitle
      : strings.permissionDeniedForeverTitle;
  final body = type == LocationSettingsDialogType.gpsOff
      ? strings.gpsOffDialogBody
      : strings.permissionDeniedForeverBody;

  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(strings.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(strings.openSettings),
        ),
      ],
    ),
  );
}

LocationSettingsDialogType? dialogTypeForFailure(LocationFlowFailure failure) {
  switch (failure.type) {
    case LocationFlowFailureType.gpsDisabled:
      return LocationSettingsDialogType.gpsOff;
    case LocationFlowFailureType.permissionDeniedForever:
      return LocationSettingsDialogType.permissionDeniedForever;
    default:
      return null;
  }
}
