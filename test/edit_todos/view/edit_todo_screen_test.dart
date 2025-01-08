// ignore_for_file: avoid_redundant_argument_values

import 'package:bloc_test/bloc_test.dart';
import 'package:bloc_todos/edit_todo/bloc/edit_todo_bloc.dart';
import 'package:bloc_todos/edit_todo/view/view.dart';
import 'package:bloc_todos/edit_todo/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:todos_repository/todos_repository.dart';

import '../../helpers/helpers.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

class MockEditTodoBloc extends MockBloc<EditTodoEvent, EditTodoState>
    implements EditTodoBloc {}

void main() {
  final mockTodo = Todo(
    id: '1',
    title: 'title 1',
    description: 'description 1',
  );

  late TodosRepository todosRepository;
  late EditTodoBloc editTodoBloc;
  late MockNavigator navigator;
  setUp(() {
    todosRepository = MockTodoRepository();
    when(() => todosRepository.getTodos()).thenAnswer(
      (_) => const Stream.empty(),
    );

    editTodoBloc = MockEditTodoBloc();
    when(() => editTodoBloc.state).thenReturn(
      EditTodoState(
        status: EditTodoStatus.initial,
        initialTodo: mockTodo,
        title: mockTodo.title,
        description: mockTodo.description,
      ),
    );

    navigator = MockNavigator();
    when(() => navigator.canPop()).thenReturn(false);
    when(() => navigator.push<void>(any())).thenAnswer((_) async {});
  });

  group('EditTodoScreen', () {
    Widget buildSubject() {
      return MockNavigatorProvider(
        navigator: navigator,
        child: BlocProvider.value(
          value: editTodoBloc,
          child: const EditTodoScreen(),
        ),
      );
    }

    group('constructor', () {
      test('works properly', () {
        expect(() => const EditTodoScreen(), returnsNormally);
      });
      test('test buildSubject works properly', () {
        expect(buildSubject, returnsNormally);
      });
    });

    group('route', () {
      testWidgets(
        'renders EditTodoScreen',
        (WidgetTester tester) async {
          await tester.pumpRoute(EditTodoScreen.route());
          expect(find.byType(EditTodoScreen), findsOneWidget);
        },
      );
      testWidgets(
        'supports providing an initial todo',
        (WidgetTester tester) async {
          await tester.pumpRoute(EditTodoScreen.route(initialTodo: mockTodo));
          expect(find.byType(EditTodoScreen), findsOneWidget);
          expect(
            find.byWidgetPredicate(
              (w) => w is EditableText && w.controller.text == mockTodo.title,
            ),
            findsOneWidget,
          );
        },
      );
    });

    testWidgets(
      'renders EditTodoView',
      (WidgetTester tester) async {
        await tester.pumpApp(
          buildSubject(),
          todosRepository: todosRepository,
        );
        expect(find.byType(EditTodoView), findsOneWidget);
      },
    );

    testWidgets(
      'pops when a todo is successfully saved',
      (WidgetTester tester) async {
        whenListen<EditTodoState>(
          editTodoBloc,
          Stream.fromIterable(
            [
              const EditTodoState(),
              const EditTodoState(status: EditTodoStatus.success),
            ],
          ),
        );
        await tester.pumpApp(
          buildSubject(),
          todosRepository: todosRepository,
        );
        verify(
          () => navigator.pop<Object?>(
            any<dynamic>(),
          ),
        );
      },
    );
  });
  group('EditTodoView', () {
    Widget buildSubject() {
      return MockNavigatorProvider(
        navigator: navigator,
        child: BlocProvider.value(
          value: editTodoBloc,
          child: const EditTodoView(),
        ),
      );
    }

    group('constructor', () {
      test('works properly', () {
        expect(() => const EditTodoView(), returnsNormally);
      });
      test('test buildSubject works properly', () {
        expect(buildSubject, returnsNormally);
      });
    });

    group('appBar', () {
      testWidgets(
        'is rendered with title text for new todo '
        'when a new todo is being created',
        (WidgetTester tester) async {
          when(() => editTodoBloc.state).thenReturn(const EditTodoState());
          await tester.pumpApp(buildSubject());
          expect(find.byType(AppBar), findsOneWidget);
          expect(
            find.descendant(
              of: find.byType(AppBar),
              matching: find.text(l10n.editTodoAppBarAddNewTodoTitle),
            ),
            findsOneWidget,
          );
        },
      );
      testWidgets(
        'is rendered with title text for editing a todo '
        'when an existing todo is being editted',
        (WidgetTester tester) async {
          when(() => editTodoBloc.state).thenReturn(
            EditTodoState(
              initialTodo: mockTodo,
              title: mockTodo.title,
              description: mockTodo.description,
            ),
          );
          await tester.pumpApp(buildSubject());
          expect(find.byType(AppBar), findsOneWidget);
          expect(
            find.descendant(
              of: find.byType(AppBar),
              matching: find.text(l10n.editTodoAppBarEditTodoTitle),
            ),
            findsOneWidget,
          );
        },
      );
    });

    group('TitleField', () {
      testWidgets(
        'is rendered',
        (WidgetTester tester) async {
          await tester.pumpApp(
            buildSubject(),
            todosRepository: todosRepository,
          );
          expect(find.byType(TitleField), findsOneWidget);
        },
      );
    });

    group('DescriptionField', () {
      testWidgets(
        'is rendered',
        (WidgetTester tester) async {
          await tester.pumpApp(
            buildSubject(),
            todosRepository: todosRepository,
          );
          expect(find.byType(DescriptionField), findsOneWidget);
        },
      );
    });

    group('save FAB', () {
      testWidgets(
        'is rendered',
        (WidgetTester tester) async {
          await tester.pumpApp(buildSubject());
          expect(find.byType(FloatingActionButton), findsOneWidget);
          expect(
            find.descendant(
              of: find.byType(FloatingActionButton),
              matching: find.byTooltip(l10n.editTodoSaveButtonTooltip),
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'renders correct icon when '
        'title is empty '
        'and status is not loading or success',
        (WidgetTester tester) async {
          when(() => editTodoBloc.state).thenReturn(
            const EditTodoState(
              status: EditTodoStatus.initial,
              title: '',
              description: '',
            ),
          );
          await tester.pumpApp(buildSubject());
          expect(find.byType(FloatingActionButton), findsOneWidget);
          final fabIcon = tester.widget<Icon>(
            find.descendant(
              of: find.byType(FloatingActionButton),
              matching: find.byType(Icon),
            ),
          );
          expect(
            fabIcon,
            isA<Icon>().having((i) => i.icon, 'icon', Icons.lock),
          );
        },
      );

      testWidgets(
        'renders correct icon when '
        'title is not empty '
        'and status is not loading or success',
        (WidgetTester tester) async {
          when(() => editTodoBloc.state).thenReturn(
            const EditTodoState(
              status: EditTodoStatus.initial,
              title: 'title',
              description: '',
            ),
          );
          await tester.pumpApp(buildSubject());
          expect(find.byType(FloatingActionButton), findsOneWidget);
          final fabIcon = tester.widget<Icon>(
            find.descendant(
              of: find.byType(FloatingActionButton),
              matching: find.byType(Icon),
            ),
          );
          expect(
            fabIcon,
            isA<Icon>().having((i) => i.icon, 'icon', Icons.check_rounded),
          );
        },
      );

      testWidgets(
        'renders loading indicator when '
        'status is loading or success (Android)',
        (WidgetTester tester) async {
          // Temporarily overide target platform test
          debugDefaultTargetPlatformOverride = TargetPlatform.android;

          when(() => editTodoBloc.state).thenReturn(
            const EditTodoState(
              status: EditTodoStatus.loading,
              title: 'title',
              description: 'description',
            ),
          );
          await tester.pumpApp(buildSubject());
          expect(find.byType(FloatingActionButton), findsOneWidget);
          expect(
            find.descendant(
              of: find.byType(FloatingActionButton),
              matching: find.byType(CircularProgressIndicator),
            ),
            findsOneWidget,
          );

          // Reset the platform override.
          debugDefaultTargetPlatformOverride = null;
        },
      );

      testWidgets(
        'renders loading indicator when '
        'status is loading or success (iOS)',
        (WidgetTester tester) async {
          // Temporarily overide target platform test
          debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

          when(() => editTodoBloc.state).thenReturn(
            const EditTodoState(
              status: EditTodoStatus.loading,
              title: 'title',
              description: 'description',
            ),
          );
          await tester.pumpApp(buildSubject());
          expect(find.byType(FloatingActionButton), findsOneWidget);
          expect(
            find.descendant(
              of: find.byType(FloatingActionButton),
              matching: find.byType(CupertinoActivityIndicator),
            ),
            findsOneWidget,
          );

          // Reset the platform override.
          debugDefaultTargetPlatformOverride = null;
        },
      );

      testWidgets(
        'adds EditTodoSubmitted '
        'to EditTodoBloc '
        'when tapped',
        (WidgetTester tester) async {
          await tester.pumpApp(buildSubject());
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();
          verify(() => editTodoBloc.add(const EditTodoSubmitted())).called(1);
        },
      );
      testWidgets(
        'does not add EditTodoSubmitted '
        'to EditTodoBloc '
        'when tapped and title is empty',
        (WidgetTester tester) async {
          when(() => editTodoBloc.state).thenReturn(
            const EditTodoState(
              title: '',
              description: 'description',
            ),
          );
          await tester.pumpApp(buildSubject());
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();
          verifyNever(() => editTodoBloc.add(const EditTodoSubmitted()));
        },
      );
    });
  });
}
