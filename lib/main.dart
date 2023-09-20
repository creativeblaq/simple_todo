// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:simple_todo/todo.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'objectbox.g.dart'; // created by `flutter pub run build_runner build`

class ObjectBox {
  late final Store store;

  ObjectBox._create(this.store);

  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();

    final store = await openStore(directory: p.join(docsDir.path, "todo"));
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
      home: const Home2(),
    );
  }
}

class Home2 extends StatefulWidget {
  const Home2({super.key});

  @override
  State<Home2> createState() => _Home2State();
}

class _Home2State extends State<Home2> {
  CarouselController carouselController = CarouselController();
  List<Todo> todos = [];

  List<Todo> doneTodos = [];

  markTodoAsDone(Todo todo) {
    // Check if the todo is already marked as done

    int index = todos.indexOf(todo);

    if (index !=
        -1 /* todos.where((element) => element == todo).isNotEmpty */) {
      //Create a new todo based on the old one
      final newTodo = todo.copyWith(isDone: true);

      //This is to update the todo in the database
      todoBox.put(newTodo, mode: PutMode.update);

      //Set the state to update the UI
      setState(() {
        //Add the new todo to the list of done todos
        doneTodos.add(newTodo);

        //Remove the old todo from the list of not done todos
        todos.remove(todo);
      });
    }
  }

  markTodoAsNotDone(Todo todo) {
    // Check if the todo is already marked as done
    int index = doneTodos.indexOf(todo);

    if (index !=
        -1 /* todos.where((element) => element == todo).isNotEmpty */) {
      //Create a new todo based on the old one
      final newTodo = todo.copyWith(isDone: false);
      //This is to update the todo in the database
      todoBox.put(newTodo, mode: PutMode.update);

      //Set the state to update the UI
      setState(() {
        //Add the new todo to the list of not done todos
        todos.add(newTodo);
        //Remove the old todo from the list of done todos
        doneTodos.remove(todo);
      });
    }
  }

  late Box<Todo> todoBox;

  @override
  void initState() {
    super.initState();

    _loadTodos();
  }

  double scrollAmount = 0;

  void _loadTodos() {
    todoBox = objectbox.store.box<Todo>();

    if (!todoBox.isEmpty()) {
      var allTodos = todoBox.getAll();
      todos = allTodos.where((element) => element.isDone == false).toList();

      doneTodos = allTodos.where((element) => element.isDone == true).toList();
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
                    child: AnimatedCrossFade(
                      crossFadeState: scrollAmount < 0.5
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      sizeCurve: Curves.easeInOut,
                      firstCurve: Curves.easeInOut,
                      secondCurve: Curves.easeInOut,
                      firstChild: Text(
                        'TODO',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: Colors.white),
                      ),
                      secondChild: Text(
                        'COMPLETED TODO',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: Colors.white),
                      ),
                      duration: 250.milliseconds,
                      reverseDuration: 250.milliseconds,
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: size.width,
                      height: size.height * 0.7,
                      child: CarouselSlider(
                        items: [
                          Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 16.0),
                            child: Visibility(
                              visible: todos.isNotEmpty,
                              replacement: Center(
                                  child: Text(
                                'No todos'.toUpperCase(),
                              )),
                              child: ListView.builder(
                                itemCount: todos.length,
                                shrinkWrap: true,
                                padding:
                                    const EdgeInsets.only(bottom: 90, top: 16),
                                itemBuilder: (context, index) {
                                  final todo = todos[index];
                                  return TodoItem(
                                    todo: todo,
                                    onDelete: () {
                                      todoBox.remove(todo.id);

                                      setState(() {
                                        todos.remove(todo);
                                      });
                                    },
                                    onMark: () {
                                      markTodoAsDone(todo);
                                    },
                                    onEdit: () async {
                                      await Navigator.push(context,
                                          MaterialPageRoute(builder: (_) {
                                        return DialogWidget(
                                          todo: todo,
                                          onConfirm:
                                              (Todo newTodo, bool isEdit) {
                                            if (isEdit) {
                                              todoBox.put(newTodo,
                                                  mode: PutMode.update);
                                              setState(() {
                                                todos[todos.indexOf(todo)] =
                                                    newTodo;
                                              });
                                            } else {
                                              todoBox.put(newTodo,
                                                  mode: PutMode.put);
                                              setState(() {
                                                todos.add(newTodo);
                                              });
                                            }
                                          },
                                        );
                                      }));
                                    },
                                  ).animate().fadeIn().scale();
                                },
                              ),
                            ),
                          ),
                          Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 16.0),
                            child: Visibility(
                              visible: doneTodos.isNotEmpty,
                              replacement: Center(
                                  child: Text(
                                'No completed todos'.toUpperCase(),
                              )),
                              child: ListView.builder(
                                shrinkWrap: true,
                                padding:
                                    const EdgeInsets.only(bottom: 90, top: 16),
                                itemCount: doneTodos.length,
                                itemBuilder: (context, index) {
                                  final todo = doneTodos[index];

                                  return TodoItem(
                                    todo: todo,
                                    onDelete: () {
                                      todoBox.remove(todo.id);

                                      setState(() {
                                        doneTodos.remove(todo);
                                      });
                                    },
                                    onMark: () {
                                      markTodoAsNotDone(todo);
                                    },
                                    onEdit: () async {
                                      await Navigator.push(context,
                                          MaterialPageRoute(builder: (_) {
                                        return DialogWidget(
                                          todo: todo,
                                          onConfirm:
                                              (Todo newTodo, bool isEdit) {
                                            if (isEdit) {
                                              todoBox.put(newTodo,
                                                  mode: PutMode.update);
                                              setState(() {
                                                doneTodos[doneTodos
                                                    .indexOf(todo)] = newTodo;
                                              });
                                            } else {
                                              todoBox.put(newTodo,
                                                  mode: PutMode.put);
                                              setState(() {
                                                doneTodos.add(newTodo);
                                              });
                                            }
                                          },
                                        );
                                      }));
                                    },
                                  ).animate().fadeIn().scale();
                                },
                              ),
                            ),
                          ),
                        ],
                        carouselController: carouselController,
                        options: CarouselOptions(
                            autoPlay: false,
                            enlargeCenterPage: true,
                            aspectRatio: 1,
                            initialPage: 0,
                            height: size.height * 0.7,
                            viewportFraction: 0.9,
                            //enlargeFactor: 0.2,
                            enableInfiniteScroll: false,
                            enlargeStrategy: CenterPageEnlargeStrategy.scale,
                            onScrolled: (a) {
                              setState(() {
                                scrollAmount = a ?? 0;
                              });
                            }
                            // reverse: true
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
      floatingActionButton: AnimatedScale(
        scale: 1 - scrollAmount,
        duration: 100.milliseconds,
        child: FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) {
                return DialogWidget(
                  onConfirm: (Todo todo, bool isEdit) {
                    if (isEdit) {
                      todoBox.put(todo, mode: PutMode.update);
                      setState(() {
                        todos[todos.indexOf(todo)] = todo;
                      });
                    } else {
                      todoBox.put(todo, mode: PutMode.put);
                      setState(() {
                        todos.add(todo);
                      });
                    }
                  },
                );
              }));
            },
            label: const Text('New todo'),
            icon: const Icon(Icons.add)),
      ),
    );
  }
}

