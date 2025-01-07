import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_list_people/repositories/viacep/via_cep_dio_interceptor.dart';

class ViaCepCustomDio {
  final _dio = Dio();

  Dio get dio => _dio;

  ViaCepCustomDio() {
    _dio.options.headers["Content-Type"] = "application/json";
    _dio.options.baseUrl = dotenv.get("VIACEPBASEURL");
    _dio.interceptors.add(ViaCepDioInterceptor());
  }
}
