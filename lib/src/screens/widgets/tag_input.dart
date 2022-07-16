import 'package:drift_sqlite/src/controllers/tags_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TagInput extends ConsumerStatefulWidget {
  const TagInput({Key? key}) : super(key: key);

  @override
  ConsumerState<TagInput> createState() => _TagInputState();
}

class _TagInputState extends ConsumerState<TagInput> {
  final tagNameController = TextEditingController();
  Color tagColor = Colors.red;

  @override
  void dispose() {
    tagNameController.dispose();
    super.dispose();
  }

  void onSubmitTag(String value) {
    ref.read(tagsControllerProvider).addTag(name: value, color: tagColor);
  }

  void onPickColor() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: MaterialColorPicker(
              allowShades: false,
              selectedColor: tagColor,
              onMainColorChange: (colorSwatch) {
                setState(() {
                  tagColor = colorSwatch as Color;
                });
                Navigator.pop(
                  context,
                );
              },
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        children: [
          Flexible(
              child: TextField(
            decoration: const InputDecoration(hintText: 'Tag Name'),
            controller: tagNameController,
            onSubmitted: onSubmitTag,
          )),
          const SizedBox(
            width: 20,
          ),
          GestureDetector(
            onTap: onPickColor,
            child: Container(
              height: 25,
              width: 25,
              decoration:
                  BoxDecoration(color: tagColor, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}
