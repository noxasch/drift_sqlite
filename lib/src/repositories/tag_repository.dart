import 'package:drift/drift.dart';
import 'package:drift_sqlite/src/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'tag_repository.g.dart';

final tagsProvider = StreamProvider.autoDispose<List<Tag>>((ref) {
  return ref.watch(tagRepoProvider).watchTags();
});

final tagRepoProvider = Provider.autoDispose((ref) {
  final db = ref.watch(dbProvider);

  return db.tagRepository;
});

@DriftAccessor(tables: [Tags])
class TagRepository extends DatabaseAccessor<AppDatabase>
    with _$TagRepositoryMixin {
  TagRepository(super.attachedDatabase);

  Stream<List<Tag>> watchTags() => select(tags).watch();

  Future<int> insertTag(Insertable<Tag> tag) => into(tags).insert(tag);
}
