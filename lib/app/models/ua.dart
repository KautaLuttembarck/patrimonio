class Ua {
  final int idUa;
  final String ua;
  final String? sigla;

  Ua({required this.idUa, required this.ua, this.sigla});

  factory Ua.fromJson(Map<String, dynamic> json) {
    return Ua(idUa: json['id_ua'], ua: json['ua'], sigla: json['sigla']);
  }
}
