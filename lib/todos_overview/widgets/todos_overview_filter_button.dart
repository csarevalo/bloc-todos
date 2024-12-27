import 'package:bloc_todos/l10n/l10n.dart';
import 'package:bloc_todos/todos_overview/bloc/todos_overview_bloc.dart';
import 'package:bloc_todos/todos_overview/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TodosOverviewFilterButton extends StatelessWidget {
  const TodosOverviewFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final activeFilter = context.select<TodosOverviewBloc, TodosViewFilter>(
      (bloc) => bloc.state.filter,
    );
    return PopupMenuButton(
      // shape: const ContinuousRectangleBorder(
      //   borderRadius: BorderRadius.all(Radius.circular(16)),
      // ),
      tooltip: l10n.todosOverviewFilterTooltip,
      icon: const Icon(Icons.filter_list_rounded),
      initialValue: activeFilter,
      onSelected: (TodosViewFilter filter) => context
          .read<TodosOverviewBloc>()
          .add(TodosOverviewFilterChanged(filter: filter)),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: TodosViewFilter.all,
            child: Text(l10n.todosOverviewFilterAllText),
          ),
          PopupMenuItem(
            value: TodosViewFilter.activeOnly,
            child: Text(l10n.todosOverviewFilterActiveOnlyText),
          ),
          PopupMenuItem(
            value: TodosViewFilter.completedOnly,
            child: Text(l10n.todosOverviewFilterCompletedOnlyText),
          ),
        ];
      },
    );
  }
}
