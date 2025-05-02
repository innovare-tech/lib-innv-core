import 'package:get/get.dart';

extension GenericExtensions<T> on T {
  T register({ bool permanent = true }) {
    return Get.put<T>(this, permanent: permanent);
  }

  void lazyRegister() {
    Get.lazyPut<T>(() => this);
  }
}

extension NullableGenericExtensions<T> on T? {
  T orElse(T defaultValue) {
    return this ?? defaultValue;
  }
}