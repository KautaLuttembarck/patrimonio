import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:patrimonio/app/models/patrimonio.dart';
import 'package:patrimonio/app/services/local_database_config.dart';

class LocalDatabaseService {
  static Database? _database;
  // Inicializa o banco de dados. Caso ele não exista, cria.
  Future<void> init() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'patrimonios.db');

    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        // Tabela patrimônios armazena todos os dados de patrimônio da empresa
        // para execução offline
        await db.execute(
          'CREATE TABLE patrimonios '
          '('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'Patrimonio TEXT, '
          'N_Antigo TEXT, '
          'Situacao TEXT, '
          'Descricao TEXT, '
          'UA TEXT, '
          'Id_ul INTEGER, '
          'Localidade TEXT, '
          'Responsavel TEXT '
          ')',
        );

        // Tabela alterações armazena os registros de ações realizadas para
        // debug e controle da data da última carga da tabela patrimônios
        await db.execute(
          'CREATE TABLE alteracoes '
          '('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'acao TEXT, '
          'realizado_em TEXT DEFAULT CURRENT_TIMESTAMP '
          ')',
        );

        // Tabela conferencia armazena os patrimônios de uma UL e o status de
        // conferência para envio posterior ao SPMETRODF
        await db.execute(
          'CREATE TABLE conferencia '
          '('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'Patrimonio TEXT, '
          'N_Antigo TEXT, '
          'Situacao TEXT, '
          'Descricao TEXT, '
          'UA TEXT, '
          'Id_ul INTEGER, '
          'Localidade TEXT, '
          'Responsavel TEXT, '
          'situacaoConferencia TEXT DEFAULT \'pendente\' '
          ')',
        );
      },
    );
  }

  // Limpa a tabela e insere nova lista de patrimônios no banco de dados.
  // Retorna verdadeiro caso a inserção tenha ocorrido corretamente
  // Retorna falso em caso de erro
  Future<bool> inserirPatrimonios(List<Patrimonio> lista) async {
    // Verifica se o banco de dados foi inicializado
    if (_database == null) {
      return false;
    }

    try {
      // Inicializa a transação para garantir que se der errado nada seja executado
      await _database!.transaction((txn) async {
        // Primeira ação: Zera a tabela
        await txn.delete('patrimonios');

        // Prepara o batch dentro da transação
        final batch = txn.batch();

        // Segunda ação: inserir os patrimônios em batch
        for (var item in lista) {
          batch.insert(
            'patrimonios',
            item.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        // Executa o batch
        await batch.commit(noResult: true);
      });

      // Registra na tabela acoes a inserção
      inserirAcaoRealizada("inserirPatrimonios");
      return true;
    } catch (e) {
      debugPrint('Erro ao inserir patrimonios: $e');
      return false;
    }
  }

  // Retorna a quantidade de patrimonios registrados no banco de dados local
  Future<int> lerQuantidadePatrimonios() async {
    final result = await _database?.rawQuery(
      'SELECT COUNT(*) AS total FROM patrimonios',
    );

    // Registra na tabela acoes
    inserirAcaoRealizada("lerQuantidadePatrimonios");

    if (result != null && result.isNotEmpty) {
      return Sqflite.firstIntValue(result) ?? 0;
    }
    return 0;
  }

  // Insere na tabela alteracoes a ação realizada
  Future<void> inserirAcaoRealizada(String acao) async {
    if (_database == null) {
      return;
    }

    _database!.insert('alteracoes', {
      'acao': acao,
      'realizado_em': DateTime.now()
          .toIso8601String()
          .substring(0, 19)
          .replaceFirst('T', ' '),
    });
  }

  // retorna o registro da última ação realizada no banco de dados local
  // retorna null em caso de tabela vazia
  Future<Map<String, dynamic>?> obterUltimaCarga() async {
    if (_database == null) {
      return null;
    }

    final List<Map<String, dynamic>> resultado = await _database!.query(
      'alteracoes',
      orderBy: 'realizado_em DESC',
      where: "acao = ?",
      whereArgs: ['inserirPatrimonios'],
      limit: 1,
    );
    return resultado.isNotEmpty ? resultado.first : null;
  }

  // Obtém a data da última carga no banco e retorna:
  //  - verdadeiro para data maior que o valor da validade dos dados ou caso
  //  não exista registro de carga
  //  - falso caso a carga registrada tenha ocorrido em menos de 24h
  Future<bool> precisaAtualizar() async {
    if (_database == null) {
      return false;
    }
    Map<String, dynamic>? ultimaAcao = await obterUltimaCarga();

    if (ultimaAcao == null) {
      return true;
    }

    final String dataStr = ultimaAcao['realizado_em'];
    final DateTime dataUltima = DateTime.parse(dataStr);
    final DateTime agora = DateTime.now();

    final Duration diferenca = agora.difference(dataUltima);

    // Retorna se já passou a validade dos dados
    return diferenca.inHours >= LocalDatabaseConfig.validadeDosDados;
  }

  Future<List<Patrimonio>> getPatrimoniosDaUl(int ul) async {
    if (_database == null) {
      return [];
    }
    final List<Map<String, dynamic>> result = await _database!.query(
      'patrimonios',
      where: 'Id_ul = ?',
      whereArgs: [ul],
    );
    List<Patrimonio> patrimonios =
        result.map((item) => Patrimonio.fromMap(item)).toList();

    return patrimonios;
  }

  // Limpa a tabela de patrimonios
  // retorna verdadeiro para ação realizada corretamente
  // falso para erro na execução
  Future<bool> esvaziaTabelaPatrimonios() async {
    if (_database == null) {
      return false;
    }
    try {
      _database!.delete('patrimonios');

      _database!.delete('alteracoes');
    } catch (e) {
      debugPrint('Erro ao esvaziar o banco $e');
      return false;
    }
    Clarity.sendCustomEvent("Limpou o banco de dados local");
    // Registra na tabela acoes
    inserirAcaoRealizada("esvaziaTabelaPatrimonios");
    return true;
  }

  // Copia os patrimônios de determinada UL para conferência
  Future<void> copiarParaConferenciaPorUl(int idUl) async {
    if (_database == null) return;

    final patrimonios = await getPatrimoniosDaUl(idUl);

    if (patrimonios.isEmpty) return;

    await _database!.transaction((txn) async {
      // Limpa a tabela conferencia antes de inserir novos dados
      await txn.delete('conferencia');

      final batch = txn.batch();

      for (var item in patrimonios) {
        batch.insert(
          'conferencia',
          item.toMapConferencia(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    });
    // Registra na tabela acoes
    inserirAcaoRealizada("copiarParaConferenciaPorUl");
  }

  // Recupera os dados da tabela de conferencia
  // retorna uma lista vazia em caso de erro
  Future<List<Patrimonio>> getConferencia() async {
    if (_database == null) return [];

    final List<Map<String, dynamic>> result = await _database!.query(
      'conferencia',
    );
    return result.map((e) => Patrimonio.fromMapConferencia(e)).toList();
  }

  // Inclui um patrimonio na tabela de conferência
  Future<void> inserirNaConferencia(Patrimonio p) async {
    if (_database == null) return;

    await _database!.insert(
      'conferencia',
      p.toMapConferencia(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Registra na tabela acoes
    inserirAcaoRealizada("inserirNaConferencia");
  }

  Future<void> limparTabelaConferencia() async {
    if (_database == null) return;

    await _database!.delete('conferencia');
    // Registra na tabela acoes
    inserirAcaoRealizada("limparTabelaConferencia");
  }

  // Atualiza a situação de conferência de um patrimônio
  // Retorna a quantidade de linhas afetadas
  Future<int> atualizaConferenciaPatrimonio(
    String situacaoConferencia,
    String patrimonio,
  ) async {
    if (_database == null) return 0;

    return await _database!.update(
      'conferencia',
      {'situacaoConferencia': situacaoConferencia},
      where: 'Patrimonio = ?',
      whereArgs: [patrimonio],
    );
  }

  // Atualiza a situação de conferência de um patrimônio
  // Retorna a quantidade de linhas afetadas
  Future<int> atualizaConferenciaPatrimonioAntigo(
    String situacaoConferencia,
    String patrimonioAntigo,
  ) async {
    if (_database == null) return 0;

    return await _database!.update(
      'conferencia',
      {'situacaoConferencia': situacaoConferencia},
      where: 'N_Antigo = ?',
      whereArgs: [patrimonioAntigo],
    );
  }

  // Obtém os dados de um patrimônio pelo número patrimonial
  Future<List<Patrimonio>> getPatrimonio(String patrimonio) async {
    if (_database == null) return [];

    final List<Map<String, dynamic>> result = await _database!.query(
      'patrimonios',
      where: "Patrimonio = ?",
      whereArgs: [patrimonio],
    );
    return result.map((e) => Patrimonio.fromMapConferencia(e)).toList();
  }

  // Obtém os dados de um patrimônio pelo número patrimonial antigo
  Future<List<Patrimonio>> getPatrimonioAntigo(String patrimonio) async {
    if (_database == null) return [];

    final List<Map<String, dynamic>> result = await _database!.query(
      'patrimonios',
      where: "N_Antigo = ?",
      whereArgs: [patrimonio],
    );
    return result.map((e) => Patrimonio.fromMapConferencia(e)).toList();
  }

  // Remove da tabela de conferência o patrimônio informado
  Future<void> removePatrimonioDaConferencia(String patrimonio) async {
    if (_database == null) return;
    await _database!.delete(
      'conferencia',
      where: "Patrimonio = ?",
      whereArgs: [patrimonio],
    );

    // Registra na tabela acoes
    inserirAcaoRealizada("removePatrimonioDaConferencia $patrimonio");
  }

  // Obtém a quantidade de patrimônios conferidos
  Future<int> getQuantidadePatrimoniosConferidos() async {
    if (_database == null) return 0;

    final result = await _database!.rawQuery(
      'SELECT COUNT(*) AS \'conferidos\' '
      'FROM conferencia '
      'WHERE conferencia.situacaoConferencia != \'pendente\';',
    );

    return result[0]['conferidos'] as int;
  }
}
