import 'package:flutter/material.dart';
import 'package:patrimonio/app/models/patrimonio.dart';
import 'package:patrimonio/app/services/local_database_service.dart';

class ConferenciaProvider extends ChangeNotifier {
  final LocalDatabaseService _db;
  List<Patrimonio> _itens = [];
  int _patrimoniosConferidos = 0;

  ConferenciaProvider(this._db);

  List<Patrimonio> get itens => List.unmodifiable(_itens);
  int get tamanhoLista => _itens.length;
  int get patrimoniosConferidos => _patrimoniosConferidos;

  Future<void> carregarItens() async {
    _itens = await _db.getConferencia();
    _patrimoniosConferidos = await _db.getQuantidadePatrimoniosConferidos();
    notifyListeners();
  }

  Future<void> adicionarItem(Patrimonio p) async {
    await _db.inserirNaConferencia(p);
    await carregarItens(); // recarrega e notifica
  }

  Future<void> limparConferencia() async {
    await _db.limparTabelaConferencia();
    await carregarItens();
  }

  // Atualiza o status de conferido de um patrimonio
  // Retorna verdadeiro para atualização bem sucedida
  // Retorna falso para erro ou patrimonio não encontrado
  Future<bool> atualizaStatusConferido(
    String situacaoConferencia,
    String patrimonio,
  ) async {
    final int result = await _db.atualizaConferenciaPatrimonio(
      situacaoConferencia,
      patrimonio,
    );
    await carregarItens();

    return result > 0;
  }

  // Atualiza o status de conferido de um patrimonio usando o número antigo
  // Retorna verdadeiro para atualização bem sucedida
  // Retorna falso para erro ou patrimonio não encontrado
  Future<bool> atualizaStatusConferidoNumeroAntigo(
    String situacaoConferencia,
    String patrimonioAntigo,
  ) async {
    final int result = await _db.atualizaConferenciaPatrimonioAntigo(
      situacaoConferencia,
      patrimonioAntigo,
    );
    await carregarItens();

    return result > 0;
  }

  Future<void> removerItem(String patrimonio) async {
    await _db.removePatrimonioDaConferencia(patrimonio);
    await carregarItens(); // recarrega e notifica
  }
}
