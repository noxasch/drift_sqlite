import 'package:drift_sqlite/src/controllers/tasks_controller.dart';
import 'package:drift_sqlite/src/database/app_database.dart';
import 'package:drift_sqlite/src/repositories/tag_repository.dart';
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
  Tag? selectedTag;

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
      lastDate: DateTime(2050),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    ref.read(tasksControllerProvider).addTask(
                          name: inputName,
                          dueDate: taskDueDate,
                          tagId: selectedTag?.id,
                        );
                    resetInput();
                  },
                );
              },
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              final tags = ref.watch(tagsProvider);
              final List<DropdownMenuItem<Tag>> dropDownItems = [
                ...tags
                    .when(
                      data: (tags) => tags
                          .map(
                            (tag) => DropdownMenuItem<Tag>(
                              value: tag,
                              child: TagItemContent(
                                tag: tag,
                              ),
                            ),
                          )
                          .toList(),
                      error: (error, stack) => [],
                      loading: () => [],
                    )
                    .toList()
              ];

              return DropdownButton(
                elevation: 2,
                value: selectedTag,
                borderRadius: BorderRadius.circular(10),
                hint: const Text('Select Tag'),
                items: dropDownItems,
                onChanged: (Tag? tag) {
                  setState(() {
                    selectedTag = tag;
                  });
                },
              );
            },
          ),
          IconButton(
            onPressed: onSetDueDate,
            icon: const Icon(Icons.calendar_today),
          )
        ],
      ),
    );
  }
}

class TagItemContent extends StatelessWidget {
  const TagItemContent({
    Key? key,
    required this.tag,
  }) : super(key: key);

  final Tag tag;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(tag.name),
        const SizedBox(
          width: 5,
        ),
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: Color(tag.color),
          ),
        ),
      ],
    );
  }
}
