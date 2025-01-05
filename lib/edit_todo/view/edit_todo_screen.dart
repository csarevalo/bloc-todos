import 'package:bloc_todos/edit_todo/bloc/edit_todo_bloc.dart';
import 'package:bloc_todos/edit_todo/widgets/widgets.dart';
import 'package:bloc_todos/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todos_repository/todos_repository.dart';

class EditTodoScreen extends StatelessWidget {
  const EditTodoScreen({super.key});

  static Route<void> route({Todo? initialTodo}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) {
        return BlocProvider(
          create: (_) => EditTodoBloc(
            todoRepository: context.read<TodosRepository>(),
            initialTodo: initialTodo,
          ),
          child: const EditTodoScreen(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditTodoBloc, EditTodoState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == EditTodoStatus.success,
      listener: (context, state) => Navigator.of(context).pop(),
      child: const EditTodoView(),
    );
  }
}

class EditTodoView extends StatelessWidget {
  const EditTodoView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = context.select((EditTodoBloc bloc) => bloc.state.status);
    final isNewTodo = context.select(
      (EditTodoBloc bloc) => bloc.state.isNewTodo,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewTodo
              ? l10n.editTodoAppBarAddNewTodoTitle
              : l10n.editTodoAppBarEditTodoTitle,
        ),
      ),
      floatingActionButton: BlocBuilder<EditTodoBloc, EditTodoState>(
        buildWhen: (previous, current) =>
            previous.title.isEmpty != current.title.isEmpty,
        builder: (context, state) {
          final isTitleEmpty = state.title.isEmpty;
          return FloatingActionButton(
            onPressed: isTitleEmpty
                ? null //disable FAB when title is empty
                : () =>
                    context.read<EditTodoBloc>().add(const EditTodoSubmitted()),
            child: status.isLoadingOrSuccess
                ? const CircularProgressIndicator.adaptive()
                : isTitleEmpty
                    ? const Icon(Icons.lock) //edit_off
                    : const Icon(Icons.check_rounded),
          );
        },
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TitleField(),
              DescriptionField(),
            ],
          ),
        ),
      ),
    );
  }
}
