import 'package:flutter_list_people/model/viacep_model.dart';
import 'package:flutter_list_people/repositories/viacep/via_cep_custom_dio.dart';

class ViaCepRepository {
  final _CustomDio = ViaCepCustomDio();

  Future<ViaCEPModel> consultarCEP(String cep) async {
    try {
      cep = cep.replaceAll(RegExp(r'\D'), '');
      var result = await _CustomDio.dio.get("/$cep/json/");
      return ViaCEPModel.fromJson(result.data);
    } catch (e) {
      throw e;
    }
  }
}
