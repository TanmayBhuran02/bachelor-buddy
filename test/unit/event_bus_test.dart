import 'package:flutter_test/flutter_test.dart';
import 'package:bachelor_buddy/core/events/domain_event.dart';

void main() {
  group('EventBus', () {
    test('delivers typed events to registered listeners', () async {
      final bus = EventBus();
      final events = <TodoCompleted>[];

      final sub = bus.on<TodoCompleted>().listen((e) {
        events.add(e);
      });

      bus.fire(TodoCompleted(
        todoId: 'test-1',
        title: 'Complete task',
        actionType: 'create_expense',
      ));

      bus.fire(WaterLogged(amountMl: 250, dailyTotalMl: 500, goalMl: 2500));

      await Future.delayed(const Duration(milliseconds: 50));

      expect(events.length, 1);
      expect(events.first.todoId, 'test-1');
      expect(events.first.title, 'Complete task');

      await sub.cancel();
    });
  });
}
