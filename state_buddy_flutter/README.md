# manager_flutter

Using this package is very simple, below is an implementation of the counter app

```dart
import 'package:flutter/material.dart';
import 'package:manager/manager.dart';
import 'package:manager_flutter/manager_flutter.dart';


//create a manager for the counter, that state is of value int in this case
class CounterManager extends Manager<int> {
  CounterManager() : super(0);

  ///increment the counter
  void increment() {
    emit(state++);
  }
}

void main(List<String> args) {
  // add the manager to the managertable, all managers should be added to the table before running the app
  ManagerTable.addManager(CounterManager());

  runApp(const CounterApp());
}
//A simple materialapp
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
        onPressed: () =>
            //call the increment function of the manager, we get the manager using the managertable
            ManagerTable.lookUpManager<CounterManager>().increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

that is it

for more in detail documentation see the github