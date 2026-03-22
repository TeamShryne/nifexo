import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nifexo/app/app.dart';

void main() {
  testWidgets('alpha shell renders core navigation', (tester) async {
    await tester.pumpWidget(const NifexoApp());

    expect(find.text('Nifexo Alpha'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Notes'), findsWidgets);
    expect(find.text('Todos'), findsWidgets);
    expect(find.text('Search'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('can create a note from the notes screen', (tester) async {
    await tester.pumpWidget(const NifexoApp());

    await tester.tap(find.text('Notes').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('No notes yet'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('note_title_field')),
      'First note',
    );
    await tester.enterText(
      find.byKey(const ValueKey('note_content_field')),
      '# Hello',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('First note'), findsOneWidget);
    expect(find.textContaining('# Hello'), findsOneWidget);
  });

  testWidgets('existing note opens in read mode and can be edited', (
    tester,
  ) async {
    await tester.pumpWidget(const NifexoApp());

    await tester.tap(find.text('Notes').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('note_title_field')),
      'Plan',
    );
    await tester.enterText(
      find.byKey(const ValueKey('note_content_field')),
      'Initial text',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Plan'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Initial text'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('note_content_field')),
      'Updated text',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Updated text'), findsOneWidget);
  });

  testWidgets('tags can be edited from the note header modal', (tester) async {
    await tester.pumpWidget(const NifexoApp());

    await tester.tap(find.text('Notes').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('note_title_field')),
      'Tagged note',
    );
    await tester.tap(find.byIcon(Icons.sell_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('note_tags_modal_field')),
      'work, ideas',
    );
    await tester.tap(find.text('Apply tags'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('work'), findsOneWidget);
    expect(find.text('ideas'), findsOneWidget);
  });

  testWidgets('settings can toggle dark mode', (tester) async {
    await tester.pumpWidget(const NifexoApp());

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();

    expect(find.text('Dark mode'), findsOneWidget);

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.light);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    final updatedMaterialApp = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );
    expect(updatedMaterialApp.themeMode, ThemeMode.dark);
  });
}