class TodoItem extends StatelessWidget {
  const TodoItem({
    super.key,
    required this.todo,
    required this.onMark,
    required this.onDelete,
    required this.onEdit,
  });

  final Todo todo;
  final Function() onMark;
  final Function() onDelete;
  final Function() onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Stack(
        //mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Priority.colorOf(Priority.fromName(todo.priority))
                .lighten(0.38),
            margin: const EdgeInsets.only(top: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.only(left: 4, right: 16, top: 2),
              title: Text(
                todo.title,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.2,
                  color: Priority.colorOf(Priority.fromName(todo.priority))
                      .darken(0.4),
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              /* onTap: () {
                onMark();
              }, */
              leading: Checkbox(
                value: todo.isDone,
                side: BorderSide(
                  color: Priority.colorOf(Priority.fromName(todo.priority)),
                ),
                onChanged: (bool? value) {
                  onMark();
                },
              ),
              minLeadingWidth: 24,
              horizontalTitleGap: 4,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_note_outlined,
                      color: Priority.colorOf(Priority.fromName(todo.priority)),
                    ),
                    onPressed: () {
                      onEdit();
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      onDelete();
                    },
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Card(
              margin: const EdgeInsets.only(left: 16, right: 4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0)),
              color: Priority.colorOf(Priority.fromName(todo.priority)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
                child: Text(
                  todo.priority,
                  style: TextStyle(
                      fontSize: 12,
                      color: Priority.colorOf(Priority.fromName(todo.priority))
                          .getTextColor()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DialogWidget extends StatefulWidget {
  const DialogWidget({super.key, required this.onConfirm, this.todo});

  final Function(Todo todo, bool isEdit) onConfirm;
  final Todo? todo;

  @override
  State<DialogWidget> createState() => _DialogWidgetState();
}

class _DialogWidgetState extends State<DialogWidget> {
  Priority p = Priority.low;
  late final TextEditingController _controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.todo?.title,
    );
    if (widget.todo != null) {
      p = Priority.values
          .firstWhere((element) => element.name == widget.todo!.priority);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar:
            AppBar(title: Text(widget.todo == null ? 'New todo' : 'Edit todo')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    autofocus: true,
                    controller: _controller,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText:
                          widget.todo == null ? 'Enter new todo ' : 'Edit todo',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: DropdownButton<Priority>(
                        value: p,
                        items: Priority.values.map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(e.name),
                          );
                        }).toList(),
                        onChanged: (priority) {
                          setState(() {
                            p = priority!;
                            //log(p);
                          });
                        }),
                  )
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            //height: kBottomNavigationBarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _controller.clear();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(
                  width: 8,
                ),
                TextButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    if (widget.todo == null) {
                      widget.onConfirm(
                          Todo(title: _controller.text, priority: p.name),
                          false);
                    } else {
                      widget.onConfirm(
                          widget.todo!.copyWith(
                              title: _controller.text, priority: p.name),
                          true);
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    widget.todo == null ? 'Add' : 'Edit',
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
