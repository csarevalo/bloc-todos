import 'package:bloc_test/bloc_test.dart';
import 'package:bloc_todos/home/home.dart';
import 'package:bloc_todos/stats/stats.dart';
import 'package:bloc_todos/todos_overview/todos_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:todos_repository/todos_repository.dart';

import '../../helpers/helpers.dart';

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

void main() {
  late TodosRepository todosRepository;
  group('HomeScreen', () {
    setUp(() {
      todosRepository = MockTodoRepository();
      when(() => todosRepository.getTodos()).thenAnswer(
        (_) => const Stream.empty(),
      );
    });
    testWidgets('renders HomeView', (tester) async {
      await tester.pumpApp(
        const HomeScreen(),
        todosRepository: todosRepository,
      );
      expect(find.byType(HomeView), findsOneWidget);
    });
  });
  group('HomeView', () {
    const addTodoFABKey = Key(
      'homeView_addTodo_floatingActionButton',
    );
    late MockNavigator navigator;
    late HomeCubit homeCubit;
    setUp(() {
      navigator = MockNavigator();
      when(() => navigator.canPop()).thenReturn(false);
      when(() => navigator.push<void>(any())).thenAnswer((_) async {});

      homeCubit = MockHomeCubit();
      when(() => homeCubit.state).thenReturn(const HomeState());

      todosRepository = MockTodoRepository();
      when(() => todosRepository.getTodos()).thenAnswer(
        (_) => const Stream.empty(),
      );
    });

    Widget buildSubject() {
      return MockNavigatorProvider(
        navigator: navigator,
        child: BlocProvider.value(
          value: homeCubit,
          child: const HomeView(),
        ),
      );
    }

    testWidgets(
      'renders TodosOverviewPage'
      ' when tab is set to HomeTab.todos',
      (tester) async {
        when(() => homeCubit.state).thenReturn(const HomeState());
        await tester.pumpApp(
          buildSubject(),
          todosRepository: todosRepository,
        );
        expect(find.byType(TodosOverviewScreen), findsOneWidget);
      },
    );
    testWidgets(
      'renders TodosOverviewPage'
      ' when tab is set to HomeTab.stats',
      (tester) async {
        when(() => homeCubit.state).thenReturn(
          const HomeState(tab: HomeTab.stats),
        );
        await tester.pumpApp(
          buildSubject(),
          todosRepository: todosRepository,
        );
        expect(find.byType(StatsScreen), findsOneWidget);
      },
    );

    testWidgets(
        'calls setTab with HomeTab.todos on HomeCubit '
        'when todos navigation button is pressed', (tester) async {
      await tester.pumpApp(
        buildSubject(),
        todosRepository: todosRepository,
      );
      const selectTodosTabBtnKey = Key('homeView_selectTodosTab_homeTabButton');
      await tester.tap(find.byKey(selectTodosTabBtnKey));
      verify(
        () => homeCubit.setTab(HomeTab.todos),
      ).called(1);
    });
    testWidgets(
        'calls setTab with HomeTab.stats on HomeCubit '
        'when stats navigation button is pressed', (tester) async {
      await tester.pumpApp(
        buildSubject(),
        todosRepository: todosRepository,
      );
      const selectStatsTabBtnKey = Key('homeView_selectStatsTab_homeTabButton');
      await tester.tap(find.byKey(selectStatsTabBtnKey));
      verify(
        () => homeCubit.setTab(HomeTab.stats),
      ).called(1);
    });
    group('add todo floating action button', () {
      testWidgets('is rendered', (tester) async {
        await tester.pumpApp(
          buildSubject(),
          todosRepository: todosRepository,
        );
        expect(
          find.byKey(addTodoFABKey),
          findsOneWidget,
        );
        final addTodoFAB = tester.widget(find.byKey(addTodoFABKey));
        expect(addTodoFAB, isA<FloatingActionButton>());
      });
      testWidgets('renders add icon', (tester) async {
        await tester.pumpApp(
          buildSubject(),
          todosRepository: todosRepository,
        );
        expect(
          find.descendant(
            of: find.byKey(addTodoFABKey),
            matching: find.byIcon(Icons.add),
          ),
          findsOneWidget,
        );
      });
      testWidgets('navigates to EditTodoScreen when pressed', (tester) async {
        await tester.pumpApp(
          buildSubject(),
          todosRepository: todosRepository,
        );

        await tester.tap(find.byKey(addTodoFABKey));
        verify(
          () => navigator.push<void>(any(that: isRoute<void>())),
        ).called(1);
      });
    });
  });
}
