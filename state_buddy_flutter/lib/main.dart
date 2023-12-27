import 'package:flutter/material.dart';
import 'package:state_buddy_flutter/state_buddy_flutter.dart';

//create a manager for the counter, the state is an int in this case
class CounterManager extends Manager<int> {
  CounterManager() : super(0);

  ///increment the counter
  void increment() {
    emit(state + 1);
  }
}

void main(List<String> args) {
  //create a manager table and add the counter manager to it
  final managerTable = ManagerTable()..addManager(CounterManager());

  //wrap the app in a manager provider to provide the manager table to the widget tree
  runApp(
      ManagerProvider(managerTable: managerTable, child: const CounterApp()));
}

//this should be familiar to you, if it is not i suggest you read the flutter docs
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

//the counter page
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        //A ManagerBuilder listens to state changes in the counter manager, and passes the state to the builder function
        child: ManagerBuilder<CounterManager, int>(
            builder: (context, state) => Text(state.toString())),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //call the increment function of the manager, we get the manager using the managertable
          ManagerProvider.of<CounterManager>(context).increment();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

void test() {
  final middleware = Middleware<int>((state) {
    print(state);
    return state;
  });
}
