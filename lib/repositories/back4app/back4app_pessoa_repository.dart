import 'package:dio/dio.dart';
import 'package:flutter_list_people/model/pessoa_model.dart';
import 'package:flutter_list_people/repositories/back4app/back4app_custom_dio.dart';

class Back4appPessoaRepository {
  final _CustomDio = Back4appCustomDio();

  Back4appPessoaRepository();

  Future<PessoasModel> validPessoa(String id) async {
    try {
      var url = "?where={\"objectId\":$id}";
      var result = await _CustomDio.dio.get("/contacts$url");
      return PessoasModel.fromJson(result.data);
    } catch (e) {
      throw e;
    }
  }

  Future<PessoasModel> getPessoas() async {
    try {
      var result = await _CustomDio.dio.get("/contacts?include=endereco");
      return PessoasModel.fromJson(result.data);
    } catch (e) {
      throw e;
    }
  }

  Future<void> postPessoa(PessoaModel pessoaModel) async {
    try {
      print("Pessoa toJsonEndpoint: ${pessoaModel.toJsonEndpoint()}");
      var result = await _CustomDio.dio.post(
        "/contacts",
        data: pessoaModel.toJsonEndpoint(),
        options: Options(
          headers: {
            'X-Parse-Application-Id':
                'B2T3K9U4Q33aBtgYAdBUH7UVIo2jJ2N0kftmcaOA',
            'X-Parse-REST-API-Key': '5pdR7vhfLKRu7xpA1r07cHqc7P4hY5p3vQx66BFd',
            'Content-Type': 'application/json',
          },
        ),
      );
      print("result: ${result}");
    } catch (e) {
      print("e: ${e}");
      throw e;
    }
  }

  Future<void> putPessoa(PessoaModel pessoaModel) async {
    try {
      print("toJsonEndpoint: ${pessoaModel.toJsonEndpoint()}");
      await _CustomDio.dio.put("/contacts/${pessoaModel.objectId}",
          data: pessoaModel.toJsonEndpoint());
    } catch (e) {
      throw e;
    }
  }

  Future<void> deletePessoa(String objectId) async {
    try {
      await _CustomDio.dio.delete("/contacts/${objectId}");
    } catch (e) {
      throw e;
    }
  }
}
