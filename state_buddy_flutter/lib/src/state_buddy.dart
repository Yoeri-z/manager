import 'dart:async';

///every manager should implement a class, a manager manages a state. You can add listerners to a manager and listen for state changes.
///If you are using flutter this is done for you by the ManagerBuilder widget
class Manager<State> {
  Manager(this.state);

  ///the current state of the manager
  State state;

  ///the previous state of the manager
  State? oldState;

  final _listeners = <void Function(State state)>[];
  Middleware<State>? _middleware;

  /// Adds a listener to the manager.
  ///
  /// The [listener] function will be called whenever the state changes.
  /// The [listener] function should accept a single parameter of type [State].
  void addListener(void Function(State state) listener) {
    _listeners.add(listener);
  }

  /// Removes the specified listener from the manager.
  ///
  /// The [listener] is a callback function that will be invoked whenever the state changes.
  /// After calling this method, the [listener] will no longer be notified of state changes.
  void removeListener(void Function(State state) listener) {
    _listeners.remove(listener);
  }

  ///add middleware to the state, middleware can acces and modify state before it is emitted.
  ///below is an example of a logger middleware
  ///```dart
  ///addMiddleware((state) {
  ///   print(state);
  ///   return state;
  /// });
  /// ```
  /// You can also use async middleware, for example to log the state to a database
  /// ```dart
  ///   addMiddleware((state) async {
  ///   await database.log(state);
  ///   return state;
  /// });
  /// ```
  ///
  /// typically you would set middleware in the constructor of the manager
  set setMiddleware(Middleware<State> middleware) {
    _middleware = middleware;
  }

  /// Emit a state to all listeners
  void emit(State emittedState) async {
    oldState = state;
    //apply all middlewares to a temporary state
    var modifiedState = emittedState;
    if (_middleware != null) {
      modifiedState = await _middleware!(emittedState);
    }
    //set the state to the modified state
    state = modifiedState;
    //emit the state to all listeners
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
    int total = 0;
    for (var manager in managers.values) {
      total += manager.hashCode;
    }
    return total;
  }
}

/// A class representing middleware for managing state in State Buddy.
/// Middleware can be used to modify or read state before it is emitted.
/// For example, you can use middleware to log state changes.
///```dart
///Middleware<State>((state) {
///   print(state);
///   return state;
/// });
/// ```
/// You can also use async middleware, for example to log the state to a database
/// ```dart
/// Middleware<State>((state) async {
///   await database.log(state);
///   return state;
/// });
/// ```
///
///you can chain middleware together to create a pipeline
///```
///final pipeline = Middleware<int>((state) {
///  //read state
///  print(state);
///  return state;
///})
///  ..chain(Middleware((state) {
///    //modify state
///    return state ~/ 2;
///  }))
///  ..chain(Middleware((state) async {
///    //you can add async functions
///    await Future.delayed(Duration(seconds: 1));
///    return state;
///  }));
///
///final manager = MyManager(baseState);
///
///manager.addMiddleware(pipeline);
///```
class Middleware<State> {
  Middleware(this._middleware);

  final FutureOr<State> Function(State state) _middleware;

  Middleware<State>? _next;

  ///chain this middleware to another middleware
  ///the chained middleware will be called after this middleware
  void chain(Middleware<State> next) {
    _next = next;
  }

  ///call the middleware
  ///this will call the middleware and all chained middleware that comes after it returning the final state
  FutureOr<State> call(State state) async {
    final modifiedState = await _middleware(state);
    if (_next != null) {
      return _next!(modifiedState);
    }
    return modifiedState;
  }
}
