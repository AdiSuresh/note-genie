import 'package:http/http.dart';

extension BaseResponseExtension on BaseResponse {
  bool get ok {
    return statusCode ~/ 100 == 2;
  }
}
