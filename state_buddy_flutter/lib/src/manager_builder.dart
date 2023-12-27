import 'package:flutter/material.dart';
import 'package:state_buddy_flutter/src/state_buddy.dart';

/// A widget that builds and manages a specific type of manager.
///
/// The [ManagerBuilder] widget is used to create and manage a specific type of [Manager].
/// It is a [StatefulWidget] that allows for dynamic updates and rebuilding of the manager.
/// The generic type parameters [M] and [St] represent the specific type of manager and its state, respectively.
/// The [builder] function is called whenever the state of the manager changes.
/// The [onlyRebuildOnChange] parameter can be used to specify whether the [builder] function should only be called when the current state is different from the previous state.
///
/// An example of how to use this widget:
/// ```
/// class HelloManager extends Manager<String> {
///  HelloManager() : super('Hello World');
/// }
///
/// class MyApp extends StatelessWidget {
///   const MyApp({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     final managerTable = ManagerTable()..addManager(HelloManager());
///     return ManagerProvider(
///         managerTable: managerTable,
///         child: ManagerBuilder<HelloManager, String>(
///             //whenever state schanges, this builder function will be called
///             builder: (context, state) => Text(state)));
///  }
/// }
/// ```
class ManagerBuilder<M extends Manager<St>, St> extends StatefulWidget {
  const ManagerBuilder(
      {super.key, required this.builder, this.onlyRebuildOnChange = false});

  ///The builder function that will be called when the state of the manager changes
  final Widget Function(BuildContext context, St state) builder;

  ///wether or not the builder should only rebuild if the current state is different from the previous state
  final bool onlyRebuildOnChange;
  @override
  State<ManagerBuilder> createState() => _ManagerBuilderState<M, St>();
}

class _ManagerBuilderState<M extends Manager<St>, St>
    extends State<ManagerBuilder<M, St>> {
  M? manager;
  void Function(St state)? listener;

  @override
  void dispose() {
    super.dispose();
    // Remove the listener when the widget is disposed
    if (listener != null) {
      manager?.removeListener(listener!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the context within the build method
    manager = ManagerProvider.of<M>(context);

    // Add a listener to the manager if there is no listener
    if (listener == null) {
      listener = (state) {
        if (widget.onlyRebuildOnChange && state == manager!.oldState) return;
        setState(() {});
      };
      manager!.addListener(listener!);
    }

    // Call the builder function with the context and the state
    return widget.builder(context, manager!.state);
  }
}

/// An inherited widget that provides access to a manager.
///
/// This widget is used to wrap the widget tree and provide access to a manager
/// instance to all descendant widgets. You can call the static [ManagerProvider.of] method to
/// get the manager instance.
///
/// an example of how to use this widget:
/// ```
/// class HelloManager extends Manager<String> {
///   HelloManager() : super('Hello World');
/// }
///
/// class MyApp extends StatelessWidget {
///   const MyApp({super.key});
///   @override
///   Widget build(BuildContext context) {
///     final managerTable = ManagerTable()..addManager(HelloManager());
///     return ManagerProvider(
///        managerTable: managerTable,
///        child: Builder(
///            builder: (context) =>
///                Text(ManagerProvider.of<HelloManager>(context).state)));
///  }
///}
/// ```
class ManagerProvider extends InheritedWidget {
  const ManagerProvider({
    Key? key,
    required this.managerTable,
    required Widget child,
  }) : super(key: key, child: child);

  /// The manager table that contains all the managers,
  /// this is used internally by the [ManagerProvider.of] method
  final ManagerTable managerTable;

  /// Retrieves the instance of the specified Manager type from the ancestor [ManagerProvider] widget
  /// that should be at the top of your widget tree.
  ///
  /// The [BuildContext] parameter is used to locate the nearest [ManagerProvider] widget in the widget tree.
  /// The type parameter [T] should be a subclass of [Manager] to ensure type safety.
  /// Returns the instance of the specified Manager type if found, otherwise returns null.
  ///
  /// You can also call [getManager] on the [BuildContext] to get the manager.
  /// ```
  /// class Example extends StatelessWidget {
  ///   const Example({super.key});
  ///   @override
  ///   Widget build(BuildContext context) {
  ///    //these two are the same
  ///    final manager = context.getManager<HelloManager>();
  ///    final alsoManager = ManagerProvider.of<HelloManager>(context);
  ///    return Text(manager.state);
  ///  }
  ///}
  ///```
  static T of<T extends Manager>(BuildContext context) {
    final manager =
        context.dependOnInheritedWidgetOfExactType<ManagerProvider>();

    assert(manager != null,
        'No manager provider found in the widget tree, did you forget to add a ManagerProvider?');

    return manager!.managerTable.managers[T] as T;
  }

  @override
  bool updateShouldNotify(ManagerProvider oldWidget) {
    return oldWidget.managerTable != managerTable;
  }
}

/// An extension on the [BuildContext] class that adds a method to get a manager.
extension ManagerContext on BuildContext {
  /// Retrieves the instance of the specified Manager type from the ancestor [ManagerProvider] widget
  T getManager<T extends Manager>() => ManagerProvider.of<T>(this);
}
