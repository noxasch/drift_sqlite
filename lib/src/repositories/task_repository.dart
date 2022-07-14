import 'package:drift/drift.dart';
import 'package:drift_sqlite/src/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'task_repository.g.dart';

final tasksProvider = StreamProvider.autoDispose<List<Task>>((ref) {
  return ref.watch(taskRepoProvider).watchAllTasks;
});

final taskRepoProvider = Provider((ref) {
  final db = AppDatabase();
  ref.onDispose(() {
    db.close();
  });
  return TaskRepository(db);
});

@DriftAccessor(tables: [Tasks])
class TaskRepository extends DatabaseAccessor<AppDatabase>
    with _$TaskRepositoryMixin {
  TaskRepository(AppDatabase db) : super(db);

  Future<List<Task>> get getAllTasks => select(tasks).get();

  Stream<List<Task>> get watchAllTasks => select(tasks).watch();

  Future<Task> getTaskById(int id) =>
      (select(tasks)..where((t) => t.id.equals(id))).getSingle();

  Future<int> addTask(TasksCompanion task) => into(tasks).insert(task);

  Future<bool> updateTask(Task task) => update(tasks).replace(task);

  Future<int> deleteTask(Task task) => delete(tasks).delete(task);
}
