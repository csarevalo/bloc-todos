// ignore_for_file: avoid_redundant_argument_values

import 'package:bloc_test/bloc_test.dart';
import 'package:bloc_todos/edit_todo/bloc/edit_todo_bloc.dart';
import 'package:bloc_todos/edit_todo/view/view.dart';
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
  group('EditTodoScreen', () {
    late MockNavigator navigator;
    setUp(() {
      todosRepository = MockTodoRepository();
      when(() => todosRepository.getTodos()).thenAnswer(
        (_) => const Stream.empty(),
      );

      editTodoBloc = MockEditTodoBloc();
      when(() => editTodoBloc.state).thenReturn(EditTodoState(
        status: EditTodoStatus.initial,
        initialTodo: mockTodo,
        title: mockTodo.title,
        description: mockTodo.description,
      ));

      navigator = MockNavigator();
      when(() => navigator.canPop()).thenReturn(false);
      when(() => navigator.push<void>(any())).thenAnswer((_) async {});
    });

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
      "test description",
      (WidgetTester tester) async {},
    );
  });
}
