import 'package:bloc_todos/edit_todo/view/view.dart';
import 'package:bloc_todos/l10n/l10n.dart';
import 'package:bloc_todos/todos_overview/bloc/todos_overview_bloc.dart';
import 'package:bloc_todos/todos_overview/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todos_repository/todos_repository.dart';

class TodosOverviewScreen extends StatelessWidget {
  const TodosOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => TodosOverviewBloc(
        todosRepository: ctx.read<TodosRepository>(),
      )..add(const TodosOverviewSubscriptionRequested()),
      child: const TodosOverviewView(),
    );
  }
}

class TodosOverviewView extends StatelessWidget {
  const TodosOverviewView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.todosOverviewAppBarTitle),
        actions: const [
          TodosOverviewFilterButton(),
          TodosOverviewOptionsButton(),
          SizedBox(width: 8),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<TodosOverviewBloc, TodosOverviewState>(
            listenWhen: (prev, current) => prev.status != current.status,
            listener: (context, state) {
              if (state.status == TodosOverviewStatus.failure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.fixed,
                      content: Text(l10n.todosOverviewErrorSnackbarText),
                    ),
                  );
              }
            },
          ),
          BlocListener<TodosOverviewBloc, TodosOverviewState>(
            listenWhen: (prev, current) =>
                prev.lastDeletedTodo != current.lastDeletedTodo &&
                current.lastDeletedTodo != null,
            listener: (context, state) {
              final deletedTodo = state.lastDeletedTodo!;
              final messenger = ScaffoldMessenger.of(context);
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.fixed,
                    content: Text(
                      l10n.todosOverviewTodoDeletedSnackBarText(
                        deletedTodo.title,
                      ),
                    ),
                    action: SnackBarAction(
                      label: l10n.todosOverviewUndoDeletionButtonText,
                      onPressed: () {
                        messenger.hideCurrentSnackBar();
                        context
                            .read<TodosOverviewBloc>()
                            .add(const TodosOverviewUndoDeletionRequested());
                      },
                    ),
                  ),
                );
            },
          ),
        ],
        child: BlocBuilder<TodosOverviewBloc, TodosOverviewState>(
          builder: (context, state) {
            if (state.filteredTodos.isEmpty) {
              switch (state.status) {
                case TodosOverviewStatus.initial:
                  return const SizedBox();
                case TodosOverviewStatus.loading:
                  return const CircularProgressIndicator.adaptive();
                case TodosOverviewStatus.failure:
                  return Center(
                    child: Text(
                      l10n.todosOverviewSomethingWentWrongText,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                case TodosOverviewStatus.success:
                  return Center(
                    child: Text(
                      l10n.todosOverviewEmptyText,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
              }
            }
            return ListView.builder(
              itemCount: state.filteredTodos.length,
              itemBuilder: (context, index) {
                final todo = state.filteredTodos[index];
                return TodoListTile(
                  todo: todo,
                  onToggleCompleted: (isCompleted) {
                    context.read<TodosOverviewBloc>().add(
                          TodosOverviewTodoCompletionToggled(
                            todo: todo,
                            isCompleted: isCompleted,
                          ),
                        );
                  },
                  onDismissed: (_) {
                    context
                        .read<TodosOverviewBloc>()
                        .add(TodosOverviewTodoDeleted(todo: todo));
                  },
                  onTap: () {
                    Navigator.of(context).push(
                      EditTodoScreen.route(initialTodo: todo),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
