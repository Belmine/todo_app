import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:todo_app/main.dart';
import 'package:todo_app/pages/shopping_list_page.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR', null);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ajoute un article avec son montant et met à jour le total', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ShoppingListPage()));
    await tester.pumpAndSettle();

    expect(find.text('Aucun article dans la liste'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'Tomates');
    await tester.enterText(find.byType(TextField).at(1), '2,50');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Pain');
    await tester.enterText(find.byType(TextField).at(1), '1.2');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Tomates'), findsOneWidget);
    expect(find.text('Pain'), findsOneWidget);
    expect(find.textContaining('2,50'), findsOneWidget);
    expect(find.textContaining('1,20'), findsOneWidget);
    expect(find.textContaining('Total 3,70'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('shopping_items'), contains('Tomates'));
  });

  testWidgets('affiche les montants sans devise ni décimales inutiles', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ShoppingListPage()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Riz');
    await tester.enterText(find.byType(TextField).at(1), '2500');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // fr_FR sépare les milliers par une espace insécable
    expect(find.textContaining(RegExp(r'^2\s500$')), findsOneWidget);
    expect(find.textContaining(RegExp(r'^Total 2\s500$')), findsOneWidget);
    expect(find.textContaining('€'), findsNothing);
  });

  testWidgets('relit les articles enregistrés avec l\'ancien champ de prix', (tester) async {
    SharedPreferences.setMockInitialValues({
      'shopping_items':
          '[{"id":"1","name":"Tomates","estimatedPrice":2.5,"isBought":false,'
          '"createdAt":"2026-10-25T13:30:00.000"}]',
    });

    await tester.pumpWidget(const MaterialApp(home: ShoppingListPage()));
    await tester.pumpAndSettle();

    expect(find.text('Tomates'), findsOneWidget);
    expect(find.textContaining('Total 2,50'), findsOneWidget);
  });

  testWidgets('retire les articles achetés', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ShoppingListPage()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Oignons');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.delete_sweep_outlined), findsNothing);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Oignons'), findsNothing);
    expect(find.text('Aucun article dans la liste'), findsOneWidget);
  });

  testWidgets('la barre du bas bascule entre tâches et courses', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Aucune tâche pour aujourd\'hui'), findsOneWidget);

    await tester.tap(find.text('Courses'));
    await tester.pumpAndSettle();

    expect(find.text('Liste de courses'), findsOneWidget);
  });
}
