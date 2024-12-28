import 'package:bloc_todos/app/app.dart';
import 'package:bloc_todos/home/home.dart';
import 'package:bloc_todos/theme.dart/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todos_repository/todos_repository.dart';

import 'helpers/helpers.dart';

void main() {
  late TodosRepository todosRepository;
  setUp(() {
    todosRepository = MockTodoRepository();
    when(() => todosRepository.getTodos()).thenAnswer(
      (_) => const Stream.empty(),
    );
  });
  group('App', () {
    testWidgets('renders AppView', (tester) async {
      await tester.pumpWidget(
        App(todosRepository: todosRepository),
      );
      expect(find.byType(AppView), findsOneWidget);
    });
    group('AppView', () {
      testWidgets('renderes MaterialApp with correct theme', (tester) async {
        await tester.pumpWidget(
          RepositoryProvider.value(
            value: todosRepository,
            child: const AppView(),
          ),
        );

        expect(find.byType(MaterialApp), findsOneWidget);

        final materialApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp),
        );
        expect(materialApp.theme, equals(AppTheme.light));
        expect(materialApp.darkTheme, equals(AppTheme.dark));
      });
      testWidgets('renders HomeScreen', (tester) async {
        await tester.pumpWidget(
          RepositoryProvider.value(
            value: todosRepository,
            child: const AppView(),
          ),
        );
        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });
  });
}
