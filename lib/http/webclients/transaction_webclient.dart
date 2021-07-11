import 'dart:convert';

import 'package:bytebank2/models/transaction.dart';
import 'package:http/http.dart';

import '../webclient.dart';

class TransactionWebClient {
  Future<List<Transaction>> findAll() async {
    final Response response =
        await client.get(Uri.parse(baseUrl)).timeout(Duration(seconds: 5));
    final List<dynamic> decodedJson = jsonDecode(response.body);
    return decodedJson
        .map((dynamic transactionJson) => Transaction.fromJson(transactionJson))
        .toList();
  }

  Future<Transaction> save(Transaction transaction) async {
    final String transactionJson = jsonEncode(transaction.toJson());
    final Response response = await client.post(Uri.parse(baseUrl),
        headers: {'Content-type': 'application/json', 'password': '1000'},
        body: transactionJson);
    return Transaction.fromJson(jsonDecode(response.body));
  }
}
