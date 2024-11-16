import 'dart:convert';
import 'package:client/core/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateProductPage extends StatefulWidget {
  const CreateProductPage({super.key});

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController =
      TextEditingController(); // Controller for tags field
  final List<TextEditingController> _imageControllers = [];
  int _imageCount = 0;

  // Function to add a new image field
  void _addImageField() {
    if (_imageCount < 10) {
      setState(() {
        _imageControllers.add(TextEditingController());
        _imageCount++;
      });
    }
  }

  // Function to submit the form data (including image URLs)
  Future<void> _submitProduct() async {
    if (_formKey.currentState!.validate()) {
      await createProduct(
        title: _titleController.text,
        description: _descriptionController.text,
        tags: _tagsController.text.split(',').map((tag) => tag.trim()).toList(),
        imageUrls: _imageControllers
            .map((controller) => controller.text.trim())
            .toList(),
      );
    }
  }

  // API call to create product
  Future<void> createProduct({
    required String title,
    required String description,
    required List<String> tags,
    required List<String> imageUrls,
  }) async {
    final Uri apiUrl =
        Uri.parse('$baseUrl/cars'); // Replace with your backend URL

    // Constructing the request body
    final Map<String, dynamic> productData = {
      "title": title,
      "description": description,
      "tags": tags, // Ensure this is sent as a list
      "images": imageUrls, // Ensure this is sent as a list
    };

    try {
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(productData), // Convert product data to JSON
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        print('Product created successfully: ${responseBody['message']}');
      } else if (response.statusCode == 422) {
        print('Validation error: ${response.body}');
      } else {
        print('Failed to create product: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Product')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Product Title'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a title' : null,
                ),
                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  decoration:
                      const InputDecoration(labelText: 'Product Description'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a description' : null,
                ),
                // Tags Field
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(labelText: 'Product Tags'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter tags' : null,
                ),
                // Image URL Fields
                const SizedBox(height: 10),
                const Text('Image URLs:'),
                ...List.generate(_imageCount, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _imageControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Image URL ${index + 1}',
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'Please enter an image URL'
                                : null,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                // Add Image Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: _addImageField,
                      icon: const Icon(Icons.add_circle),
                    ),
                    const Text('Add Image URL'),
                  ],
                ),
                const SizedBox(height: 20),
                // Submit Button - Calls the _submitProduct function
                ElevatedButton(
                  onPressed:
                      _submitProduct, // Directly calls _submitProduct here
                  child: const Text('Submit Product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
