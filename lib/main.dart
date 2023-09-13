// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:simple_todo/todo.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'objectbox.g.dart'; // created by `flutter pub run build_runner build`

class ObjectBox {
  /// The Store of this app.
  late final Store store;

  ObjectBox._create(this.store) {
    // Add any additional setup code, e.g. build queries.
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store =
        await openStore(directory: p.join(docsDir.path, "obx-example"));
    return ObjectBox._create(store);
  }
}

late ObjectBox objectbox;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  objectbox = await ObjectBox.create();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Todo> todos = [];
  final TextEditingController _controller = TextEditingController();

  void markTodo(Todo todo) {
    List<Todo> newTodos = List.from(todos);
    final newTodo = todo.copyWith(isDone: !todo.isDone);
    newTodos[todos.indexOf(todo)] = newTodo;
    todoBox.put(newTodo, mode: PutMode.update);
    setState(() {
      // _counter++;
      todos = newTodos;
      //todoBox.
    });
  }

  late Box<Todo> todoBox;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    todoBox = objectbox.store.box<Todo>();

    if (!todoBox.isEmpty()) {
      todos = todoBox.getAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            Container(
              color: const Color(0xFF5C0493),
              height: size.height * 0.5,
              width: size.width,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 56.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      top: size.height * 0.12,
                    ),
                    child: Text(
                      'TODOS',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 16.0),
                      child: Visibility(
                        visible: todos
                            .where((element) => !element.isDone)
                            .isNotEmpty,
                        replacement: Center(
                            child: Text(
                          'No todos'.toUpperCase(),
                        )),
                        child: ListView.builder(
                          itemCount: todos.where((todo) => !todo.isDone).length,
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(bottom: 90, top: 16),
                          itemBuilder: (context, index) {
                            final todo = todos
                                .where((todo) => !todo.isDone)
                                .toList()[index];
                            return ListTile(
                                title: Text(
                                  todo.title,
                                ),
                                onTap: () {
                                  markTodo(todo);
                                },
                                leading: Checkbox(
                                  value: todo.isDone,
                                  onChanged: (bool? value) {
                                    markTodo(todo);
                                  },
                                ),
                                trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                    ),
                                    onPressed: () {
                                      todoBox.remove(todo.id);

                                      setState(() {
                                        todos.remove(todo);
                                      });
                                    })).animate().fadeIn().scale();
                          },
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Completed'.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Expanded(
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 16.0),
                      child: Visibility(
                        visible:
                            todos.where((element) => element.isDone).isNotEmpty,
                        replacement: Center(
                            child: Text(
                          'No completed todos'.toUpperCase(),
                        )),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(bottom: 90, top: 16),
                          itemCount: todos.where((todo) => todo.isDone).length,
                          itemBuilder: (context, index) {
                            final todo = todos
                                .where((todo) => todo.isDone)
                                .toList()[index];
                            return ListTile(
                              title: Text(
                                todo.title,
                              ),
                              onTap: () {
                                markTodo(todo);
                              },
                              leading: Checkbox(
                                value: todo.isDone,
                                onChanged: (bool? value) {
                                  markTodo(todo);
                                },
                              ),
                              trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                  ),
                                  onPressed: () {
                                    todoBox.remove(todo.id);

                                    setState(() {
                                      todos.remove(todo);
                                    });
                                  }),
                            ).animate().fadeIn().scale();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                      title: const Text('New todo'),
                      content: TextField(
                        autofocus: true,
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Enter new todo',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            _controller.clear();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            final todo = Todo(title: _controller.text);
                            todoBox.put(todo, mode: PutMode.put);

                            setState(() {
                              todos.add(todo);
                              _controller.clear();
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text('Add'),
                        )
                      ]);
                });
          },
          label: const Text('New todo'),
          icon: const Icon(Icons.add)),
    );
  }
}
