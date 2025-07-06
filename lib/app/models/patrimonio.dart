class Patrimonio {
  final String patrimonio;
  final String nAntigo;
  final String situacao;
  final String descricao;
  final String ua;
  final int idUl;
  final String localidade;
  final String responsavel;
  String situacaoConferencia;

  Patrimonio({
    required this.patrimonio,
    this.nAntigo = "",
    required this.situacao,
    required this.descricao,
    required this.ua,
    required this.idUl,
    required this.localidade,
    required this.responsavel,
    this.situacaoConferencia = "pendente",
  });

  factory Patrimonio.fromMap(Map<String, dynamic> data) {
    return Patrimonio(
      patrimonio: data['Patrimonio'].toString(),
      nAntigo: data['N_Antigo'].toString(),
      situacao: data['Situacao'],
      descricao: data['Descricao'],
      ua: data['UA'],
      idUl: data['Id_ul'],
      localidade: data['Localidade'],
      responsavel: data['Responsavel'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Patrimonio': patrimonio.toString(),
      'N_Antigo': nAntigo.toString(),
      'Situacao': situacao,
      'Descricao': descricao,
      'UA': ua,
      'Id_ul': idUl,
      'Localidade': localidade,
      'Responsavel': responsavel,
    };
  }

  factory Patrimonio.fromMapConferencia(Map<String, dynamic> data) {
    return Patrimonio(
      patrimonio: data['Patrimonio'].toString(),
      nAntigo: data['N_Antigo'].toString(),
      situacao: data['Situacao'],
      descricao: data['Descricao'],
      ua: data['UA'],
      idUl: data['Id_ul'],
      localidade: data['Localidade'],
      responsavel: data['Responsavel'],
      situacaoConferencia: data['situacaoConferencia'] ?? "pendente",
    );
  }

  Map<String, dynamic> toMapConferencia() {
    return {
      'Patrimonio': patrimonio.toString(),
      'N_Antigo': nAntigo.toString(),
      'Situacao': situacao,
      'Descricao': descricao,
      'UA': ua,
      'Id_ul': idUl,
      'Localidade': localidade,
      'Responsavel': responsavel,
      'situacaoConferencia': situacaoConferencia,
    };
  }
}
