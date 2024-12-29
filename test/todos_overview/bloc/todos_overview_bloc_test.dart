import 'package:bloc_test/bloc_test.dart';
import 'package:bloc_todos/todos_overview/bloc/todos_overview_bloc.dart';
import 'package:bloc_todos/todos_overview/models/todos_view_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todos_repository/todos_repository.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

class FakeTodo extends Fake implements Todo {}

void main() {
  final mockTodos = [
    Todo(
      id: '1',
      title: 'title 1',
      description: 'description 1',
    ),
    Todo(
      id: '2',
      title: 'title 2',
      description: 'description 2',
    ),
    Todo(
      id: '3',
      title: 'title 3',
      description: 'description 3',
      isCompleted: true,
    ),
  ];
  group('TodosOverviewBloc', () {
    late TodosRepository todosRepository;

    setUpAll(() {
      registerFallbackValue(FakeTodo());
    });

    setUp(() {
      todosRepository = MockTodosRepository();
      when(() => todosRepository.getTodos()).thenAnswer(
        (_) => Stream.value(mockTodos),
      );
      when(() => todosRepository.saveTodo(any())).thenAnswer((_) async {});
    });

    TodosOverviewBloc buildBloc() {
      return TodosOverviewBloc(todosRepository: todosRepository);
    }

    group('constructor', () {
      test('works properly', () {
        expect(buildBloc, returnsNormally);
      });
      test('has correct initial state', () {
        expect(
          buildBloc().state,
          equals(const TodosOverviewState()),
        );
      });
    });
    group('TodosOverviewSubscriptionRequested', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'start listening to repository getTodos stream',
        build: buildBloc,
        act: (bloc) => bloc.add(const TodosOverviewSubscriptionRequested()),
        verify: (_) {
          verify(() => todosRepository.getTodos()).called(1);
        },
      );
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'emits state with updated status and todos '
        'when repository getTodos stream emits new todos',
        build: buildBloc,
        act: (bloc) => bloc.add(const TodosOverviewSubscriptionRequested()),
        expect: () => <TodosOverviewState>[
          const TodosOverviewState(
            status: TodosOverviewStatus.loading,
          ),
          TodosOverviewState(
            status: TodosOverviewStatus.success,
            todos: mockTodos,
          ),
        ],
      );
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'emits state with a failure status '
        'when respository getTodos stream emits error',
        setUp: () {
          when(() => todosRepository.getTodos()).thenAnswer(
            (_) => Stream.error(Exception('oops')),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const TodosOverviewSubscriptionRequested()),
        expect: () => const <TodosOverviewState>[
          TodosOverviewState(
            status: TodosOverviewStatus.loading,
          ),
          TodosOverviewState(
            status: TodosOverviewStatus.failure,
          ),
        ],
      );
    });
    group('TodosOverviewTodoCompletionToggled', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'saves todo using repository '
        'with isCompleted set to event isCompleted flag',
        seed: () => TodosOverviewState(
          status: TodosOverviewStatus.success,
          todos: mockTodos,
        ),
        build: buildBloc,
        act: (bloc) => bloc.add(
          TodosOverviewTodoCompletionToggled(
            todo: mockTodos[0],
            isCompleted: !mockTodos[0].isCompleted,
          ),
        ),
        verify: (_) {
          verify(() => todosRepository.saveTodo(any())).called(1);
        },
        //DOESN'T WORK BECASUSE REPO.SAVETODO() IS STUBBED
        // expect: () => <TodosOverviewState>[
        //   TodosOverviewState(
        //     status: TodosOverviewStatus.success,
        //     todos: [
        //       mockTodos[0].copyWith(
        //         isCompleted: !mockTodos[0].isCompleted,
        //       ),
        //       ...mockTodos.sublist(1),
        //     ],
        //   ),
        // ],
      );
    });
    group('TodosOverviewTodoDeleted', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'deletes todo using repository',
        setUp: () {
          when(
            () => todosRepository.deleteTodo(any()),
          ).thenAnswer((_) async {});
        },
        build: buildBloc,
        seed: () => TodosOverviewState(
          status: TodosOverviewStatus.success,
          todos: mockTodos,
        ),
        act: (bloc) => bloc.add(
          TodosOverviewTodoDeleted(todo: mockTodos.first),
        ),
        verify: (bloc) {
          verify(
            () => todosRepository.deleteTodo(mockTodos.first.id),
          ).called(1);
        },
      );
    });
    group('TodosOverviewUndoDeletionRequested', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'restores last deleted todo and clears lastDeletedTodo field',
        build: buildBloc,
        seed: () => TodosOverviewState(
          status: TodosOverviewStatus.success,
          todos: mockTodos,
          lastDeletedTodo: mockTodos.first,
        ),
        act: (bloc) => bloc.add(const TodosOverviewUndoDeletionRequested()),
        verify: (_) {
          verify(() => todosRepository.saveTodo(mockTodos.first)).called(1);
        },
      );
    });
    group('TodosOverviewFilterChanged', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'emits state with updated filter',
        build: buildBloc,
        seed: () => TodosOverviewState(
          status: TodosOverviewStatus.success,
          todos: mockTodos,
        ),
        act: (bloc) => bloc.add(
          const TodosOverviewFilterChanged(
            filter: TodosViewFilter.completedOnly,
          ),
        ),
        expect: () => <TodosOverviewState>[
          TodosOverviewState(
            status: TodosOverviewStatus.success,
            todos: mockTodos,
            filter: TodosViewFilter.completedOnly,
          ),
        ],
      );
    });
    group('TodosOverviewToggleAllRequested', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'toggles all todos to completed '
        'when some or all todos are uncompleted',
        setUp: () {
          when(
            () => todosRepository.completeAll(
              isCompleted: any(named: 'isCompleted'),
            ),
          ).thenAnswer((_) async => 0);
        },
        build: buildBloc,
        seed: () => TodosOverviewState(
          status: TodosOverviewStatus.success,
          todos: mockTodos,
        ),
        act: (bloc) => bloc.add(const TodosOverviewToggleAllRequested()),
        verify: (bloc) {
          verify(
            () => todosRepository.completeAll(isCompleted: true),
          ).called(1);
        },
      );
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'toggles all todos to uncompleted '
        'when all are completed',
        setUp: () {
          when(
            () => todosRepository.completeAll(
              isCompleted: any(named: 'isCompleted'),
            ),
          ).thenAnswer((_) async => 0);
        },
        build: buildBloc,
        seed: () => TodosOverviewState(
          status: TodosOverviewStatus.success,
          todos: mockTodos
              .map((todo) => todo.copyWith(isCompleted: true))
              .toList(),
        ),
        act: (bloc) => bloc.add(const TodosOverviewToggleAllRequested()),
        verify: (bloc) {
          verify(
            () => todosRepository.completeAll(isCompleted: false),
          ).called(1);
        },
      );
    });
    group('TodosOverviewClearCompletedRequested', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'clears completed todos using repository',
        setUp: () {
          when(
            () => todosRepository.clearCompleted(),
          ).thenAnswer((_) async => 0);
        },
        build: buildBloc,
        seed: () => TodosOverviewState(
          status: TodosOverviewStatus.success,
          todos: mockTodos,
        ),
        act: (bloc) => bloc.add(const TodosOverviewClearCompletedRequested()),
        verify: (bloc) {
          verify(() => todosRepository.clearCompleted()).called(1);
        },
      );
    });
  });
}
