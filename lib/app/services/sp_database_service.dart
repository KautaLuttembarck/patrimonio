import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:patrimonio/app/services/sp_database_config.dart';
import 'package:patrimonio/app/models/patrimonio.dart';

import 'local_database_service.dart';

class SpDatabaseService {
  // Realiza o login no spmetrodf passando os dados de usuário e senha;
  // Está pendente a criptografia dos dados.
  Future<String> login(String usuario, String senha) async {
    const String endpoint = SpDatabaseConfig.loginEndPoint;

    final Uri url = Uri.https(SpDatabaseConfig.baseUrl, endpoint);

    try {
      // Realiza a requisição de login
      http.Response response = await http.post(
        url,
        headers: SpDatabaseConfig.headersService,
        body: {'matri': usuario, 'senha': senha},
      );

      // Organiza o retorno
      if (response.statusCode == 200) {
        return utf8.decode(response.bodyBytes);
      } else {
        return jsonEncode({
          "login_result": false,
          "Erro": "Falha de comunicação com o servidor!",
          "body": utf8.decode(response.bodyBytes),
        });
      }
    } catch (e) {
      return jsonEncode({
        "login_result": false,
        "Erro": "Falha ao enviar a comunicação!",
        "body": e.toString(),
      });
    }
  }

  // Obtém a lista de Unidades Administrativas do servidor (consulta 1)
  Future<String> getListaUa() async {
    final uri = Uri.https(
      SpDatabaseConfig.baseUrl,
      SpDatabaseConfig.localizacaoEndPoint,
      {
        'consulta': SpDatabaseConfig.getListaUa,
      },
    );
    try {
      final response = await http.get(
        uri,
      );
      if (response.statusCode == 200) {
        final data = utf8.decode(response.bodyBytes);
        // Remove o caractere BOM se existir
        return data.trim().replaceFirst('\uFEFF', '');
      } else {
        return utf8.decode(response.bodyBytes);
        // return jsonEncode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      return "";
    }
  }

  // Obtém a lista de Unidade de Localização do servidor (consulta 2) com base
  // no id da Unidade Administrativa informada
  Future<String> getListaUl(int idUa) async {
    final uri = Uri.https(
      SpDatabaseConfig.baseUrl,
      SpDatabaseConfig.localizacaoEndPoint,
      {
        'consulta': SpDatabaseConfig.getListaUl,
        'id_ua': '$idUa', // ID da UA selecionada
      },
    );
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = utf8.decode(response.bodyBytes);
        // Remove o caractere BOM se existir
        return data.trim().replaceFirst('\uFEFF', '');
      } else {
        return utf8.decode(response.bodyBytes);
        // return jsonEncode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      return "";
    }
  }

  // Recupera toda a lista de patrimônios do servidor online
  // grava no banco de dados local
  // retorna verdadeiro para dados gravados com sucesso
  // retorna falso para casos de falha
  Future<bool> getListaPatrimonios(BuildContext ctx) async {
    final uri = Uri.https(
      SpDatabaseConfig.baseUrl,
      SpDatabaseConfig.listaPatrimoniosEndPoint,
    );
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        String data = utf8.decode(response.bodyBytes);

        // Decodifica a lista do JSON
        var dataDecoded = jsonDecode(data);

        // Transforma em lista de objetos Patrimonio
        List<Patrimonio> listaPatrimonios =
            (dataDecoded as List)
                .map((item) => Patrimonio.fromMap(item))
                .toList();

        // Grava os dados no local db e retorna
        // Verdadeiro pra gravação bem sucedida
        // Falso para falha na gravação
        if (ctx.mounted) {
          return await ctx.read<LocalDatabaseService>().inserirPatrimonios(
            listaPatrimonios,
          );
        }
        return false;
        // Remove o caractere BOM se existir
        // return data.trim().replaceFirst('\uFEFF', '');
      } else {
        // erro
        debugPrint(
          "Erro na getListaPatrimonios! Status Code: ${response.statusCode}",
        );
        return false;
      }
    } catch (e) {
      debugPrint("Erro: $e");
      return false;
    }
  }
}
