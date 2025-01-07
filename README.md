# flutter_list_people (Lista Pessoas)

## Desafio (Criando um App Flutter de Lista de Contatos)
* Criar uma aplicação Flutter​.
* Criar um banco de dados / Back4App​.
* Fazer um cadastro de pessoa com foto de perfil​.
* Salvar apenas o path da imagem na base de dados​.
* Listar as pessoas em uma lista com sua respectiva foto​.
* Usar os outros componentes aprendidos.

## Funcionalidade
* Registros de Pessoa e Endereço.
    * Utilizando o Back4App para Cadastro/Edição/Consulta/Exclusão.
    * Vincular Endereço: Ao cadastrar verifica se o endereço existe na nossa base, se não estiver é cadastra e vinculado o ID do Endereço no Dado da Pessoa.
* Consultar endereço pelo ViaCEP.
* Configuração de Bloqueio de Visualização de Campos (Pessoa e Endereço).
    * Utilizando **Shared Preferences** para salvar essa configuração.