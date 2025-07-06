import 'package:flutter/material.dart';
import 'package:patrimonio/ui/components/form_login.dart';
import 'package:patrimonio/app/utils/help_dialog.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Login"),
          actions: [
            IconButton(
              onPressed: () => showLoginHelpDialog(context),
              icon: Icon(Icons.help),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: FormLogin(),
            ),
          ),
        ),
      ),
    );
  }
}
