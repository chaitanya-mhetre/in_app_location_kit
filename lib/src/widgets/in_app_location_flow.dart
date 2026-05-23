import 'package:flutter/material.dart';

import '../config/in_app_location_config.dart';
import '../models/location_fix_result.dart';
import '../models/location_flow_failure.dart';
import '../models/location_flow_result.dart';
import '../models/location_flow_step.dart';
import '../service/location_kit_base.dart';
import 'location_flow_controller.dart';

typedef InAppLocationFlowBuilder = Widget Function(
  BuildContext context,
  LocationFlowStep step,
  bool isBusy,
  Future<void> Function() start,
);

/// Fully custom UI: host builds widgets per [LocationFlowStep].
class InAppLocationFlow extends StatefulWidget {
  const InAppLocationFlow({
    super.key,
    required this.builder,
    this.kit,
    this.config,
    this.autoStart = false,
    this.onSuccess,
    this.onFailure,
  });

  final InAppLocationFlowBuilder builder;
  final LocationKitBase? kit;
  final InAppLocationConfig? config;
  final bool autoStart;
  final void Function(LocationFixResult result)? onSuccess;
  final void Function(LocationFlowFailure failure)? onFailure;

  @override
  State<InAppLocationFlow> createState() => _InAppLocationFlowState();
}

class _InAppLocationFlowState extends State<InAppLocationFlow> {
  late final LocationFlowController _flow;
  LocationFlowStep _step = LocationFlowStep.idle;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _flow = LocationFlowController(kit: widget.kit, config: widget.config);
    final kit = widget.kit ?? _flow.kit;
    kit.steps.listen((s) {
      if (mounted) setState(() => _step = s);
    });
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _start());
    }
  }

  Future<void> _start() async {
    setState(() {
      _busy = true;
      _step = LocationFlowStep.checking;
    });
    final result = await _flow.runFetch(
      context: context,
      showSettingsDialogOnFailure: false,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _step = _flow.step;
    });
    if (result is LocationFlowSuccess) {
      widget.onSuccess?.call(result.fix);
    } else if (result is LocationFlowError) {
      widget.onFailure?.call(result.failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _step, _busy, _start);
  }
}
