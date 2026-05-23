import 'package:flutter/material.dart';

import '../service/in_app_location_kit.dart';
import '../service/location_kit_base.dart';

/// Shows [child] only when GPS + permission are ready; otherwise [placeholder].
class InAppLocationGuard extends StatefulWidget {
  const InAppLocationGuard({
    super.key,
    required this.child,
    this.kit,
    this.placeholder,
    this.builder,
    this.checkOnInit = true,
  });

  final Widget child;
  final LocationKitBase? kit;
  final Widget? placeholder;

  /// Full control: `(context, ready, checking)`.
  final Widget Function(BuildContext context, bool ready, bool checking)?
      builder;

  final bool checkOnInit;

  @override
  State<InAppLocationGuard> createState() => _InAppLocationGuardState();
}

class _InAppLocationGuardState extends State<InAppLocationGuard> {
  late final LocationKitBase _kit;
  bool _checking = true;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _kit = widget.kit ?? InAppLocationKit();
    if (widget.checkOnInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    }
  }

  Future<void> _check() async {
    setState(() => _checking = true);
    final gps = await _kit.isGpsEnabled();
    final perm = await _kit.hasPermission();
    if (!mounted) return;
    setState(() {
      _checking = false;
      _ready = gps && perm;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.builder != null) {
      return widget.builder!(context, _ready, _checking);
    }
    if (_checking) {
      return widget.placeholder ??
          const Center(child: CircularProgressIndicator());
    }
    if (!_ready) {
      return widget.placeholder ?? const SizedBox.shrink();
    }
    return widget.child;
  }
}
