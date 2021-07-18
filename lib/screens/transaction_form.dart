import 'dart:async';

import 'package:bytebank2/components/container.dart';
import 'package:bytebank2/components/error.dart';
import 'package:bytebank2/components/progress.dart';
import 'package:bytebank2/components/response_dialog.dart';
import 'package:bytebank2/components/transaction_auth_dialog.dart';
import 'package:bytebank2/http/webclients/transaction_webclient.dart';
import 'package:bytebank2/models/contact.dart';
import 'package:bytebank2/models/transaction.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

@immutable
abstract class TransactionFormState {
  const TransactionFormState();
}

@immutable
class SendingState extends TransactionFormState {
  const SendingState();
}

@immutable
class ShowFormState extends TransactionFormState {
  const ShowFormState();
}

@immutable
class SentState extends TransactionFormState {
  const SentState();
}

@immutable
class FatalErrorTransactionFormState extends TransactionFormState {
  final String _message;
  const FatalErrorTransactionFormState(this._message);
}

class TransactionFormCubit extends Cubit<TransactionFormState> {
  TransactionFormCubit() : super(ShowFormState());
  final TransactionWebClient _webClient = TransactionWebClient();

  void save(Transaction transactionCreated, String password,
      BuildContext context) async {
    emit(SendingState());
    await _send(
      transactionCreated,
      password,
      context,
    );

    // await _showSucessfulMessage(context);
  }

  _send(Transaction transactionCreated, String password,
      BuildContext context) async {
    await _webClient
        .save(transactionCreated, password)
        .then((transaction) => emit(SentState()))
        .catchError((err) {
      emit(FatalErrorTransactionFormState('Timeout submiting the transaction'));
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.setCustomKey('exception', err.toString());
        FirebaseCrashlytics.instance
            .setCustomKey('http_body', transactionCreated.toString());
        FirebaseCrashlytics.instance.recordError(err, null);
      }
      // _showFailureMessage(context, err.message);
    }, test: (err) => err is TimeoutException).catchError((err) {
      emit(FatalErrorTransactionFormState(err.message));
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.setCustomKey('exception', err.toString());
        FirebaseCrashlytics.instance.setCustomKey('http_code', err.statusCode);
        FirebaseCrashlytics.instance
            .setCustomKey('http_body', transactionCreated.toString());
        FirebaseCrashlytics.instance.recordError(err, null);
      }
      // _showFailureMessage(context, err.message);
    }, test: (err) => err is HttpException);
    // .catchError((err) {
    //   _showFailureMessage(context);
    // })
  }
}

class TransactionFormContainer extends BlocContainer {
  final Contact _contact;
  TransactionFormContainer(this._contact);
  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionFormCubit>(
      create: (BuildContext context) {
        return TransactionFormCubit();
      },
      child: BlocListener<TransactionFormCubit, TransactionFormState>(
        child: TransactionFormStateless(_contact),
        listener: (context, state) {
          if (state is SentState) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

class TransactionFormStateless extends StatelessWidget {
  final Contact _contact;
  TransactionFormStateless(this._contact);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionFormCubit, TransactionFormState>(
      builder: (context, state) {
        if (state is ShowFormState) {
          return _BasicForm(_contact);
        }
        if (state is SendingState || state is SentState) {
          return ProgressView();
        }
        if (state is FatalErrorTransactionFormState) {
          return ErrorView(state._message);
        }
        return ErrorView('Unknown error');
      },
    );
  }

  Future<void> _showSucessfulMessage(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (contextDialog) {
          return SuccessDialog('Sucessful');
        });
    Navigator.pop(context);
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

class _BasicForm extends StatelessWidget {
  final Contact _contact;
  final TextEditingController _valueController = TextEditingController();
  final String transactionId = Uuid().v4();
  _BasicForm(this._contact);

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
              Text(
                _contact.name,
                style: TextStyle(
                  fontSize: 24.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _contact.accountNumber.toString(),
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
                          Transaction(transactionId, value, _contact);
                      showDialog(
                          context: context,
                          builder: (contextDialog) => TransactionAuthDialog(
                                onConfirm: (String password) {
                                  BlocProvider.of<TransactionFormCubit>(context)
                                      .save(
                                    transactionCreated,
                                    password,
                                    context,
                                  );
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
}
