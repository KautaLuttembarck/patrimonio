import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patrimonio/app/providers/user_provider.dart';
import 'package:clarity_flutter/clarity_flutter.dart';

class AppDrawerHeader extends StatefulWidget {
  AppDrawerHeader({super.key});
  static const String _placeholderImage = "assets/images/empregado_250x250.png";

  @override
  State<AppDrawerHeader> createState() => _AppDrawerHeaderState();
}

class _AppDrawerHeaderState extends State<AppDrawerHeader> {
  late final String _userImage;

  String _nomeFoto(String matricula) {
    return matricula.substring(matricula.length - 7);
  }

  @override
  void initState() {
    super.initState();
    context.read<UserProvider>().matricula;
    _userImage = _nomeFoto("00000${context.read<UserProvider>().matricula}");
  }

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
          child: ClarityUnmask(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              child: ClipOval(
                // Busca o formato JPEG
                child: Image.network(
                  'http://sgradsv.metro.df.gov.br:9666/$_userImage.jpeg',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      'http://sgradsv.metro.df.gov.br:9666/$_userImage.jpg',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Em caso de erro, retorna uma imagem local
                        return Image.asset(
                          AppDrawerHeader._placeholderImage,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ClarityUnmask(
          child: Text(
            context.watch<UserProvider>().nome,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
        ClarityUnmask(
          child: Text(
            context.watch<UserProvider>().matricula,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
      ],
    );
  }
}
