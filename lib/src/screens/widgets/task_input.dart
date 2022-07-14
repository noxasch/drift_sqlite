import 'package:drift_sqlite/src/controllers/tasks_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskInput extends StatefulWidget {
  const TaskInput({Key? key}) : super(key: key);

  @override
  State<TaskInput> createState() => _TaskInputState();
}

class _TaskInputState extends State<TaskInput> {
  final nameController = TextEditingController();
  DateTime? taskDueDate;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void resetInput() {
    taskDueDate = null;
    nameController.clear();
  }

  void onSetDueDate() async {
    taskDueDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2050));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            Flexible(
              child: Consumer(
                builder: (context, ref, child) {
                  return TextField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: 'Task Name'),
                    onSubmitted: (inputName) {
                      // if (inputName.isNotEmpty) {
                      ref
                          .read(tasksControllerProvider)
                          .addTask(name: inputName, dueDate: taskDueDate);
                      // }
                      resetInput();
                    },
                  );
                },
              ),
            ),
            IconButton(
                onPressed: onSetDueDate, icon: const Icon(Icons.calendar_today))
          ],
        ),
      ),
    );
  }
}
