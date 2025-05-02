extension BoolExtensions on bool {
  void ifTrue(Function() callback) {
    if (this) {
      callback();
    }
  }

  void ifFalse(Function() callback) {
    if (!this) {
      callback();
    }
  }
}