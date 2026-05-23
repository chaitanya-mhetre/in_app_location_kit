import 'package:flutter/material.dart';

import '../config/in_app_location_strings.dart';
import '../config/in_app_location_theme.dart';

/// Shown when [InAppLocationMapScreen] is used without a native Maps API key.
class MapsUnavailablePlaceholder extends StatelessWidget {
  const MapsUnavailablePlaceholder({
    super.key,
    this.strings = const InAppLocationStrings(),
    this.theme = const InAppLocationTheme(),
    this.setupHint,
    this.appBarTitle = 'Set location',
  });

  final InAppLocationStrings strings;
  final InAppLocationTheme theme;
  final String? setupHint;
  final String appBarTitle;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 72,
              color: theme.primaryColor ?? themeData.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              strings.mapsApiKeyMissingTitle,
              textAlign: TextAlign.center,
              style: theme.titleStyle ??
                  themeData.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              setupHint ?? strings.mapsApiKeyMissingBody,
              textAlign: TextAlign.center,
              style: theme.bodyStyle ?? themeData.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
