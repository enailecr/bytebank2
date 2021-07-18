import 'dart:async';

import 'package:bytebank2/components/progress.dart';
import 'package:bytebank2/components/response_dialog.dart';
import 'package:bytebank2/components/transaction_auth_dialog.dart';
import 'package:bytebank2/http/webclients/transaction_webclient.dart';
import 'package:bytebank2/models/contact.dart';
import 'package:bytebank2/models/transaction.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TransactionForm extends StatefulWidget {
  final Contact contact;

  TransactionForm(this.contact);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final TextEditingController _valueController = TextEditingController();
  final TransactionWebClient _webClient = TransactionWebClient();
  final String transactionId = Uuid().v4();

  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New transaction'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Visibility(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Progress(
                    message: 'Sending...',
                  ),
                ),
                visible: _sending,
              ),
              Text(
                widget.contact.name,
                style: TextStyle(
                  fontSize: 24.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  widget.contact.accountNumber.toString(),
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextField(
                  controller: _valueController,
                  style: TextStyle(fontSize: 24.0),
                  decoration: InputDecoration(labelText: 'Value'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton(
                    child: Text('Transfer'),
                    onPressed: () {
                      final double? value =
                          double.tryParse(_valueController.text);
                      final transactionCreated =
                          Transaction(transactionId, value, widget.contact);
                      showDialog(
                          context: context,
                          builder: (contextDialog) => TransactionAuthDialog(
                                onConfirm: (String password) {
                                  _save(transactionCreated, password, context);
                                },
                              ));
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _save(
    Transaction transactionCreated,
    String password,
    BuildContext context,
  ) async {
    await _send(
      transactionCreated,
      password,
      context,
    );

    await _showSucessfulMessage(context);
  }

  Future<void> _showSucessfulMessage(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (contextDialog) {
          return SuccessDialog('Sucessful');
        });
    Navigator.pop(context);
  }

  Future<void> _send(Transaction transactionCreated, String password,
      BuildContext context) async {
    setState(() {
      _sending = true;
    });
    await _webClient.save(transactionCreated, password).catchError((err) {
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.setCustomKey('exception', err.toString());
        FirebaseCrashlytics.instance
            .setCustomKey('http_body', transactionCreated.toString());
        FirebaseCrashlytics.instance.recordError(err, null);
      }
      _showFailureMessage(context, err.message);
    }, test: (err) => err is TimeoutException).catchError((err) {
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.setCustomKey('exception', err.toString());
        FirebaseCrashlytics.instance.setCustomKey('http_code', err.statusCode);
        FirebaseCrashlytics.instance
            .setCustomKey('http_body', transactionCreated.toString());
        FirebaseCrashlytics.instance.recordError(err, null);
      }
      _showFailureMessage(context, err.message);
    }, test: (err) => err is HttpException).whenComplete(() => setState(() {
              _sending = false;
            }))
        // .catchError((err) {
        //   _showFailureMessage(context);
        // })
        ;
  }

  void _showFailureMessage(BuildContext context,
      [String message = 'Unknown error']) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // showDialog(
    //     context: context,
    //     builder: (_) => NetworkGiffyDialog(
    //           image: Image.asset('images/ERROR.gif'),
    //           title: Text('OPSS',
    //               textAlign: TextAlign.center,
    //               style:
    //                   TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
    //           description: Text(
    //             message,
    //             textAlign: TextAlign.center,
    //           ),
    //           entryAnimation: EntryAnimation.TOP,
    //           onOkButtonPressed: () {},
    //         ));

    // showDialog(
    //     context: context, builder: (contextDialog) => FailureDialog(message));
  }
}
