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

  testWidgets('ajoute un article avec son prix et met à jour le total', (tester) async {
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

  testWidgets('retire les articles achetés', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ShoppingListPage()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Oignons');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.remove_done), findsNothing);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.remove_done));
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
