import 'dart:math';

import 'package:bytebank2/models/contact.dart';
import 'package:bytebank2/models/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Should return the value when create a transaction', () {
    final transaction = Transaction('', 200, Contact(1, '', null));
    expect(transaction.value, 200);
  });
  test('Shoul show error when create transaction with null value ', () {
    expect(() => Transaction('', null, Contact(1, '', null)),
        throwsAssertionError);
  });
}
