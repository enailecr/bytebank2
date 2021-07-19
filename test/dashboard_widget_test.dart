import 'package:bytebank2/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'matchers.dart';

void main() {
  group('When Dashboard is opened', () {
    testWidgets('Should display the main image when the dashboard is opened',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: DashboardContainer()));
      final mainImage = find.byType(Image);
      expect(mainImage, findsOneWidget);
    });

    testWidgets('Should display the transfer feature then Dashboard is opened',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: DashboardContainer(),
      ));
      //   final iconTransferFeatureItem =
      //       find.widgetWithIcon(FeatureItem, Icons.monetization_on);
      //   expect(iconTransferFeatureItem, findsWidgets);
      //   final nameTransferFeatureItem =
      //       find.widgetWithText(FeatureItem, 'Transfer');
      //   expect(nameTransferFeatureItem, findsWidgets);
      final transferFeatureItem = find.byWidgetPredicate((widget) =>
          featureItemMatcher(widget, 'Transfer', Icons.monetization_on));

      expect(transferFeatureItem, findsOneWidget);
    });

    testWidgets(
        'Should display the transaction feed feature then Dashboard is opened',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: DashboardContainer(),
      ));
      final transactionFeedFeatureitem = find.byWidgetPredicate((widget) =>
          featureItemMatcher(widget, 'Transaction Feed', Icons.description));
      expect(transactionFeedFeatureitem, findsOneWidget);
    });
  });
}
