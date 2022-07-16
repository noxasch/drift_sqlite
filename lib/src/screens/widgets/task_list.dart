import 'package:drift_sqlite/src/controllers/tasks_controller.dart';
import 'package:drift_sqlite/src/repositories/task_repository.dart';
import 'package:drift_sqlite/src/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskList extends ConsumerWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(homeModeProvider);
    final tasks = ref.watch(tasksProviderFamily(viewMode));

    return tasks.when(
      data: (data) {
        return ListView.separated(
          itemBuilder: (context, index) {
            final task = data[index];
            return CheckboxListTile(
              value: task.task.completed,
              title: Row(
                children: [
                  if (task.tag != null)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: task.tag?.color != null
                                ? Color(task.tag!.color)
                                : null,
                          ),
                        ),
                        Text(task.tag!.name),
                      ],
                    ),
                  Text(task.task.name),
                ],
              ),
              subtitle: Text(task.task.dueDate?.toString() ?? 'No date'),
              onChanged: (newVal) {
                ref
                    .read(tasksControllerProvider)
                    .updateTask(task.task, completed: newVal);
              },
            );
          },
          separatorBuilder: (context, index) => const SizedBox(
            height: 20,
          ),
          itemCount: data.length,
        );
      },
      error: (error, stack) {
        return Center(
          child: Text('$error'),
        );
      },
      loading: () {
        return const CircularProgressIndicator();
      },
    );
  }
}
