import 'package:flutter_list_people/model/endereco_model.dart';

class PessoasModel {
  List<PessoaModel>? results = [];

  PessoasModel(this.results);

  PessoasModel.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <PessoaModel>[];
      json['results'].forEach((v) {
        results!.add(PessoaModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PessoaModel {
  String objectId = "";
  String createdAt = "";
  String updatedAt = "";
  String nome = "";
  String telefone = "";
  String imagem = "";
  String numero = "";
  String dataNacimento = "";
  EnderecoModel endereco = EnderecoModel.vazio();

  PessoaModel(
    this.objectId,
    this.createdAt,
    this.updatedAt,
    this.nome,
    this.telefone,
    this.imagem,
    this.numero,
    this.dataNacimento,
    this.endereco,
  );

  PessoaModel.criar(
    this.nome,
    this.telefone,
    this.imagem,
    this.numero,
    this.dataNacimento,
    this.endereco,
  );

  PessoaModel.criarEdit(
    this.objectId,
    this.nome,
    this.telefone,
    this.imagem,
    this.numero,
    this.dataNacimento,
    this.endereco,
  );

  PessoaModel.fromJson(Map<String, dynamic> json) {
    objectId = json['objectId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    nome = json['nome'];
    telefone = json['telefone'];
    imagem = json['imagem'];
    numero = json['numero'];
    dataNacimento = json['data_nacimento'];
    if (json['endereco'] != null) {
      endereco = EnderecoModel.fromJson(json['endereco']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['objectId'] = objectId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['nome'] = nome;
    data['telefone'] = telefone;
    data['imagem'] = imagem;
    data['numero'] = numero;
    data['data_nacimento'] = dataNacimento;
    if (endereco != []) {
      data['endereco'] = endereco.toJson();
    }
    return data;
  }

  Map<String, dynamic> toJsonEndpoint() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nome'] = nome;
    data['telefone'] = telefone;
    data['imagem'] = imagem;
    data['numero'] = numero;
    data['data_nacimento'] = dataNacimento;
    if (endereco.objectId.isNotEmpty) {
      data['endereco'] = {
        "__type": "Pointer",
        "className": "Searches_Cep",
        "objectId": endereco.objectId
      };
    }
    // if (endereco != []) {
    //   data['endereco'] = endereco.toJson();
    // }
    return data;
  }

  // Retorna a lista de campos do Pessoas para gerar a configuração de visibilidade
  static List<Map<String, String>> getFields() {
    return [
      {'name': 'createdAt', 'label': 'Criado'},
      {'name': 'updatedAt', 'label': 'Ultima Alteração'},
      {'name': 'nome', 'label': 'Nome'},
      {'name': 'telefone', 'label': 'Telefone'},
      {'name': 'imagem', 'label': 'Foto'},
      {'name': 'numero', 'label': 'Nº'},
      {'name': 'dataNacimento', 'label': 'Data de Nascimento'},
      {'name': 'endereco', 'label': 'Endereço'},
    ];
  }

  // Retorna a lista de campos do Pessoas para cadastro e edição
  static List<Map<String, String>> dynamicFields() {
    return [
      {'name': 'nome', 'label': 'Nome', 'type': 'text', 'format': 'String'},
      {
        'name': 'telefone',
        'label': 'Telefone',
        'type': 'text',
        'format': 'fone'
      },
      {
        'name': 'dataNacimento',
        'label': 'Data de Nascimento',
        'type': 'text',
        'format': 'date'
      },
      {
        'name': 'numero',
        'label': 'Nº Endereço',
        'type': 'text',
        'format': 'String'
      },
    ];
  }

  static int countFields() {
    return 5;
  }
}
