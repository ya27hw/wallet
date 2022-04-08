import 'dart:convert';
import 'package:http/http.dart' as http;

class Ethplorer {
  final String _mainnetApiUrl = "api.ethplorer.io";
  final String _kovanApiUrl = "kovan-api.ethplorer.io";
  final String _key = "EK-eXrJn-MxUq95L-Gyjfs";
  final String ethplorerUrl = "ethplorer.io";

  Future<Map> getFromAPI(String path, String tokenAddress,
      [Map<String, dynamic>? params]) async {
    var response = await http.get(
        Uri.https(_mainnetApiUrl, "/$path/$tokenAddress",
            {"apiKey": _key, ...?params}),
        headers: {"Content-Type": "application/json"});
    var jsonResponse = json.decode(response.body);
    return jsonResponse;
  }
}
