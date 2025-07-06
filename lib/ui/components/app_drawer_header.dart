import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patrimonio/app/providers/user_provider.dart';

class AppDrawerHeader extends StatelessWidget {
  const AppDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage("assets/images/empregado.png"),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          context.watch<UserProvider>().nome,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        Text(
          context.watch<UserProvider>().matricula,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ],
    );
  }
}
