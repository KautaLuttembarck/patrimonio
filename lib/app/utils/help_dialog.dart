import 'package:flutter/material.dart';

import 'package:patrimonio/app/models/patrimonio.dart';

void showLoginHelpDialog(BuildContext context) {
  showHelpDialog(
    context,
    title: 'Realizando login no aplicativo',
    content: Text(
      "Para ter o acesso permitido no aplicativo, "
      "deve ser utilizada a sua matrícula e a senha "
      "do Sistema Patrimonial - SPMETRODF.",
      textAlign: TextAlign.justify,
    ),
  );
}

void showConferenciaHelpDialog(BuildContext context) {
  showHelpDialog(
    context,
    title: 'Realizando a Conferência Patrimonial',
    content: Text(
      "Esta função permite a leitura/digitação da "
      "plaqueta patrimonial com envio dos dados "
      "ao SPMETRODF. Os dados lidos serão "
      "associados à unidade selecionada, gerando "
      "assim um registro de conferência "
      "patrimonial.",
      textAlign: TextAlign.justify,
    ),
  );
}

void showContinuarConferenciaHelpDialog(BuildContext context) {
  showHelpDialog(
    context,
    title: 'Continuando a Conferência Patrimonial',
    content: Text(
      "Esta função permite continuar a conferência patrimonial "
      "iniciada anteriormente.\n\n "
      "Caso queira iniciar uma NOVA conferência, é necessário, primeiro, "
      "finalizar a conferência atual ou cancelar a conferência em andamento "
      "na página de configurações.",
      textAlign: TextAlign.justify,
    ),
  );
}

void showSettingsHelpDialog(BuildContext context) {
  showHelpDialog(
    context,
    title: 'Configurações',
    content: Text(
      "Área reservada para:\n\n"
      "☑️ Atualizar os dados de patrimônio registrados no na memória do celular;\n"
      "☑️ Cancelar conferência patrimonial em andamento;\n"
      "☑️ Limpar os dados de patrimônio registrados no celular;\n\n"
      "O download antecipado é necessário para poder realizar a "
      "conferência patrimonial!",
      textAlign: TextAlign.justify,
    ),
  );
}

void showDetalhesPatrimonio(BuildContext context, Patrimonio patrimonio) {
  showHelpDialog(
    context,
    headerIcon: Icons.search,
    title: 'Informações do patrimônio',
    content: RichText(
      text: TextSpan(
        text: "\n",
        style: Theme.of(context).textTheme.bodySmall,
        children: [
          TextSpan(
            text: "Unidade Administrativa: ",
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: "${patrimonio.ua}\n"),

          TextSpan(
            text: "Localização: ",
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: "${patrimonio.localidade}\n\n"),

          TextSpan(
            text: "Responsável: ",
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: "${patrimonio.responsavel}\n\n"),

          TextSpan(
            text: "Decrição: ",
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: "${patrimonio.descricao}\n\n"),

          TextSpan(
            text: "Situação: ",
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                patrimonio.situacaoConferencia == "conferido"
                    ? "Patrimônio conferido"
                    : "Conferência pendente",
          ),
        ],
      ),
    ),
  );
}

void showHelpDialog(
  BuildContext context, {
  required final String title,
  required final Widget content,
  final IconData headerIcon = Icons.help,
  final String buttonText = "Voltar",
}) {
  showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          icon: Icon(headerIcon, size: 42),
          iconColor: Theme.of(context).primaryColor,
          title: Text(title),
          content: content,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(buttonText),
            ),
          ],
        ),
  );
}
