import 'package:drift/drift.dart';
import 'package:drift_sqlite/src/controllers/tasks_controller.dart';
import 'package:drift_sqlite/src/database/app_database.dart';
import 'package:drift_sqlite/src/exception/task_exception.dart';
import 'package:drift_sqlite/src/repositories/tag_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tagsControllerProvider =
    Provider.autoDispose<TagsController>((ref) => TagsController(ref.read));

class TagsController extends StateNotifier<AsyncValue<List<Tag>>> {
  final Reader read;

  TagsController(this.read) : super(const AsyncLoading());

  Future<void> addTag({required String name, Color? color}) async {
    if (name.isEmpty) {
      read(taskErrorProvider.state).state =
          TaskException('Please enter task name');
    } else {
      try {
        final tag = TagsCompanion(
            name: Value(name), color: Value.ofNullable(color?.value));
        await read(tagRepoProvider).insertTag(tag);
      } on InvalidDataException catch (error) {
        read(taskErrorProvider.state).state = TaskException(error.message);
      }
    }
  }
}
