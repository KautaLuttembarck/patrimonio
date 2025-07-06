import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:patrimonio/app/services/local_database_service.dart';
import 'package:patrimonio/app/app.dart';
import 'package:patrimonio/app/providers/conferencia_provider.dart';
import 'package:clarity_flutter/clarity_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurações do Microsoft Clarity
  final config = ClarityConfig(
    projectId: "s9burb1bmp",
    // Note: Use "LogLevel.Verbose" value while testing to debug initialization issues.
    logLevel: LogLevel.None,
  );

  // Devolve a barra de notificação para o iOS
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
  );

  // Define a orientação
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Inicializa o banco de dados local
  final localDatabaseService = LocalDatabaseService();
  await localDatabaseService.init();

  // Inicializa o provider de conferência
  final conferenciaProvider = ConferenciaProvider(localDatabaseService);
  await conferenciaProvider.carregarItens();

  runApp(
    ClarityWidget(
      app: App(
        localDatabaseService: localDatabaseService,
        conferenciaProvider: conferenciaProvider,
      ),
      clarityConfig: config,
    ),
  );
}
