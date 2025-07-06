import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  int idUsuario;
  String nome;
  String matricula;
  String permissao;

  UserProvider({
    this.idUsuario = 0,
    this.nome = "",
    this.matricula = "",
    this.permissao = "CONSULTA",
  });

  void registraLogin({required Map<String, dynamic> userData}) {
    idUsuario = userData['id_usuario'];
    nome = userData['nome'];
    matricula = userData['matricula'];
    permissao = userData['permissao'];
    notifyListeners();
  }

  void registraLogout() {
    idUsuario = 0;
    nome = "";
    matricula = "";
    permissao = "CONSULTA";
    notifyListeners();
  }
}
