import 'package:bloc_todos/edit_todo/bloc/edit_todo_bloc.dart';
import 'package:bloc_todos/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DescriptionField extends StatelessWidget {
  const DescriptionField({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status =
        context.select<EditTodoBloc, EditTodoStatus>((b) => b.state.status);
    final description =
        context.select<EditTodoBloc, String>((b) => b.state.description);
    final hintText =
        context.read<EditTodoBloc>().state.initialTodo?.description ?? '';

    return TextFormField(
      key: const Key('editTodoView_description_textFormField'),
      enabled: !status.isLoadingOrSuccess, //textFormField enabled
      initialValue: description,
      decoration: InputDecoration(
        enabled: !status.isLoadingOrSuccess, //decoration enabled
        labelText: l10n.editTodoDescriptionLabel,
        hintText: hintText,
      ),
      maxLength: 300,
      maxLines: 7,
      inputFormatters: [
        LengthLimitingTextInputFormatter(300),
      ],
      onChanged: (value) {
        context.read<EditTodoBloc>().add(EditTodoDescriptionChanged(value));
      },
    );
  }
}
