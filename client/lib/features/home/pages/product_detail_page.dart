// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:client/core/utils.dart';
import 'package:client/features/home/pages/update_product_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CarDetailPage extends StatefulWidget {
  final int carId;
  final String title;
  final String description;
  final List<String> images;
  final List<String> tags;

  const CarDetailPage({
    super.key,
    required this.carId,
    required this.title,
    required this.description,
    required this.images,
    required this.tags,
  });

  @override
  State<CarDetailPage> createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  bool isLoading = false;
  late String title;
  late String description;
  late List<String> images;
  late List<String> tags;

  Future<void> updateCar({
    required int carId,
    required String title,
    required String description,
    required List<String> tags,
    required List<String> imageUrls,
  }) async {
    final Uri apiUrl = Uri.parse('$baseUrl/cars/$carId'); // Update endpoint

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

  Future<void> deleteCar() async {
    final url = Uri.parse('$baseUrl/cars/${widget.carId}');
    setState(() => isLoading = true);

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        Navigator.pop(context); // Go back to HomePage
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Car deleted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete car: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchCarDetails() async {
    final url = Uri.parse('$baseUrl/cars/${widget.carId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        title = data['title'];
        description = data['description'];
        images = (data['images'] as String)
            .split(',')
            .map((e) => e.trim().replaceAll('{', '').replaceAll('}', ''))
            .toList();
        tags =
            (data['tags'] as String).split(',').map((e) => e.trim()).toList();
      });
    } else {
      // Handle error
      print('Failed to fetch car details: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tags: ${widget.tags.join(", ")}',
                    style: const TextStyle(
                        fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Image.network(
                            widget.images[index],
                            fit: BoxFit.cover,
                            height: 200,
                            width: 300,
                          ),
                        );
                      },
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateCarPage(
                                carId: widget.carId, // Pass the car's ID
                                initialTitle:
                                    widget.title, // Pass the car's title
                                initialDescription: widget
                                    .description, // Pass the car's description
                                initialTags: widget
                                    .tags, // Pass the car's tags as a list
                                initialImages: widget
                                    .images, // Pass the car's image URLs as a list
                              ),
                            ),
                          );

                          if (updated == true) {
                            setState(() {
                              isLoading =
                                  true; // Optional: Show loading indicator
                            });

                            await fetchCarDetails(); // Re-fetch car details from the API

                            setState(() {
                              isLoading = false; // Hide loading indicator
                            });
                          }
                        },
                        child: const Text('Update'),
                      ),
                      ElevatedButton(
                        onPressed: deleteCar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
