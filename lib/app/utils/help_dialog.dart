import 'package:flutter/material.dart';

void showLoginHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          icon: Icon(Icons.help, size: 42),
          iconColor: Theme.of(context).primaryColor,
          title: Text('Realizando login no aplicativo'),
          content: Text(
            "Para ter o acesso permitido no aplicativo, "
            "deve ser utilizada a sua matrícula e a senha "
            "do Sistema Patrimonial - SPMETRODF.",
            textAlign: TextAlign.justify,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Fechar"),
            ),
          ],
        ),
  );
}

void showConferenciaHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          icon: Icon(Icons.help, size: 42),
          iconColor: Theme.of(context).primaryColor,
          title: Text('Realizando a Conferência Patrimonial'),
          content: Text(
            "Esta função permite a leitura/digitação da "
            "plaqueta patrimonial com envio dos dados "
            "ao SPMETRODF. Os dados lidos serão "
            "associados à unidade selecionada, gerando "
            "assim um registro de conferência "
            "patrimonial.",
            textAlign: TextAlign.justify,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Fechar"),
            ),
          ],
        ),
  );
}

void showContinuarConferenciaHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          icon: Icon(Icons.help, size: 42),
          iconColor: Theme.of(context).primaryColor,
          title: Text('Continuando a Conferência Patrimonial'),
          content: Text(
            "Esta função permite continuar a conferência patrimonial "
            "iniciada anteriormente.\n\n "
            "Caso queira iniciar uma NOVA conferência, é necessário, primeiro, "
            "finalizar a conferência atual ou cancelar a conferência em andamento "
            "na página de configurações.",
            textAlign: TextAlign.justify,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Fechar"),
            ),
          ],
        ),
  );
}

void showCustomHelpDialog(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          icon: Icon(Icons.help, size: 42),
          iconColor: Theme.of(context).primaryColor,
          title: Text(title),
          content: Text(content, textAlign: TextAlign.justify),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Fechar"),
            ),
          ],
        ),
  );
}

void showSettingsHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          icon: Icon(Icons.help, size: 42),
          iconColor: Theme.of(context).primaryColor,
          title: Text('Configurações'),
          content: Text(
            "Área reservada para:\n\n"
            "☑️ Atualizar os dados de patrimônio registrados no na memória do celular;\n"
            "☑️ Cancelar conferência patrimonial em andamento;\n"
            "☑️ Limpar os dados de patrimônio registrados no celular;\n\n"
            "O download antecipado é necessário para poder realizar a "
            "conferência patrimonial!",
            textAlign: TextAlign.justify,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Fechar"),
            ),
          ],
        ),
  );
}
