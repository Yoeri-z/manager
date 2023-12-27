import 'package:test/test.dart';
import 'package:state_buddy/state_buddy.dart';

class CounterManager extends Manager<int> {
  CounterManager() : super(0);

  ///increment the counter
  void increment() {
    emit(state + 1);
  }
}

void main() {
  test('adds one to input values', () {
    int listenerval = 0;
    final managerTable = ManagerTable()..addManager(CounterManager());
    final manager = managerTable.find<CounterManager>();
    manager.addListener((state) => listenerval = state);

    manager.increment();
    manager.increment();

    expect(listenerval, 2);
  });
}
