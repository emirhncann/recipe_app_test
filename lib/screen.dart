import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Screen1 extends StatefulWidget {
  const Screen1({Key? key}) : super(key: key);

  @override
  _Screen1State createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  List<String> ingredients = [
    'tomato',
    'milk',
    "oil"
  ]; // Malzemeleri tutacak liste
  List<String> recipes = []; // Tarifleri tutacak liste

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen 1'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Malzemeler:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Chip(
                      label: Text(ingredients[index]),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchRecipes,
              child: const Text('Tarifleri Bul'),
            ),
            SizedBox(height: 16),
            Text(
              'Tarifler:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: recipes.isEmpty
                  ? Center(
                      child: Text('Tarif bulunamadı.'),
                    )
                  : ListView.builder(
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(recipes[index]),
                          onTap: () {
                            fetchRecipeDetails(recipes[index]);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchRecipes() async {
    final apiKey =
        'c09738cb0fe4473784dafda3b321f2dd'; // Spoonacular API anahtarını buraya ekleyin

    List<String> combinedIngredients = [];

    // Malzemeleri sırayla birbiriyle kombinasyon yaparak yeni bir liste oluştur
    for (int i = 0; i < ingredients.length; i++) {
      for (int j = i + 1; j < ingredients.length; j++) {
        combinedIngredients.add('${ingredients[i]},${ingredients[j]}');
      }
    }

    List<String> newRecipes = [];

    // Kombine edilmiş malzemelerle sorguları yap ve tarifleri al
    for (int i = 0; i < combinedIngredients.length; i++) {
      final url = Uri.parse(
          'https://api.spoonacular.com/recipes/findByIngredients?apiKey=$apiKey&ingredients=${combinedIngredients[i]}&number=5');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final List<String> recipes =
            data.map<String>((recipe) => recipe['title'] as String).toList();

        newRecipes.addAll(recipes);
      } else {
        throw ('Tarifler alınırken bir hata oluştu');
      }
    }

    setState(() {
      recipes = newRecipes;
    });
  }

  Future<void> fetchRecipeDetails(String recipeTitle) async {
    final apiKey =
        'd030d986bfd8febc17fb3e8da91dcf12c57d30498f5386680bcb253a8a9b0125'; // SerpApi API anahtarını buraya ekleyin

    final url = Uri.parse(
        'https://serpapi.com/search?q=$recipeTitle&hl=tr&gl=tr&api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data.isEmpty ||
          data['organic_results'] == null ||
          data['organic_results'].isEmpty) {
        throw Exception('Tarif detayları bulunamadı');
      }

      final recipeDetails = data['organic_results'][0];
      final recipeImage = recipeDetails['thumbnail'];
      final recipeLink = recipeDetails['link'];

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(recipeTitle),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recipeImage != null)
                  Image.network(
                    recipeImage,
                    width: 200,
                    height: 200,
                  ),
                Text('Recipe:'),
                Text(recipeDetails['snippet']),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                // Open the recipe link in the browser
                launch(recipeLink);
              },
              child: Text('Link'),
            ),
          ],
        ),
      );
    } else {
      throw Exception('Tarif detayları alınırken bir hata oluştu');
    }
  }
}
