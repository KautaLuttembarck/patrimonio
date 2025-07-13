import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:patrimonio/ui/themes/app_theme.dart';
import 'package:patrimonio/app/navigation/app_routes.dart';
import 'package:patrimonio/app/services/local_database_service.dart';
import 'package:patrimonio/ui/pages/auth_page.dart';
import 'package:patrimonio/ui/pages/splash_screen.dart';
import 'package:patrimonio/ui/pages/conferencia_page.dart';
import 'package:patrimonio/ui/pages/configuracoes_page.dart';
import 'package:patrimonio/ui/pages/seleciona_unidade_page.dart';
import 'package:patrimonio/ui/pages/initial_menu_page.dart';
import 'package:patrimonio/app/providers/conferencia_provider.dart';
import 'package:patrimonio/app/providers/user_provider.dart';

class App extends StatelessWidget {
  final LocalDatabaseService localDatabaseService;
  final ConferenciaProvider conferenciaProvider;
  final NavigatorObserver clarityObserver;

  const App({
    super.key,
    required this.localDatabaseService,
    required this.conferenciaProvider,
    required this.clarityObserver,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        Provider<LocalDatabaseService>.value(value: localDatabaseService),
        ChangeNotifierProvider<ConferenciaProvider>.value(
          value: conferenciaProvider,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Conferência Patrimonial',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        locale: Locale('pt', 'BR'), // define o idioma padrão

        supportedLocales: const [
          Locale('pt', 'BR'),
          Locale('en', 'US'), // se quiser fallback
        ],

        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // navigatorObserver criado para passar o nome das rotas ao Clarity
        navigatorObservers: [clarityObserver],
        routes: {
          AppRoutes.splashScreen: (ctx) => SplashScreen(),
          AppRoutes.authPage: (ctx) => AuthPage(),
          AppRoutes.menuInicial: (ctx) => InitialMenuPage(),
          AppRoutes.selecionaUlPage: (ctx) => SelecionaUnidadePage(),
          AppRoutes.conferenciaPage: (ctx) => ConferenciaPage(),
          AppRoutes.configuracoesPage: (ctx) => ConfiguracoesPage(),
        },
      ),
    );
  }
}
