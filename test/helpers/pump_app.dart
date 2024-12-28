import 'package:bloc_todos/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todos_repository/todos_repository.dart';

class MockTodoRepository extends Mock implements TodosRepository {}

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    TodosRepository? todosRepository,
  }) {
    return pumpWidget(
      RepositoryProvider.value(
        value: todosRepository ?? MockTodoRepository(),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // home: Scaffold(body: widget),
          home: widget,
        ),
      ),
    );
  }

  Future<void> pumpRoute(
    Route<dynamic> route, {
    TodosRepository? todosRepository,
  }) {
    return pumpApp(
      Navigator(onGenerateRoute: (_) => route),
      todosRepository: todosRepository,
    );
  }
}
