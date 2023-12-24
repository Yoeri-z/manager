import 'package:flutter/material.dart';
import 'package:state_buddy/state_buddy.dart';

///A widget that rebuilds when the state of a manager changes,
///```
///   ManagerBuilder<MyManager, MyState>(builder: (context, state) => Text(state.toString())
///```
///The builder will rebuild whenever the manager changes state, the state can be accessed in the builder function
class ManagerBuilder<M extends Manager<St>, St> extends StatefulWidget {
  const ManagerBuilder({super.key, required this.builder});

  ///The builder function that will be called when the state of the manager changes
  final Widget Function(BuildContext context, St state) builder;

  @override
  State<ManagerBuilder> createState() => _ManagerBuilderState<M, St>();
}

class _ManagerBuilderState<M extends Manager<St>, St>
    extends State<ManagerBuilder<M, St>> {
  //manager will be looked up in the init state
  final M manager = ManagerTable.find<M>();

  //the listener function will be stored here
  late void Function(St state) listener;

  //the state will be stored here
  late St state;

  @override
  void initState() {
    super.initState();
    //get the state from the manager
    state = manager.state;
    //create a listener function that will be called on state update
    listener = (st) => setState(() => state = st);
    //add the listener to the manager
    manager.addListener(listener);
  }

  @override
  void dispose() {
    super.dispose();
    //remove the listener from the manager when the widget is disposed
    manager.removeListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    //call the builder function with the context and the state
    return widget.builder(context, state);
  }
}
