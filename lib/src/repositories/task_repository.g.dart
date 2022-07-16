// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_repository.dart';

// **************************************************************************
// DaoGenerator
// **************************************************************************

mixin _$TaskRepositoryMixin on DatabaseAccessor<AppDatabase> {
  $TasksTable get tasks => attachedDatabase.tasks;
  Selectable<Task> completedTasksGenerated() {
    return customSelect(
        'SELECT * FROM tasks WHERE completed = 1 ORDER BY due_date DESC, name;',
        variables: [],
        readsFrom: {
          tasks,
        }).map(tasks.mapFromRow);
  }
}
