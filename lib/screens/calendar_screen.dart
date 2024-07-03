import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  final List<Task> tasks;
  final Function(Task) onAddTask;

  const CalendarScreen({Key? key, required this.tasks, required this.onAddTask}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Map<DateTime, List<Task>> _taskEvents;
  late List<Task> _selectedTasks;
  DateTime _selectedDay = DateTime.now();
  DateTime? _lastSelectedDay;

  @override
  void initState() {
    super.initState();
    _taskEvents = _groupTasksByDate(widget.tasks);
    _selectedTasks = _taskEvents[_selectedDay] ?? [];
    print('Initial task events: $_taskEvents');
    print('Selected tasks for $_selectedDay: $_selectedTasks');
  }

  Map<DateTime, List<Task>> _groupTasksByDate(List<Task> tasks) {
    Map<DateTime, List<Task>> data = {};
    for (var task in tasks) {
      DateTime date = DateTime(task.dateTime.year, task.dateTime.month, task.dateTime.day);
      if (data[date] == null) data[date] = [];
      data[date]!.add(task);
    }
    data.forEach((key, value) {
      print('Date: $key, Tasks: ${value.length}');
    });
    return data;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      if (_lastSelectedDay != null && _lastSelectedDay == selectedDay) {
        _showAddTaskDialog(context, selectedDay);
      }
      _lastSelectedDay = selectedDay;
      _selectedDay = selectedDay;
      _selectedTasks = _taskEvents[selectedDay] ?? [];
      print('Selected Date: $_selectedDay, Tasks: ${_selectedTasks.length}');
    });
  }

  void _showAddTaskDialog(BuildContext context, DateTime selectedDay) {
    String? title;
    String? description;
    String? category;

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
                    if (title != null && description != null && category != null) {
                      final newTask = Task(
                        title: title!,
                        description: description!,
                        category: category!,
                        dateTime: selectedDay,
                      );
                      widget.onAddTask(newTask);
                      Navigator.of(context).pop();
                      setState(() {
                        _taskEvents = _groupTasksByDate(widget.tasks);
                        _selectedTasks = _taskEvents[_selectedDay] ?? [];
                      });
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

  @override
  Widget build(BuildContext context) {
    _taskEvents = _groupTasksByDate(widget.tasks); // Odświeżanie stanu po powrocie
    _selectedTasks = _taskEvents[_selectedDay] ?? [];
    print('Building CalendarScreen with tasks: ${widget.tasks}');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _selectedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            eventLoader: (day) {
              return _taskEvents[day] ?? [];
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, tasks) {
                if (tasks.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${tasks.length}',
                          style: const TextStyle().copyWith(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return null;
              },
              selectedBuilder: (context, date, _) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
              todayBuilder: (context, date, _) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedTasks.length,
              itemBuilder: (context, index) {
                Task task = _selectedTasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text('${task.description}\n${DateFormat('yyyy-MM-dd – kk:mm').format(task.dateTime)}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
