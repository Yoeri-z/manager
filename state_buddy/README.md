# state budy

as simple state manager

```dart
class CounterManager extends Manager<int>{
    CounterManager():super(0);

    void increment() => emit(state++);
}

void main(){
    //Add the manager to the ManagerTable to make it accesible throughout the entire application
    ManagerTable.addManager(CounterManager());
    //you can find the manager in the table like this
    final manager = ManagerTable.find<CounterManager>();
    //print the state every time it changes
    manager.addListener((state) => print(state));
    //this will print 1
    manager.increment();
    //this will print 2
    manager.increment();
}

```