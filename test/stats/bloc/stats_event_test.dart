import 'package:bloc_todos/stats/bloc/stats_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatsEvent', () {
    group('StatsSubscriptionRequested', () {
      test('supports value equality', () {
        expect(
          const StatsSubscriptionRequested(),
          equals(const StatsSubscriptionRequested()),
        );
      });

      test('props are correct', () {
        expect(
          const StatsSubscriptionRequested().props,
          equals(<Object?>[]),
        );
      });
    });
  });
}
