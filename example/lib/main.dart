import 'package:flutter/material.dart';
import 'package:state_buddy/state_buddy.dart';
import 'package:state_buddy_flutter/state_buddy_flutter.dart';

class CounterManager extends Manager<int> {
  CounterManager() : super(0);

  ///increment the counter
  void increment() {
    emit(state++);
  }
}

void main(List<String> args) {
  ManagerTable.addManager(CounterManager());

  runApp(const CounterApp());
}

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Counter App',
      home: CounterPage(),
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ManagerBuilder<CounterManager, int>(
            builder: (context, state) => Text(state.toString())),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ManagerTable.find<CounterManager>().increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
