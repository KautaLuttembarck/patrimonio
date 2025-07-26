import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/material.dart';
import 'package:patrimonio/app/models/patrimonio.dart';
import 'package:patrimonio/app/services/local_database_service.dart';

class ConferenciaProvider extends ChangeNotifier {
  final LocalDatabaseService _db;
  List<Patrimonio> _itens = [];
  List<Patrimonio> filteredItens = [];
  int _patrimoniosConferidos = 0;

  ConferenciaProvider(this._db);

  List<Patrimonio> get itens => List.unmodifiable(_itens);
  int get tamanhoLista => _itens.length;
  int get patrimoniosConferidos => _patrimoniosConferidos;

  // Disponibilzia para consumo:
  // Todos os patrimônios da tabela conferência
  // A quantidade de patrimonios conferidos.
  Future<void> carregarItens() async {
    _itens = await _db.getConferencia();
    _patrimoniosConferidos = await _db.getQuantidadePatrimoniosConferidos();
    notifyListeners();
  }

  Future<void> filtrarItens(String filtro) async {
    filteredItens =
        _itens
            .where(
              (patrimonio) =>
                  (patrimonio.patrimonio == filtro ||
                      patrimonio.nAntigo == filtro ||
                      patrimonio.descricao.toUpperCase().contains(
                        filtro.toUpperCase(),
                      )),
            )
            .toList();
    notifyListeners();
  }

  Future<void> adicionarItem(Patrimonio p) async {
    await _db.inserirNaConferencia(p);
    await carregarItens();
    Clarity.sendCustomEvent("Adicionou um elemento na lista de conferência");
  }

  Future<void> limparConferencia() async {
    await _db.limparTabelaConferencia();
    await carregarItens();
    Clarity.sendCustomEvent(
      "Cancelou uma conferência em andamento (Tabela de conferência patrimonial limpa)",
    );
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
    final index = filteredItens.indexWhere(
      (patrimonioFiltrado) => patrimonioFiltrado.patrimonio == patrimonio,
    );
    if (index != -1) {
      filteredItens[index].situacaoConferencia = situacaoConferencia;
    }
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

  // Remove um patrimônio da lista de conferência.
  // Retorna verdadeiro pra caso de remoção com sucesso e falso pra caso de falha
  Future<bool> removerItem(Patrimonio patrimonio) async {
    // Busca o índice do elemento desejado na lista
    final index = _itens.indexWhere(
      (elemento) => elemento.patrimonio == patrimonio.patrimonio,
    );

    // Remove o elemento caso tenha sido encontrado
    if (index != -1) {
      _itens.removeAt(index);
    }

    // Ajusta a contagem de conferidos, caso necessário
    if (patrimonio.situacaoConferencia == "conferido") {
      _patrimoniosConferidos--;
    }

    // Busca o índice do elemento desejado na lista filtrada
    final indexFiltro = filteredItens.indexWhere(
      (patrimonioFiltrado) =>
          patrimonioFiltrado.patrimonio == patrimonio.patrimonio,
    );

    // Remove o elemento caso tenha sido encontrado
    if (indexFiltro != -1) {
      filteredItens.removeAt(indexFiltro);
    }

    notifyListeners();
    try {
      await _db.removePatrimonioDaConferencia(patrimonio.patrimonio);
      Clarity.sendCustomEvent("Removido um patrimônio da lista de conferência");
      return true;
    } catch (e) {
      Clarity.sendCustomEvent(
        "Falha ao remover um patrimônio da lista de conferências no DB",
      );
      // Se falhar, recarrega toda a lista
      await carregarItens(); // recarrega e notifica
      return false;
    }
  }
}
