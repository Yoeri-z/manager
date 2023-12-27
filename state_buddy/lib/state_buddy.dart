///every manager should implement a class, a manager manages a state. You can add listerners to a manager and listen for state changes.
///If you are using flutter this is done for you by the ManagerBuilder widget
abstract class Manager<State> {
  Manager(this.state);

  ///the current state of the manager
  State state;

  ///the previous state of the manager
  State? oldState;

  final _listeners = <void Function(State state)>[];

  void addListener(void Function(State state) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(State state) listener) {
    _listeners.remove(listener);
  }

  /// Emit a state to all listeners
  void emit(State emittedState) {
    oldState = state;
    state = emittedState;
    //first emit the state to all listeners
    for (var listener in _listeners) {
      listener(emittedState);
    }
  }
}

/// A lookup table for managers, store managers inside here to ensure they are singletons
class ManagerTable {
  ManagerTable();

  final Map<Type, Manager> managers = {};

  /// Look up a manager for the given state type
  T find<T extends Manager>() {
    final manager = managers[T];
    assert(manager != null, 'No manager found for $T');
    return manager as T;
  }

  /// Add a manager to the table, only one manager can be added for each state type
  void addManager<T extends Manager>(T manager) {
    assert(managers[T] == null, 'Two managers found for $T');

    managers[T] = manager;
  }

  /// Add multiple managers to the table, only one manager can be added for each state type
  void addManagers(Iterable<Manager> managers) {
    managers.forEach(addManager);
  }

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode && other is ManagerTable;
  }

  @override
  int get hashCode {
    //the managers is defined by its length, in an application there should be only one managertable, one manager table can only change in length
    //because managers can not be removed
    return managers.length;
  }
}
