# state_buddy

state buddy will be your buddy in state management. It is easy to pick up, the source code is minimal but yet flexible.
Preformance tests still need to be preformed but I am pretty confident in saying that is is perfomant to. So lets dive into it

## Managers
The core concept of the state_buddy relies around managers. Managers can help you manager the state of your app. Managers work both in flutter application and regular applications. There are some flutter widgets to help integrating the manager in you application, they are documented after the core manager package since i think it is important to first understand how the basics work.

To create a manager, extend the manager class

### the manager
```dart
//create a manager, this managers manages an integer which is the counter
class CounterManager extends Manager<int> {
  //the initial state of the counter is 0
  CounterManager() : super(0);
}
```
This manager manages the value of a counter.
If we want to increment the counter, we need to change the state of the counter.
We can change state by calling the emit function
```dart
class CounterManager extends Manager<int> {
  CounterManager() : super(0);

  ///increment the counter
  void increment() {
    emit(state + 1);
  }
}
```
the emit function changes the state and notifies all components listening to this counter

### listeners
In order for other parts of your program to know that the state of the manager has changed.
We can add listeners.
A listener is a function that is executed every time the state changes.
```dart
final counterManager = CounterManager();
final listener = (state) => print(state);
counterManager.addListener(listener);
```
This will print the state every time the value of the counter changes.
we can also remove the listener
```dart
counterManager.removeListener(listener);
```
### middleware
If you want to modify or read state, before it is emitted to listeners you can add middleware.
middleware will be executed on the state before it is emitted. You can create middleware as follows
```dart
  final middleware = Middleware<int>((state) {
    print(state);
    return state;
  });
```
You can also use async middleware, for example to log the state to a database
```dart
Middleware<State>((state) async {
  await database.log(state);
  return state;
});
```
You can also chain middleware together to create a pipeline of sorts.
```dart
final pipeline = Middleware<int>((state) {
  //read state
  print(state);
  return state;
})
  ..chain(Middleware((state) {
    //modify state
    return state ~/ 2;
  }))
  ..chain(Middleware((state) async {
    //you can add async functions
    await Future.delayed(Duration(seconds: 1));
    return state;
  }));

final manager = MyManager(baseState);

manager.addMiddleware(pipeline);
```
you can use the addMiddleware method of the manager to add your middleware to the manager

### the manager table
in application using managers, the managertable acts as a central storage to store and find managers troughout your entire application

you can add managers to the table
```dart
//create a managertable
final managerTable = ManagerTable()
// Create your manager
final myManager = MyManager();

// Add the manager to the table
managerTable.addManager(myManager);
```

after adding managers to the table you can find them using the type of your manager
```dart
final myManager = managerTable.find<MyManager>();
```
Although it is not strictly nessecary to use the table manager. It is good practice to do so, since it ensures that there is only one instance of each manager.

## the manager in flutter
There are some widgets that can help integrating the manager into your flutter application

### Manager provider
the manager provider is a widget that internally uses the managertable and makes it available to all other widgets in the widget tree.
Usually you would add the provider to the top of your widget tree, and you should only have one provider in the entire tree.

The provider takes a managertable and child widget to be created.

```dart
void main(List<String> args) {
  //create a manager table and add your manager to it
  final managerTable = ManagerTable()..addManager(MyManager);

  //wrap the app in a manager provider to provide the manager table to the widget tree
  runApp(
      ManagerProvider(managerTable: managerTable, child: const CounterApp()));
}
```

you can get your managers from your provider like so:
```dart
//call this in a place where you have acces to the build context
ManagerProvider.of<CounterManager>(context).increment();
```
### ManagerBuilder

The manager builder is used to listen to a managerfor changes and rebuild whenever a change happens. 
```
class HelloManager extends Manager<String> {
   HelloManager() : super('Hello World');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final managerTable = ManagerTable()..addManager(HelloManager());
    return ManagerProvider(
        managerTable: managerTable,
        child: ManagerBuilder<HelloManager, String>(
            //whenever state schanges, this builder function will be called
            builder: (context, state) => Text(state)));
 }
}
```

## Contributing
Feel free to contribute by opening issues or submitting pull requests. Bug reports, feature requests, and improvements are welcome.
