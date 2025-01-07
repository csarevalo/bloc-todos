import 'package:bloc_todos/stats/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('TodoCountTile', () {
    const subjectCount = 9;
    const subjectLabelText = 'sample text';
    const subjectIcon = Icons.abc;
    const subjectColor = Colors.pink;

    Widget buildSubject() {
      return const Material(
        child: TodoCountTile(
          count: subjectCount,
          labelText: subjectLabelText,
          icon: subjectIcon,
          iconColor: subjectColor,
        ),
      );
    }

    group('constructor', () {
      test('works properly', () {
        expect(
          () => const TodoCountTile(
            count: subjectCount,
            labelText: subjectLabelText,
            icon: subjectIcon,
          ),
          returnsNormally,
        );
      });
      test('test buildSubject works properly', () {
        expect(buildSubject, returnsNormally);
      });
    });

    testWidgets(
      'renders labelText',
      (WidgetTester tester) async {
        await tester.pumpApp(buildSubject());
        expect(find.text(subjectLabelText), findsOneWidget);
      },
    );

    testWidgets(
      'renders count',
      (WidgetTester tester) async {
        await tester.pumpApp(buildSubject());
        expect(find.text(subjectCount.toString()), findsOneWidget);
      },
    );

    group('icon', () {
      testWidgets(
        'is rendered',
        (WidgetTester tester) async {
          await tester.pumpApp(buildSubject());
          expect(find.byType(Icon), findsOneWidget);
          final icon = tester.widget<Icon>(find.byType(Icon));
          expect(icon.icon, subjectIcon);
        },
      );

      testWidgets(
        'is rendered with correct color',
        (WidgetTester tester) async {
          await tester.pumpApp(buildSubject());
          final icon = tester.widget<Icon>(find.byType(Icon));
          expect(icon.color, subjectColor);
        },
      );
    });
  });
}
