import 'package:get/get.dart';
import 'package:innovare_core/data/errors/rest_error.dart';

class UnknownRestError extends RestError {
  UnknownRestError(Response response): super(
    response, 'Unknown REST error'
  );
}