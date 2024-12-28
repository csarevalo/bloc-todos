import 'package:bloc_test/bloc_test.dart';
import 'package:bloc_todos/home/home.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeCubit', () {
    HomeCubit buildCubit() => HomeCubit();
    group('constructor', () {
      test('works properly', () {
        expect(buildCubit, returnsNormally);
      });
      test('had correct initial state', () {
        expect(
          buildCubit().state,
          equals(const HomeState()),
        );
      });
    });
    group('setTab', () {
      blocTest<HomeCubit, HomeState>(
        'sets home tab to given value (stats).',
        build: buildCubit,
        act: (bloc) => bloc.setTab(HomeTab.stats),
        expect: () => const <HomeState>[
          HomeState(tab: HomeTab.stats),
        ],
      );
      blocTest<HomeCubit, HomeState>(
        'sets home tab to given value (todos).',
        build: buildCubit,
        seed: () => const HomeState(tab: HomeTab.stats),
        act: (bloc) => bloc.setTab(HomeTab.todos),
        expect: () => const <HomeState>[
          HomeState(),
        ],
      );
    });
  });
}
