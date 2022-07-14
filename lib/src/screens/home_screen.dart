import 'package:drift_sqlite/src/controllers/tasks_controller.dart';
import 'package:drift_sqlite/src/repositories/task_repository.dart';
import 'package:drift_sqlite/src/screens/widgets/task_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);

    ref.listen<Exception?>(taskErrorProvider,
        (Exception? prevException, Exception? currentException) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade300,
          content: Text(
            currentException.toString(),
            style: const TextStyle(color: Colors.white),
          )));
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
              child: tasks.when(data: (data) {
            return ListView.separated(
                itemBuilder: (context, index) {
                  final task = data[index];
                  return CheckboxListTile(
                      value: task.completed,
                      title: Text(task.name),
                      subtitle: Text(task.dueDate?.toString() ?? 'No date'),
                      onChanged: (newVal) {
                        ref
                            .read(tasksControllerProvider)
                            .updateTask(task, completed: newVal);
                      });
                },
                separatorBuilder: (context, index) => const SizedBox(
                      height: 20,
                    ),
                itemCount: data.length);
          }, error: (error, stack) {
            return Center(
              child: Text('$error'),
            );
          }, loading: () {
            return const CircularProgressIndicator();
          })),
          const TaskInput(),
        ],
      )),
    );
  }
}
