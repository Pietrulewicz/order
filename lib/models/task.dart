class Task {
  final String title;
  final String description;
  final String category;
  final DateTime dateTime;
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    required this.category,
    required this.dateTime,
    this.isCompleted = false,
  });
}
