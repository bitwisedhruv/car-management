// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:client/core/utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class UpdateCarPage extends StatefulWidget {
  final int carId;
  final String initialTitle;
  final String initialDescription;
  final List<String> initialTags;
  final List<String> initialImages;

  const UpdateCarPage({
    super.key,
    required this.carId,
    required this.initialTitle,
    required this.initialDescription,
    required this.initialTags,
    required this.initialImages,
  });

  @override
  State<UpdateCarPage> createState() => _UpdateCarPageState();
}

class _UpdateCarPageState extends State<UpdateCarPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> imageControllers = [];
  final _tagsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle;
    _descriptionController.text = widget.initialDescription;
    _tagsController.text = widget.initialTags.join(', ');

    for (final image in widget.initialImages) {
      imageControllers.add(TextEditingController(text: image));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    for (final controller in imageControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> updateCar({
    required int carId,
    required String title,
    required String description,
    required List<String> tags,
    required List<String> imageUrls,
  }) async {
    final Uri apiUrl =
        Uri.parse('$baseUrl/cars/$carId'); // Replace with your API endpoint

    final Map<String, dynamic> carData = {
      "title": title,
      "description": description,
      "tags": tags,
      "images": imageUrls,
    };

    try {
      final response = await http.put(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(carData),
      );

      if (response.statusCode == 200) {
        print('Car updated successfully');
      } else {
        print('Failed to update car: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _updateCar() async {
    if (_formKey.currentState!.validate()) {
      await updateCar(
        carId: widget.carId,
        title: _titleController.text,
        description: _descriptionController.text,
        tags: _tagsController.text.split(',').map((tag) => tag.trim()).toList(),
        imageUrls: imageControllers
            .map((controller) => controller.text.trim())
            .toList(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car updated successfully!')),
      );

      Navigator.pop(
          context, true); // Signal that the car was updated successfully
    }
  }

  void _addImageField() {
    if (imageControllers.length < 10) {
      setState(() {
        imageControllers.add(TextEditingController());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can add up to 10 images only!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Car'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                      value!.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? 'Description is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                      labelText: 'Tags (comma-separated)'),
                  validator: (value) =>
                      value!.isEmpty ? 'Tags are required' : null,
                ),
                const SizedBox(height: 16),
                const Text('Images'),
                const SizedBox(height: 8),
                ...imageControllers.asMap().entries.map(
                  (entry) {
                    final index = entry.key;
                    final controller = entry.value;
                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller,
                            decoration:
                                const InputDecoration(labelText: 'Image URL'),
                            validator: (value) =>
                                value!.isEmpty ? 'Image URL is required' : null,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              imageControllers.removeAt(index);
                            });
                          },
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red),
                        ),
                      ],
                    );
                  },
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addImageField,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Image'),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _updateCar,
                  child: const Text('Update Car'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
