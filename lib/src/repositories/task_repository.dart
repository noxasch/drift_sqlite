import 'package:drift/drift.dart';
import 'package:drift_sqlite/src/database/app_database.dart';
import 'package:drift_sqlite/src/screens/home_screen.dart' show HomeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'task_repository.g.dart';

final tasksProvider = StreamProvider.autoDispose<List<Task>>((ref) {
  return ref.watch(taskRepoProvider).watchAllTasks;
});

final tasksProviderFamily =
    StreamProvider.family.autoDispose<List<Task>, HomeMode>((ref, mode) {
  if (mode == HomeMode.completed) {
    return ref.watch(taskRepoProvider).watchCompletedTasks;
  }
  return ref.watch(taskRepoProvider).watchAllTasks;
});

final taskRepoProvider = Provider((ref) {
  final db = AppDatabase();
  ref.onDispose(() {
    db.close();
  });

  // since we define in the daos list,
  // drift already instantiate the DAO when the db is instantiated
  return db.taskRepository;
  // return TaskRepository(db);
});

// TypeSafe as drift will create corresponding result handler
// need to be called like this .completedTasksGenerated().watch();
const completedTasksQuery =
    'SELECT * FROM tasks WHERE completed = 1 ORDER BY due_date DESC, name;';

@DriftAccessor(tables: [
  Tasks
], queries: {
  'completedTasksGenerated':
      'SELECT * FROM tasks WHERE completed = 1 ORDER BY due_date DESC, name;'
})
class TaskRepository extends DatabaseAccessor<AppDatabase>
    with _$TaskRepositoryMixin {
  TaskRepository(AppDatabase db) : super(db);

  Future<List<Task>> get getAllTasks => select(tasks).get();

  Stream<List<Task>> get watchAllTasks {
    final query = select(tasks)
      ..orderBy([
        ((tbl) => OrderingTerm.desc(tbl.dueDate)),
        ((tbl) => OrderingTerm.asc(tbl.name))
      ]);

    return query.watch();
  }

  Stream<List<Task>> get watchCompletedTasks {
    final query = select(tasks)
      ..where((tbl) => tbl.completed.equals(true))
      ..orderBy([
        ((tbl) => OrderingTerm.desc(tbl.dueDate)),
        ((tbl) => OrderingTerm.asc(tbl.name))
      ]);

    return query.watch();
  }

  Stream<List<Task>> get watchCompletedTasksCustom {
    return customSelect(completedTasksQuery, readsFrom: {tasks})
        .watch()
        .map((rows) {
      return rows.map((row) => Task.fromData(row.data)).toList();
    });
  }

  Future<Task?> getTaskById(int id) =>
      (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> addTask(TasksCompanion task) => into(tasks).insert(task);

  Future<bool> updateTask(Task task) => update(tasks).replace(task);

  Future<int> deleteTask(Task task) => delete(tasks).delete(task);
}
