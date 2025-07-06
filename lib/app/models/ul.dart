class Ul {
  final int idUl;
  final String endereco;
  final String matriResp;
  final String nomeResp;

  Ul({
    required this.idUl,
    required this.endereco,
    required this.matriResp,
    required this.nomeResp,
  });

  factory Ul.fromJson(Map<String, dynamic> json) {
    return Ul(
      idUl: json['id_ul'],
      endereco: json['Endereco'],
      matriResp: json['Matri_resp'].toString(),
      nomeResp: json['Nome_resp'],
    );
  }
}
