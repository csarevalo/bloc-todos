import 'package:bloc_todos/l10n/l10n.dart';
import 'package:bloc_todos/stats/bloc/stats_bloc.dart';
import 'package:bloc_todos/stats/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todos_repository/todos_repository.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StatsBloc(
        todosRepository: context.read<TodosRepository>(),
      )..add(const StatsSubscriptionRequested()),
      child: const StatsView(),
    );
  }
}

class StatsView extends StatelessWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statsAppBarTitle),
      ),
      body: BlocBuilder<StatsBloc, StatsState>(
        builder: (context, state) {
          switch (state.status) {
            case StatsStatus.initial:
            case StatsStatus.loading:
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            case StatsStatus.failure:
              Center(
                child: Text(l10n.statsSomethingWentWrongText),
              );
            case StatsStatus.success:
          }
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                TodoCountTile(
                  labelText: l10n.statsCompletedTodosCountLabel,
                  count: state.completedTodos,
                  icon: Icons.check,
                ),
                TodoCountTile(
                  labelText: l10n.statsActiveTodosCountLabel,
                  count: state.activeTodos,
                  icon: Icons.radio_button_unchecked_rounded,
                  iconColor: Colors.blue,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
