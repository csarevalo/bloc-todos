import 'package:bloc_test/bloc_test.dart';
import 'package:bloc_todos/stats/bloc/stats_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class MockStatsBloc extends MockBloc<StatsEvent, StatsState>
    implements StatsBloc {}

void main() {
  group('StatsScreen', () {
    late StatsBloc statsBloc;

    setUp(() {
      statsBloc = MockStatsBloc();
    });


  });
}
