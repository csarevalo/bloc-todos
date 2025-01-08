import 'package:bloc_test/bloc_test.dart';
import 'package:bloc_todos/stats/bloc/stats_bloc.dart';
import 'package:bloc_todos/stats/view/view.dart';
import 'package:bloc_todos/stats/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:todos_repository/todos_repository.dart';

import '../../helpers/helpers.dart';

class MockStatsBloc extends MockBloc<StatsEvent, StatsState>
    implements StatsBloc {}

void main() {
  late TodosRepository todosRepository;
  group('StatsScreen', () {
    setUp(() {
      todosRepository = MockTodoRepository();
      when(() => todosRepository.getTodos()).thenAnswer(
        (_) => const Stream.empty(),
      );
    });

    testWidgets('renders StatsView', (tester) async {
      await tester.pumpApp(
        const StatsScreen(),
        todosRepository: todosRepository,
      );
      expect(find.byType(StatsView), findsOneWidget);
    });

    testWidgets('subscribes to todos stream on initialization', (tester) async {
      await tester.pumpApp(
        const StatsScreen(),
        todosRepository: todosRepository,
      );
      verify(() => todosRepository.getTodos()).called(1);
    });
  });
  group('StatsView', () {
    late StatsBloc statsBloc;
    late MockNavigator navigator;

    setUp(() {
      navigator = MockNavigator();
      when(() => navigator.push(any())).thenAnswer((_) async => null);
      when(() => navigator.canPop()).thenReturn(false);

      statsBloc = MockStatsBloc();
      when(() => statsBloc.state).thenReturn(
        const StatsState(status: StatsStatus.success),
      );
    });

    Widget buildSubject() {
      return MockNavigatorProvider(
        navigator: navigator,
        child: BlocProvider.value(
          value: statsBloc,
          child: const StatsView(),
        ),
      );
    }

    testWidgets('renders AppBar with title', (tester) async {
      await tester.pumpApp(buildSubject());
      expect(find.byType(AppBar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(l10n.statsAppBarTitle),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'renders error text '
      'when status is failure',
      (tester) async {
        when(() => statsBloc.state).thenReturn(
          const StatsState(status: StatsStatus.failure),
        );
        await tester.pumpApp(buildSubject());
        expect(
          find.text(l10n.statsSomethingWentWrongText),
          findsOneWidget,
        );
      },
    );
    testWidgets(
      'renders loading indicator '
      'when status is loading (Android)',
      (tester) async {
        // Temporarily overide target platform test
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        when(() => statsBloc.state).thenReturn(
          const StatsState(status: StatsStatus.loading),
        );
        await tester.pumpApp(buildSubject());
        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
        );

        // Reset the platform override.
        debugDefaultTargetPlatformOverride = null;
      },
    );

    testWidgets(
      'renders loading indicator '
      'when status is loading (iOS)',
      (tester) async {
        // Temporarily overide target platform test
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        when(() => statsBloc.state).thenReturn(
          const StatsState(status: StatsStatus.loading),
        );
        await tester.pumpApp(buildSubject());
        expect(
          find.byType(CupertinoActivityIndicator),
          findsOneWidget,
        );

        // Reset the platform override.
        debugDefaultTargetPlatformOverride = null;
      },
    );

    group('TodoCountTile', () {
      const completedTodosCountKey = ValueKey(
        'statsView_TodoCountTile_completedTodos',
      );
      const activeTodosCountKey = ValueKey(
        'statsView_TodoCountTile_activeTodos',
      );
      const completedTodos = 3;
      const activeTodos = 2;

      setUp(() {
        when(() => statsBloc.state).thenReturn(
          const StatsState(
            status: StatsStatus.success,
            completedTodos: completedTodos,
            activeTodos: activeTodos,
          ),
        );
      });

      testWidgets(
        'renders two TodoCountTile (completedTodos, activeTodos) '
        'when status is success',
        (tester) async {
          await tester.pumpApp(buildSubject());
          expect(find.byType(TodoCountTile), findsNWidgets(2));
        },
      );

      testWidgets(
        'renders TodoCountTile for completedTodos '
        'when status is success',
        (tester) async {
          await tester.pumpApp(buildSubject());
          expect(find.byKey(completedTodosCountKey), findsOneWidget);
          final completedTodosCountTile = tester.widget<TodoCountTile>(
            find.byKey(completedTodosCountKey),
          );
          expect(completedTodosCountTile, isA<TodoCountTile>());
        },
      );

      testWidgets(
        'renders correct TodoCountTile '
        'for completedTodos '
        'when status is success',
        (tester) async {
          await tester.pumpApp(buildSubject());
          expect(find.byKey(completedTodosCountKey), findsOneWidget);
          final completedTodosCountTile = tester.widget<TodoCountTile>(
            find.byKey(completedTodosCountKey),
          );
          expect(
            completedTodosCountTile,
            isA<TodoCountTile>()
                .having(
                  (t) => t.labelText,
                  'label text',
                  l10n.statsCompletedTodosCountLabel,
                )
                .having(
                  (t) => t.count,
                  'completed todos count',
                  completedTodos,
                )
                .having((t) => t.icon, 'icon', Icons.check)
                .having((t) => t.iconColor, 'icon color', Colors.green),
          );
        },
      );

      testWidgets(
        'renders TodoCountTile for activeTodos '
        'when status is success',
        (tester) async {
          await tester.pumpApp(buildSubject());
          expect(find.byKey(activeTodosCountKey), findsOneWidget);
          final activeTodosCountTile = tester.widget<TodoCountTile>(
            find.byKey(activeTodosCountKey),
          );
          expect(activeTodosCountTile, isA<TodoCountTile>());
        },
      );

      testWidgets(
        'renders correct TodoCountTile '
        'for activeTodos '
        'when status is success',
        (tester) async {
          await tester.pumpApp(buildSubject());
          expect(find.byKey(activeTodosCountKey), findsOneWidget);
          final activeTodosCountTile = tester.widget<TodoCountTile>(
            find.byKey(activeTodosCountKey),
          );
          expect(
            activeTodosCountTile,
            isA<TodoCountTile>()
                .having(
                  (t) => t.labelText,
                  'label text',
                  l10n.statsActiveTodosCountLabel,
                )
                .having(
                  (t) => t.count,
                  'active todos count',
                  activeTodos,
                )
                .having(
                  (t) => t.icon,
                  'icon',
                  Icons.radio_button_unchecked_rounded,
                )
                .having((t) => t.iconColor, 'icon color', Colors.blue),
          );
        },
      );
    });
  });
}
