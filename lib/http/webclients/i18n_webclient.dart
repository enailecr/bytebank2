import 'dart:convert';

import 'package:bytebank2/components/localization.dart';
import 'package:http/http.dart';

import '../webclient.dart';

const MESSAGES_URI =
    "https://gist.githubusercontent.com/enailecr/03d4d94e653137f358885eb85bc50257/raw/1310e03cb52a630352cef0df0611645ab279d7b7/";

class I18NWebClient {
  final String? _viewKey;

  I18NWebClient(this._viewKey);
  Future<Map<String, dynamic>> findAll() async {
    final Response response =
        await client.get(Uri.parse('$MESSAGES_URI$_viewKey.json'));
    final Map<String, dynamic> decodedJson = jsonDecode(response.body);
    return decodedJson;
  }
}
