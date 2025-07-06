import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibration/vibration.dart';

class ItemMenuPrincipal extends StatelessWidget {
  const ItemMenuPrincipal({
    this.popOnNavigate = true,
    required this.helpDialog,
    required this.icone,
    required this.acao,
    required this.explicacao,
    required this.destino,
    super.key,
  });

  final void Function(BuildContext) helpDialog;
  final String acao;
  final String explicacao;
  final IconData icone;
  final String destino;
  final bool popOnNavigate;

  @override
  Widget build(BuildContext context) {
    void navigate() {
      if (popOnNavigate) {
        Navigator.of(context).pushReplacementNamed(destino);
      } else {
        Navigator.of(context).pushNamed(destino);
      }
    }

    void showHelp() async {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 50);
      }
      if (context.mounted) {
        helpDialog(context);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        color: Colors.transparent,
        elevation: 5,
        child: ListTile(
          visualDensity: VisualDensity.comfortable,
          tileColor: Theme.of(context).colorScheme.secondary,
          onTap: navigate,
          onLongPress: showHelp,
          title: Text(
            acao,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          horizontalTitleGap: 25,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Icon(icone, size: 35, color: Theme.of(context).primaryColor),
          ),
          subtitle: Text(
            explicacao,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_outlined, size: 40),
        ),
      ),
    ).animate(
      effects: [
        FadeEffect(
          delay: Duration(milliseconds: 100),
          duration: Duration(milliseconds: 200),
        ),
      ],
    );
  }
}
