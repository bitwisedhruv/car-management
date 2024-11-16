import 'dart:convert';
import 'package:client/auth_services.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/auth/pages/signup_page.dart';
import 'package:client/features/home/pages/create_product_page.dart';
import 'package:client/features/home/pages/product_detail_page.dart';
import 'package:client/features/home/widgets/car_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;
  List cars = [];

  @override
  void initState() {
    super.initState();
    fetchCars();
  }

  Future<void> fetchCars() async {
    final url = Uri.parse('$baseUrl/all-cars');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      setState(() {
        cars = data.map((car) {
          return {
            "id": car["id"],
            "title": car["title"],
            "description": car["description"],
            "images": (car["images"] as String)
                .split(",")
                .map((e) => e.trim().replaceAll("{", "").replaceAll("}", ""))
                .toList(),
            "tags": (car["tags"] as String)
                .split(",")
                .map((e) => e.trim())
                .toList(),
          };
        }).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List> searchCars(String query) async {
    final url = Uri.parse('$baseUrl/search?query=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((car) {
        return {
          "id": car["id"],
          "title": car["title"],
          "description": car["description"],
          "images": (car["images"] as String)
              .split(",")
              .map((e) => e.trim().replaceAll("{", "").replaceAll("}", ""))
              .toList(),
          "tags":
              (car["tags"] as String).split(",").map((e) => e.trim()).toList(),
        };
      }).toList();
    } else {
      throw Exception("Failed to search cars");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CarSearchDelegate(onSearch: searchCars),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService = AuthService();
              await authService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignupPage()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CarDetailPage(
                          carId: car['id'],
                          title: car['title'],
                          description: car['description'],
                          tags: List<String>.from(car['tags']),
                          images: List<String>.from(car['images']),
                        ),
                      ),
                    ).then((updated) {
                      if (updated == true) {
                        setState(() {
                          isLoading = true;
                        });

                        fetchCars();

                        setState(() {
                          isLoading = false;
                        });
                      }
                    });
                  },
                  child: CarCard(
                    images: car['images'],
                    title: car['title'],
                    description: car['description'],
                    tags: List<String>.from(car['tags']),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateProductPage(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CarSearchDelegate extends SearchDelegate {
  final Future<List> Function(String query) onSearch;

  CarSearchDelegate({required this.onSearch});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List>(
      future: onSearch(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final cars = snapshot.data!;
          return ListView.builder(
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return CarCard(
                images: car['images'],
                title: car['title'],
                description: car['description'],
                tags: List<String>.from(car['tags']),
              );
            },
          );
        } else {
          return const Center(child: Text('No results found.'));
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
        child: Text('Search for cars by title, description, or tags.'));
  }
}
