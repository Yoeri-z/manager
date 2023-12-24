///every manager should implement a class, a manager manages a state. You can add listerners to a manager and listen for state changes.
///If you are using flutter this is done for you by the ManagerBuilder widget
abstract class Manager<State> {
  Manager(this.state);

  State state;

  final _listeners = <void Function(State state)>[];

  void addListener(void Function(State state) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(State state) listener) {
    _listeners.remove(listener);
  }

  /// Emit a state to all listeners
  void emit(State emittedState) {
    state = emittedState;
    for (var listener in _listeners) {
      listener(emittedState);
    }
  }
}

/// A lookup table for managers, store managers inside here to ensure they are singletons
class ManagerTable {
  ManagerTable._();

  final Map<Type, Manager> managers = {};

  static final _instance = ManagerTable._();

  /// Look up a manager for the given state type
  static T find<T extends Manager>() {
    final manager = _instance.managers[T];
    assert(manager != null, 'No manager found for $T');
    return manager as T;
  }

  /// Add a manager to the table, only one manager can be added for each state type
  static void addManager<T extends Manager>(T manager) {
    assert(_instance.managers[T] == null, 'Two managers found for $T');

    _instance.managers[T] = manager;
  }

  /// Add multiple managers to the table, only one manager can be added for each state type
  static void addManagers(Iterable<Manager> managers) {
    managers.forEach(addManager);
  }
}
