import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_location_kit/in_app_location_kit.dart';
import 'package:in_app_location_kit/maps.dart';
import 'package:in_app_location_kit/riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: InAppLocationKitExampleApp(),
    ),
  );
}

class InAppLocationKitExampleApp extends StatelessWidget {
  const InAppLocationKitExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'in_app_location_kit demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const DemoHomePage(),
    );
  }
}

class DemoHomePage extends ConsumerStatefulWidget {
  const DemoHomePage({super.key});

  @override
  ConsumerState<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends ConsumerState<DemoHomePage> {
  LocationFixResult? _last;

  @override
  Widget build(BuildContext context) {
    final cached = ref.watch(cachedLocationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('in_app_location_kit')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          cached.when(
            data: (c) => Text(
              c == null
                  ? 'No cached address'
                  : 'Cached: ${c.formattedAddress ?? '${c.latitude}, ${c.longitude}'}',
            ),
            loading: () => const Text('Loading cache...'),
            error: (e, _) => Text('Cache error: $e'),
          ),
          const SizedBox(height: 16),
          if (_last != null)
            Card(
              child: ListTile(
                title: const Text('Last fix'),
                subtitle: Text(_last!.formattedAddress ?? 'coords only'),
              ),
            ),
          const SizedBox(height: 8),
          InAppLocationButton(
            storage: ref.read(locationStorageProvider),
            theme: const InAppLocationTheme(primaryColor: Colors.orange),
            onLocation: (r) => setState(() => _last = r),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => InAppLocationPermissionScreen(
                    storage: ref.read(locationStorageProvider),
                    theme: const InAppLocationTheme(primaryColor: Colors.orange),
                    onSuccess: (r) {
                      setState(() => _last = r);
                      Navigator.pop(context);
                    },
                    onManualEntry: () => Navigator.pop(context),
                  ),
                ),
              );
            },
            child: const Text('Permission screen'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => InAppLocationLoadingScreen(
                    mode: 'gps',
                    storage: ref.read(locationStorageProvider),
                    onComplete: (r) {
                      if (r != null) setState(() => _last = r);
                      Navigator.pop(context);
                    },
                    onManualFallback: () => Navigator.pop(context),
                  ),
                ),
              );
            },
            child: const Text('Loading screen (GPS)'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              final route =
                  await ref.read(locationBootstrapProvider).resolve();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Bootstrap: ${route.action}')),
              );
            },
            child: const Text('Run bootstrap'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => InAppLocationMapScreen(
                    onConfirm: (r) {
                      setState(() => _last = r);
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
            child: const Text('Map picker'),
          ),
        ],
      ),
    );
  }
}
