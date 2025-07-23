import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patrimonio/app/providers/user_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clarity_flutter/clarity_flutter.dart';

class AppDrawerHeader extends StatefulWidget {
  const AppDrawerHeader({super.key});
  static const String _placeholderImage = "assets/images/empregado.png";

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
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: ClipOval(
            child: Container(
              width: 84,
              height: 84,
              color: Colors.grey[300],
              child: CachedNetworkImage(
                imageUrl:
                    "http://sgradsv.metro.df.gov.br:9666/$_userImage.jpeg",
                fit: BoxFit.cover,
                placeholder:
                    (_, _) => Stack(
                      children: [
                        Image.asset(AppDrawerHeader._placeholderImage),
                        const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            constraints: BoxConstraints(
                              minHeight: 84,
                              minWidth: 84,
                            ),
                          ),
                        ),
                      ],
                    ),
                errorWidget:
                    (_, _, _) => CachedNetworkImage(
                      imageUrl:
                          "http://sgradsv.metro.df.gov.br:9666/$_userImage.jpg",
                      fit: BoxFit.cover,
                      placeholder:
                          (_, _) => Stack(
                            children: [
                              Image.asset(AppDrawerHeader._placeholderImage),
                              const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 4,
                                  constraints: BoxConstraints(
                                    minHeight: 84,
                                    minWidth: 84,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      errorWidget:
                          (_, _, _) =>
                              Image.asset(AppDrawerHeader._placeholderImage),
                    ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ClarityMask(
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
