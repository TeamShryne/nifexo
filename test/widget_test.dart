import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nifexo/app/app.dart';
import 'package:nifexo/features/notes/markdown/markdown_inline_parser.dart';
import 'mock_repositories.dart';

void main() {
  late MockRepositoryContainer mockRepositories;

  setUp(() {
    mockRepositories = MockRepositoryContainer();
  });

  test('inline parser supports *italic* and **bold**', () {
    const parser = MarkdownInlineParser();
    final nodes = parser.parse('Use *italic* and **bold** text');

    expect(nodes.any((node) => node.text == 'italic' && node.isItalic), isTrue);
    expect(nodes.any((node) => node.text == 'bold' && node.isBold), isTrue);
  });

  test('inline parser handles list marker and bold content', () {
    const parser = MarkdownInlineParser();
    final nodes = parser.parse('* **Bold**');

    expect(nodes.any((node) => node.text == 'Bold' && node.isBold), isTrue);
  });

  testWidgets('alpha shell renders core navigation', (tester) async {
    await tester.pumpWidget(NifexoApp(repositories: mockRepositories));
    await tester.pumpAndSettle();

    expect(find.text('Nifexo Alpha'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Notes'), findsWidgets);
    expect(find.text('Todos'), findsWidgets);
    expect(find.text('Search'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('can create a note from the notes screen', (tester) async {
    await tester.pumpWidget(NifexoApp(repositories: mockRepositories));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Notes').last);
    await tester.pumpAndSettle();

    // Check if the welcome note is visible
    expect(find.textContaining('Welcome to Nifexo!'), findsOneWidget);

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
    await tester.pumpWidget(NifexoApp(repositories: mockRepositories));
    await tester.pumpAndSettle();

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
    await tester.pumpWidget(NifexoApp(repositories: mockRepositories));
    await tester.pumpAndSettle();

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
    await tester.pumpWidget(NifexoApp(repositories: mockRepositories));
    await tester.pumpAndSettle();

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

  testWidgets('preview and read mode handle markdown safely', (tester) async {
    await tester.pumpWidget(NifexoApp(repositories: mockRepositories));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Notes').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('note_title_field')),
      'Markdown note',
    );
    await tester.enterText(
      find.byKey(const ValueKey('note_content_field')),
      'This has *italic* and **bold** and a lone pipe |\n',
    );

    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Markdown note'), findsOneWidget);

    await tester.tap(find.text('Markdown note'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('preview and read render star lists with emphasis', (tester) async {
    await tester.pumpWidget(NifexoApp(repositories: mockRepositories));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Notes').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('note_title_field')),
      'Showcase note',
    );
    await tester.enterText(
      find.byKey(const ValueKey('note_content_field')),
      '* *Italic*\n* **Bold**\n* ***Bold + Italic***',
    );

    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Showcase note'), findsOneWidget);

    await tester.tap(find.text('Showcase note'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
