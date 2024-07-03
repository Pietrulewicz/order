import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/task_item.dart';
import 'package:intl/intl.dart';
import 'calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> tasks = [
    Task(
      title: 'Buy milk',
      description: 'Get milk from the store',
      category: 'House',
      dateTime: DateTime.now().add(const Duration(days: 1)),
    ),
    Task(
      title: 'Complete homework',
      description: 'Finish math assignment',
      category: 'Work/School',
      dateTime: DateTime.now().add(const Duration(days: 2)),
    ),
  ];

  void _deleteTask(Task task) {
    setState(() {
      tasks.remove(task);
    });
  }

  void _addTask(Task task) {
    setState(() {
      tasks.add(task);
      print('Task added: ${task.title}, ${task.dateTime}');
      for (var t in tasks) {
        print('Task: ${t.title}, Date: ${t.dateTime}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
      ),
      body: ListView(
        children: [
          _buildCategory('House'),
          _buildCategory('Work/School'),
          _buildCategory('Hobby'),
          _buildCategory('Meetings'),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: FloatingActionButton(
              heroTag: 'calendar',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalendarScreen(tasks: tasks, onAddTask: _addTask)),
                ).then((_) {
                  print('Returning from CalendarScreen with tasks:');
                  for (var t in tasks) {
                    print('Task: ${t.title}, Date: ${t.dateTime}');
                  }
                  setState(() {}); // Odśwież stan po powrocie z ekranu kalendarza
                });
              },
              child: const Icon(Icons.calendar_today),
            ),
          ),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () {
              _showAddTaskDialog(context);
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(String category) {
    final categoryTasks = tasks.where((task) => task.category == category).toList();
    return ExpansionTile(
      title: Text(category),
      children: categoryTasks.map((task) {
        return TaskItem(
          task: task,
          onChanged: (bool? value) {
            setState(() {
              task.isCompleted = value!;
            });
          },
          onDelete: () => _deleteTask(task),
        );
      }).toList(),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    String? title;
    String? description;
    String? category;
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add New Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'Title'),
                      onChanged: (value) {
                        title = value;
                      },
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Description'),
                      onChanged: (value) {
                        description = value;
                      },
                    ),
                    DropdownButton<String>(
                      hint: const Text('Select Category'),
                      value: category,
                      onChanged: (String? newValue) {
                        setState(() {
                          category = newValue!;
                        });
                      },
                      items: <String>['House', 'Work/School', 'Hobby', 'Meetings']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    Row(
                      children: [
                        TextButton(
                          child: const Text('Select Date'),
                          onPressed: () async {
                            DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (date != null) {
                              setState(() {
                                selectedDate = date;
                              });
                            }
                          },
                        ),
                        Text(selectedDate == null ? '' : DateFormat('yyyy-MM-dd').format(selectedDate!)),
                      ],
                    ),
                    Row(
                      children: [
                        TextButton(
                          child: const Text('Select Time'),
                          onPressed: () async {
                            TimeOfDay? time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                selectedTime = time;
                              });
                            }
                          },
                        ),
                        Text(selectedTime == null ? '' : selectedTime!.format(context)),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    if (title != null && description != null && category != null && selectedDate != null && selectedTime != null) {
                      final DateTime dateTime = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        selectedTime!.hour,
                        selectedTime!.minute,
                      );
                      final newTask = Task(
                        title: title!,
                        description: description!,
                        category: category!,
                        dateTime: dateTime,
                      );
                      _addTask(newTask);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
