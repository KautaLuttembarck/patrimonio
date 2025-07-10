import 'package:flutter/material.dart';
import 'package:clarity_flutter/clarity_flutter.dart';

// Route Observer criado para centralizar o envio do nome das telas ao Clarity
// Evita a necessidade de incluir no initState da página, uma vez que sempre que
// uma rota é acessada, o observer é automáticamente chamado.
class ClarityRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  void _sendScreenName(Route? route) {
    if (route is PageRoute) {
      final screenName = route.settings.name ?? route.runtimeType.toString();
      if (screenName.trim().isNotEmpty) {
        Clarity.setCurrentScreenName(screenName);
      }
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _sendScreenName(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _sendScreenName(newRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _sendScreenName(previousRoute);
  }
}
