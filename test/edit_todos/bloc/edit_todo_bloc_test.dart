// ignore_for_file: avoid_redundant_argument_values

import 'package:bloc_test/bloc_test.dart';
import 'package:bloc_todos/edit_todo/bloc/edit_todo_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todos_repository/todos_repository.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

class FakeTodo extends Fake implements Todo {}

void main() {
  final mockInitialTodo = Todo(
    id: '1',
    title: 'title 1',
    description: 'description 1',
  );
  group('EditTodoBloc', () {
    late TodosRepository todosRepository;

    setUpAll(() {
      registerFallbackValue(FakeTodo());
    });

    setUp(() {
      todosRepository = MockTodosRepository();
      when(() => todosRepository.getTodos()).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => todosRepository.saveTodo(any())).thenAnswer((_) async {});
    });

    EditTodoBloc buildBloc({Todo? initialTodo}) {
      return EditTodoBloc(
        todoRepository: todosRepository,
        initialTodo: initialTodo,
      );
    }

    group('constructor', () {
      test('works properly', () {
        expect(buildBloc, returnsNormally);
        expect(() => buildBloc(initialTodo: mockInitialTodo), returnsNormally);
      });
      test('has correct initial state', () {
        expect(
          buildBloc().state,
          const EditTodoState(),
        );
      });
    });

    group('EditTodoTitleChanged', () {
      blocTest<EditTodoBloc, EditTodoState>(
        'emits state with updated title '
        'when EditTodoTitleChanged is added.',
        build: buildBloc,
        act: (bloc) => bloc.add(const EditTodoTitleChanged('title')),
        expect: () => const <EditTodoState>[
          EditTodoState(title: 'title'),
        ],
      );
    });

    group('EditTodoDescriptionChanged', () {
      blocTest<EditTodoBloc, EditTodoState>(
        'emits state with updated description '
        'when EditTodoDescriptionChanged is added.',
        build: buildBloc,
        act: (bloc) => bloc.add(
          const EditTodoDescriptionChanged('description'),
        ),
        expect: () => const <EditTodoState>[
          EditTodoState(description: 'description'),
        ],
      );
    });

    group('EditTodoSubmitted', () {
      late EditTodoState initialStateForSubmission;
      setUp(() {
        initialStateForSubmission = EditTodoState(
          status: EditTodoStatus.initial,
          title: mockInitialTodo.title,
          description: mockInitialTodo.description,
        );
      });
      blocTest<EditTodoBloc, EditTodoState>(
        'attempts to save new todo using repository '
        'if no initial todo is provided',
        setUp: () => when(() => todosRepository.saveTodo(any())).thenAnswer(
          (_) async {},
        ),
        build: buildBloc,
        seed: () => initialStateForSubmission,
        act: (bloc) => bloc.add(const EditTodoSubmitted()),
        expect: () => <EditTodoState>[
          initialStateForSubmission.copyWith(
            status: EditTodoStatus.loading,
            title: mockInitialTodo.title,
            description: mockInitialTodo.description,
          ),
          initialStateForSubmission.copyWith(
            status: EditTodoStatus.success,
            title: mockInitialTodo.title,
            description: mockInitialTodo.description,
          ),
        ],
        verify: (bloc) => verify(
          () => todosRepository.saveTodo(
            any(
              that: isA<Todo>()
                  .having(
                    (t) => t.title,
                    'title',
                    equals(mockInitialTodo.title),
                  )
                  .having(
                    (t) => t.description,
                    'description',
                    equals(mockInitialTodo.description),
                  ),
            ),
          ),
        ).called(1),
      );

      blocTest<EditTodoBloc, EditTodoState>(
        'attempts to save updated todo using repository '
        'if an initial todo is provided',
        setUp: () => when(() => todosRepository.saveTodo(any())).thenAnswer(
          (_) async {},
        ),
        build: buildBloc,
        seed: () => initialStateForSubmission.copyWith(
          initialTodo: mockInitialTodo,
          title: 'new title',
          description: 'new description',
        ),
        act: (bloc) => bloc.add(const EditTodoSubmitted()),
        expect: () => <EditTodoState>[
          initialStateForSubmission.copyWith(
            status: EditTodoStatus.loading,
            title: 'new title',
            description: 'new description',
            initialTodo: mockInitialTodo,
          ),
          initialStateForSubmission.copyWith(
            status: EditTodoStatus.success,
            title: 'new title',
            description: 'new description',
            initialTodo: mockInitialTodo,
          ),
        ],
        verify: (bloc) => verify(
          () => todosRepository.saveTodo(
            any(
              that: isA<Todo>()
                  .having((t) => t.id, 'id', equals(mockInitialTodo.id))
                  .having(
                    (t) => t.title,
                    'title',
                    equals('new title'),
                  )
                  .having(
                    (t) => t.description,
                    'description',
                    equals('new description'),
                  )
                  .having(
                    (t) => t.isCompleted,
                    'isCompleted',
                    equals(mockInitialTodo.isCompleted),
                  ),
            ),
          ),
        ).called(1),
      );

      blocTest<EditTodoBloc, EditTodoState>(
        'emits new state with error '
        'if failed to save to todos repository',
        setUp: () => when(() => todosRepository.saveTodo(any())).thenThrow(
          Exception('oops'),
        ),
        build: buildBloc,
        seed: () => initialStateForSubmission,
        act: (bloc) => bloc.add(const EditTodoSubmitted()),
        expect: () => <EditTodoState>[
          initialStateForSubmission.copyWith(
            status: EditTodoStatus.loading,
            title: mockInitialTodo.title,
            description: mockInitialTodo.description,
          ),
          initialStateForSubmission.copyWith(
            status: EditTodoStatus.failure,
            title: mockInitialTodo.title,
            description: mockInitialTodo.description,
          ),
        ],
      );
    });
  });
}
