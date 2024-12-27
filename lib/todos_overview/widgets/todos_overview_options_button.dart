import 'package:bloc_todos/l10n/l10n.dart';
import 'package:bloc_todos/todos_overview/bloc/todos_overview_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@visibleForTesting
enum TodosOverviewOption { toggleAll, clearCompleted }

class TodosOverviewOptionsButton extends StatelessWidget {
  const TodosOverviewOptionsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final todos = context.select((TodosOverviewBloc bloc) => bloc.state.todos);
    final completedTodosAmount = todos.where((t) => t.isCompleted).length;
    final hasTodos = todos.isNotEmpty;
    return PopupMenuButton(
      // shape: const ContinuousRectangleBorder(
      //   borderRadius: BorderRadius.all(Radius.circular(16)),
      // ),
      tooltip: l10n.todosOverviewOptionsTooltip,
      icon: const Icon(Icons.more_horiz_rounded),
      onSelected: (TodosOverviewOption option) {
        switch (option) {
          case TodosOverviewOption.toggleAll:
            context
                .read<TodosOverviewBloc>()
                .add(const TodosOverviewToggleAllRequested());
          case TodosOverviewOption.clearCompleted:
            context
                .read<TodosOverviewBloc>()
                .add(const TodosOverviewClearCompletedRequested());
        }
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: TodosOverviewOption.toggleAll,
            enabled: hasTodos,
            child: Text(
              todos.length == completedTodosAmount
                  ? l10n.todosOverviewOptionsMarkAllIncomplete
                  : l10n.todosOverviewOptionsMarkAllComplete,
            ),
          ),
          PopupMenuItem(
            value: TodosOverviewOption.clearCompleted,
            enabled: hasTodos && completedTodosAmount > 0,
            child: Text(l10n.todosOverviewOptionsClearCompleted),
          ),
        ];
      },
    );
  }
}
