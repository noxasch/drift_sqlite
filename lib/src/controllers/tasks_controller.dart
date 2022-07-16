import 'package:drift/drift.dart';
import 'package:drift_sqlite/src/database/app_database.dart';
import 'package:drift_sqlite/src/exception/task_exception.dart';
import 'package:drift_sqlite/src/repositories/task_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final taskErrorProvider = StateProvider<TaskException?>((_) => null);

final tasksControllerProvider =
    Provider.autoDispose<TasksController>((ref) => TasksController(ref.read));

class TasksController extends StateNotifier<AsyncValue<List<Task>>> {
  final Reader read;

  TasksController(this.read) : super(const AsyncLoading());

  Future<void> addTask({
    required String name,
    DateTime? dueDate,
    int? tagId,
  }) async {
    if (name.isEmpty) {
      read(taskErrorProvider.state).state =
          TaskException('Please enter task name');
    } else {
      try {
        final task = TasksCompanion(
          name: Value(name),
          dueDate: Value(dueDate),
          tagId: Value(tagId),
        );
        await read(taskRepoProvider).addTask(task);
      } on InvalidDataException catch (error) {
        read(taskErrorProvider.state).state = TaskException(error.message);
      }
    }
  }

  Future<void> updateTask(Task task,
      {String? name, bool? completed, DateTime? dueDate}) async {
    try {
      final updatedTask =
          task.copyWith(name: name, completed: completed, dueDate: dueDate);
      await read(taskRepoProvider).updateTask(updatedTask);
    } on InvalidDataException catch (error) {
      read(taskErrorProvider.state).state = TaskException(error.message);
    }
  }
}
