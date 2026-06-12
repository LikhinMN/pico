import 'package:flutter/widgets.dart';
import 'store.dart';
import 'target_listener.dart';

/// A highly-optimized widget that connects to a [Store] and rebuilds
/// only when a specific slice of the state changes.
class PicoBuilder<S, T> extends StatefulWidget {
  /// Creates a [PicoBuilder] widget.
  const PicoBuilder({
    super.key,
    required this.store,
    required this.selector,
    required this.builder,
    this.equals,
  });

  /// The [Store] instance to listen to.
  final Store<S> store;

  /// A pure function that extracts the precise piece of data needed.
  final T Function(S state) selector;

  /// An optional custom equality comparator to override deep equality behavior.
  final bool Function(T oldSlice, T newSlice)? equals;

  /// The builder function that receives the `context` and the precise `slice` of data.
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
