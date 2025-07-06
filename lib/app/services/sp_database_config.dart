class SpDatabaseConfig {
  static const port = "443";
  static const baseUrl = "spmetrodf.com";
  static const loginEndPoint = "/agpat/login_webservice.php";
  static const localizacaoEndPoint = "/agpat/localizacao_webservice.php";
  static const listaPatrimoniosEndPoint = "/agpat/relatorio_webservice.php";
  static const getListaUa = "1"; // Código da consulta para obter a lista de UA
  static const getListaUl = "2"; // Código da consulta para obter a lista de UL
  static const headersService = {
    'Content-Type': 'application/x-www-form-urlencoded',
  };
}
