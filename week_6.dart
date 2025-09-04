import 'package:flutter/material.dart';

// Mock Provider implementation to avoid import errors
// These will be replaced with actual Provider imports once dependencies are installed
class ChangeNotifierProvider<T extends ChangeNotifier> extends StatefulWidget {
  final T Function(BuildContext) create;
  final Widget child;

  const ChangeNotifierProvider({
    super.key,
    required this.create,
    required this.child,
  });

  static T of<T>(BuildContext context, {bool listen = true}) {
    return context.dependOnInheritedWidgetOfExactType<_InheritedProvider<T>>()!.value;
  }

  @override
  State<ChangeNotifierProvider<T>> createState() => _ChangeNotifierProviderState<T>();
}

class _ChangeNotifierProviderState<T extends ChangeNotifier> extends State<ChangeNotifierProvider<T>> {
  late T value;

  @override
  void initState() {
    super.initState();
    value = widget.create(context);
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedProvider<T>(
      value: value,
      child: widget.child,
    );
  }
}

class _InheritedProvider<T> extends InheritedWidget {
  final T value;

  const _InheritedProvider({
    required this.value,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedProvider<T> oldWidget) {
    return value != oldWidget.value;
  }
}

class Consumer<T> extends StatelessWidget {
  final Widget Function(BuildContext context, T value, Widget? child) builder;

  const Consumer({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      ChangeNotifierProvider.of<T>(context),
      null,
    );
  }
}

// Mock Slidable implementation
class Slidable extends StatelessWidget {
  final Widget child;
  final Widget? endActionPane;

  const Slidable({
    super.key,
    required this.child,
    this.endActionPane,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class ActionPane extends StatelessWidget {
  final Widget motion;
  final List<Widget> children;

  const ActionPane({
    super.key,
    required this.motion,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class SlidableAction extends StatelessWidget {
  final Function(BuildContext)? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final String label;

  const SlidableAction({
    super.key,
    this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class ScrollMotion extends StatelessWidget {
  const ScrollMotion({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// Task Model
class Task {
  final String id;
  final String title;
  final String description;
  bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Task Provider for State Management
class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  List<Task> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();

  List<Task> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList();

  void addTask(Task task) {
    _tasks.insert(0, task);
    notifyListeners();
  }

  void updateTask(String id, Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  void clearCompletedTasks() {
    _tasks.removeWhere((task) => task.isCompleted);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: MaterialApp(
        title: 'Task Manager',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const TaskListScreen(),
      ),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          if (_selectedIndex == 1)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                _showClearCompletedDialog(context);
              },
            ),
        ],
      ),
      body: _buildSelectedScreen(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'All Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Completed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'Pending',
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return const AllTasksTab();
      case 1:
        return const CompletedTasksTab();
      case 2:
        return const PendingTasksTab();
      default:
        return const AllTasksTab();
    }
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add New Task',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isNotEmpty) {
                          final taskProvider =
                              ChangeNotifierProvider.of<TaskProvider>(context, listen: false);
                          taskProvider.addTask(
                            Task(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: titleController.text,
                              description: descriptionController.text,
                              createdAt: DateTime.now(),
                            ),
                          );
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showClearCompletedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Completed Tasks'),
          content: const Text('Are you sure you want to clear all completed tasks?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ChangeNotifierProvider.of<TaskProvider>(context, listen: false).clearCompletedTasks();
                Navigator.of(context).pop();
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}

class AllTasksTab extends StatelessWidget {
  const AllTasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        if (taskProvider.tasks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_alt, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No tasks yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  'Tap the + button to add a task',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: taskProvider.tasks.length,
          itemBuilder: (context, index) {
            final task = taskProvider.tasks[index];
            return _buildTaskItem(context, task);
          },
        );
      },
    );
  }
}

class CompletedTasksTab extends StatelessWidget {
  const CompletedTasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        if (taskProvider.completedTasks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No completed tasks',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: taskProvider.completedTasks.length,
          itemBuilder: (context, index) {
            final task = taskProvider.completedTasks[index];
            return _buildTaskItem(context, task);
          },
        );
      },
    );
  }
}

class PendingTasksTab extends StatelessWidget {
  const PendingTasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        if (taskProvider.pendingTasks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pending_actions, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No pending tasks',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  'All tasks are completed!',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: taskProvider.pendingTasks.length,
          itemBuilder: (context, index) {
            final task = taskProvider.pendingTasks[index];
            return _buildTaskItem(context, task);
          },
        );
      },
    );
  }
}

Widget _buildTaskItem(BuildContext context, Task task) {
  return Dismissible(
    key: Key(task.id),
    direction: DismissDirection.endToStart,
    background: Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20.0),
      child: const Icon(Icons.delete, color: Colors.white),
    ),
    onDismissed: (direction) {
      ChangeNotifierProvider.of<TaskProvider>(context, listen: false).deleteTask(task.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${task.title}" deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              ChangeNotifierProvider.of<TaskProvider>(context, listen: false).addTask(task);
            },
          ),
        ),
      );
    },
    child: Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            ChangeNotifierProvider.of<TaskProvider>(context, listen: false)
                .toggleTaskCompletion(task.id);
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: task.description.isNotEmpty
            ? Text(
                task.description,
                style: TextStyle(
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () {
                _showEditTaskDialog(context, task);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () {
                ChangeNotifierProvider.of<TaskProvider>(context, listen: false).deleteTask(task.id);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

void _showEditTaskDialog(BuildContext context, Task task) {
  final titleController = TextEditingController(text: task.title);
  final descriptionController = TextEditingController(text: task.description);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Task',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty) {
                        final taskProvider =
                            ChangeNotifierProvider.of<TaskProvider>(context, listen: false);
                        taskProvider.updateTask(
                          task.id,
                          task.copyWith(
                            title: titleController.text,
                            description: descriptionController.text,
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}