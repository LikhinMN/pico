import 'package:flutter/widgets.dart';
import 'store.dart';
import 'target_listener.dart';

class PicoBuilder<S, T> extends StatefulWidget {
  const PicoBuilder({
    super.key,
    required this.store,
    required this.selector,
    required this.builder,
    this.equals,
  });

  final Store<S> store;
  final T Function(S state) selector;
  final bool Function(T oldSlice, T newSlice)? equals;
  final Widget Function(BuildContext context, T value) builder;

  @override
  State<PicoBuilder<S, T>> createState() => _PicoBuilderState<S, T>();
}

class _PicoBuilderState<S, T> extends State<PicoBuilder<S, T>> {
  late TargetListener<S, T> _listener;

  void _createListener() {
    _listener = TargetListener<S, T>(
      selector: widget.selector,
      onRebuild: () {
        if (mounted) {
          setState(() {});
        }
      },
      initialState: widget.store.state,
      equals: widget.equals,
    );
  }

  @override
  void initState() {
    super.initState();
    _createListener();
    widget.store.addListener(_listener);
  }

  @override
  void didUpdateWidget(PicoBuilder<S, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.store != widget.store) {
      oldWidget.store.removeListener(_listener);
      _createListener();
      widget.store.addListener(_listener);
    }
  }

  @override
  void dispose() {
    widget.store.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _listener.cachedSlice);
  }
}
