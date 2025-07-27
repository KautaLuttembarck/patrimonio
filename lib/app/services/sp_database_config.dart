class SpDatabaseConfig {
  static const String port = "443";
  static const String baseUrl = "spmetrodf.com";
  static const String loginEndPoint = "/agpat/login_webservice.php";
  static const String localizacaoEndPoint = "/agpat/localizacao_webservice.php";
  static const String listaPatrimoniosEndPoint =
      "/agpat/relatorio_webservice.php";
  static const String getListaUa =
      "1"; // Código da consulta para obter a lista de UA
  static const String getListaUl =
      "2"; // Código da consulta para obter a lista de UL
  static const Map<String, String> headersService = {
    'Content-Type': 'application/x-www-form-urlencoded',
  };
}
