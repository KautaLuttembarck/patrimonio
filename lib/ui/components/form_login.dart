import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:patrimonio/app/services/sp_database_service.dart';
import 'package:patrimonio/app/navigation/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:patrimonio/app/providers/user_provider.dart';
import 'package:clarity_flutter/clarity_flutter.dart';

class FormLogin extends StatefulWidget {
  const FormLogin({super.key});

  @override
  State<FormLogin> createState() => _FormLoginState();
}

class _FormLoginState extends State<FormLogin> {
  final _formKey = GlobalKey<FormState>();

  final _matriculaController = TextEditingController();

  final _senhaController = TextEditingController();

  final _senhaFocus = FocusNode();

  bool obscureText = true;
  bool isLoading = false;

  void toggleObscureText() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  Future<void> submitLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      var res = await SpDatabaseService().login(
        _matriculaController.text,
        _senhaController.text,
      );

      var loginStatus = jsonDecode(res);
      if (loginStatus['login_result']) {
        Clarity.setCustomUserId(loginStatus['usuario']['matricula']);
        Clarity.setOnSessionStartedCallback((_) {
          Clarity.setCustomTag(
            'Usuário Logado',
            loginStatus['usuario']['matricula'],
          );
          Clarity.setCustomTag(
            'Grupo de Permissão',
            loginStatus['usuario']['permissao'],
          );
        });
        setState(() => isLoading = false);
        if (mounted) {
          context.read<UserProvider>().registraLogin(
            userData: loginStatus['usuario'],
          );
          Navigator.of(context).pushReplacementNamed(AppRoutes.menuInicial);
        }
      } else {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loginStatus['Erro']),
              backgroundColor: Theme.of(context).colorScheme.error,
              showCloseIcon: true,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        Clarity.sendCustomEvent(
          loginStatus['Erro'],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(25),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            spacing: 30,
            children: [
              SizedBox(),

              Image.asset(
                MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? "assets/images/logo_metro_horizontal_invertido_600x209.png"
                    : 'assets/images/logo_metro_horizontal.png',
                width: 220,
              ),
              SizedBox(),
              TextFormField(
                controller: _matriculaController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  labelText: 'Matrícula',
                  suffixIcon: Icon(Icons.numbers_sharp),
                ),
                keyboardType: TextInputType.text,
                onChanged: (matriculaInformada) {
                  String limpa = matriculaInformada.replaceAll(
                    RegExp(r'[^0-9Xx]'),
                    '',
                  );
                  _matriculaController.value = TextEditingValue(
                    text: limpa.toUpperCase(),
                    selection: TextSelection.collapsed(offset: limpa.length),
                  );
                },
                textCapitalization: TextCapitalization.characters,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_senhaFocus);
                },
                validator: (matriculaInformada) {
                  String matricula = matriculaInformada ?? "";
                  if (matricula.isEmpty) {
                    return "Preencha sua matrícula!";
                  }
                  return null;
                },
              ),

              TextFormField(
                focusNode: _senhaFocus,
                controller: _senhaController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  labelText: 'Senha',
                  suffixIcon: IconButton(
                    onPressed: toggleObscureText,
                    icon:
                        obscureText
                            ? Icon(Icons.visibility)
                            : Icon(Icons.visibility_off),
                  ),
                ),
                obscureText: obscureText,
                keyboardType: TextInputType.text,
                validator: (senhaInformada) {
                  String senha = senhaInformada ?? "";
                  if (senha.isEmpty) {
                    return "Informe sua senha!";
                  }
                  return null;
                },
                onFieldSubmitted: (_) => submitLogin(),
              ),

              TextButton.icon(
                label:
                    isLoading
                        ? SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                        : Text("Entrar"),
                icon: isLoading ? null : Icon(Icons.login),
                onPressed: isLoading ? null : submitLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
