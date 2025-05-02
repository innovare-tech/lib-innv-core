extension IntExtensions on int {
  Duration seconds() {
    return Duration(seconds: this);
  }

  Duration milliseconds() {
    return Duration(milliseconds: this);
  }

  Duration microseconds() {
    return Duration(microseconds: this);
  }

  Duration minutes() {
    return Duration(minutes: this);
  }

  Duration hours() {
    return Duration(hours: this);
  }

  Duration days() {
    return Duration(days: this);
  }
}