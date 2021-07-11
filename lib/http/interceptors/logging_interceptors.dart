import 'package:http_interceptor/http_interceptor.dart';

class LoggingInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    print('Request');
    print('headers ' + data.headers.toString());
    print('body ' + data.body.toString());
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    print('Response');
    print('status code ' + data.statusCode.toString());
    print('headers ' + data.headers.toString());
    print('body ' + data.body.toString());
    return data;
  }
}
