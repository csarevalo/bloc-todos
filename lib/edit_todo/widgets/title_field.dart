import 'package:bloc_todos/edit_todo/bloc/edit_todo_bloc.dart';
import 'package:bloc_todos/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TitleField extends StatelessWidget {
  const TitleField({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status =
        context.select<EditTodoBloc, EditTodoStatus>((b) => b.state.status);
    final title = context.select<EditTodoBloc, String>((b) => b.state.title);
    final hintText =
        context.read<EditTodoBloc>().state.initialTodo?.title ?? '';

    return TextFormField(
      key: const Key('editTodoView_title_textFormField'),
      enabled: !status.isLoadingOrSuccess, //textFormField enabled
      initialValue: title,
      decoration: InputDecoration(
        enabled: !status.isLoadingOrSuccess, //decoration enabled
        labelText: l10n.editTodoTitleLabel,
        hintText: hintText,
      ),
      maxLength: 50,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
      ],
      onChanged: (value) {
        context.read<EditTodoBloc>().add(EditTodoTitleChanged(value));
      },
    );
  }
}
