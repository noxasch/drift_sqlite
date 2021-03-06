import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_sqlite/src/repositories/tag_repository.dart'
    show TagRepository;
import 'package:drift_sqlite/src/repositories/task_repository.dart'
    show TaskRepository;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// this is supposed to be model definition
// if we are using drift only this is the only model we need
// should be named as test.dart and task.g.dart
// will not be generated as we are using freezed instead
// we meed to implement custom function to support
// drift getter if we are using freezed or other data class generator
part 'app_database.g.dart';

// we should only use one db connection for the app
final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();

  ref.onDispose(() {
    db.close();
  });

  return db;
});

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tagId => integer().nullable().references(Tags, #id)();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  // drift autoconvert into DateTime from unixtime as sqlite does not have datetime type
  DateTimeColumn get dueDate => dateTime().nullable()();
  // drfit autoconvert into bool from integer as sqlite does not have boolean type
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get color => integer()();
}

// for joined table
class TaskWithTag {
  final Task task;
  final Tag? tag;

  TaskWithTag({required this.task, this.tag});
}

// list of DAOs are optional
@DriftDatabase(tables: [Tasks, Tags], daos: [TaskRepository, TagRepository])
class AppDatabase extends _$AppDatabase {
  // we tell the database where to store the data with this constructor
  AppDatabase() : super(_openConnection());

  // you should bump this number whenever you change or add a table definition.
  // Migrations are covered later in the documentation.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      // onCreate is optional
      // onCreate: (Migrator migrator) async => await migrator.createAll(),
      onUpgrade: (Migrator migrator, int from, int to) async {
        if (from == 1) {
          await migrator.createTable(tags);
          await migrator.addColumn(tasks, tasks.tagId);
        }
      },
      beforeOpen: (OpeningDetails details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file,
        logStatements: true); // set logStatements: !kDebugMode
  });
}
