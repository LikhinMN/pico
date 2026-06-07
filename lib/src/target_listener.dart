class TargetListener<S, T> {
  TargetListener({
    required this.selector,
    required this.onRebuild,
    required S initialState,
    this.equals,
  }) : cachedSlice = selector(initialState);

  final T Function(S state) selector;
  final bool Function(T oldSlice, T newSlice)? equals;
  final void Function() onRebuild;

  T cachedSlice;

  bool updateAndCheck(S newState) {
    final newSlice = selector(newState);
    
    final bool hasChanged;
    if (equals != null) {
      hasChanged = !equals!(cachedSlice, newSlice);
    } else {
      hasChanged = cachedSlice != newSlice;
    }

    if (hasChanged) {
      cachedSlice = newSlice;
      return true;
    }
    
    return false;
  }
}
