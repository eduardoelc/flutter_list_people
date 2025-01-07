import 'package:flutter_list_people/model/endereco_model.dart';
import 'package:flutter_list_people/repositories/back4app/back4app_custom_dio.dart';

class Back4appEnderecoRepository {
  final _CustomDio = Back4appCustomDio();

  Back4appEnderecoRepository();

  Future<EnderecosModel> validCep(String cep) async {
    try {
      cep = cep.replaceAll(RegExp(r'\D'), '');
      if (cep.length == 8) {
        cep = '${cep.substring(0, 5)}-${cep.substring(5)}';
      }
      var encodedCep = Uri.encodeComponent(cep);
      var url = "?where={\"cep\":\"$encodedCep\"}";
      var result = await _CustomDio.dio.get("/Searches_Cep$url");
      return EnderecosModel.fromJson(result.data);
    } catch (e) {
      throw e;
    }
  }

  Future<EnderecosModel> getCep() async {
    try {
      var result = await _CustomDio.dio.get("/Searches_Cep");
      return EnderecosModel.fromJson(result.data);
    } catch (e) {
      throw e;
    }
  }

  Future<void> postCep(EnderecoModel enderecoModel) async {
    try {
      print("toJsonEndpoint: ${enderecoModel.toJsonEndpoint()}");
      await _CustomDio.dio
          .post("/Searches_Cep", data: enderecoModel.toJsonEndpoint());
    } catch (e) {
      throw e;
    }
  }

  Future<void> putCep(EnderecoModel enderecoModel) async {
    try {
      await _CustomDio.dio.put("/Searches_Cep/${enderecoModel.objectId}",
          data: enderecoModel.toJsonEndpoint());
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteCep(String objectId) async {
    try {
      await _CustomDio.dio.delete("/Searches_Cep/${objectId}");
    } catch (e) {
      throw e;
    }
  }
}
