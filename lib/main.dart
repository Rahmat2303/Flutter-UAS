import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tesla News',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> articles = [];
  int page = 1;
  bool isLoading = false;
  bool isLastPage = false;

  Future<void> fetchNews() async {
    if (isLoading || isLastPage) return;

    final apiKey = '2e8488957a83447eaa39850372f3d93b';
    final pageSize = 10;

    final url =
        'https://newsapi.org/v2/everything?q=tesla&from=2023-06-03&sortBy=publishedAt&apiKey=$apiKey&page=$page&pageSize=$pageSize';

    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final newArticles = jsonData['articles'] as List<dynamic>;

      if (newArticles.isEmpty) {
        setState(() {
          isLastPage = true;
          isLoading = false;
        });
      } else {
        setState(() {
          articles.addAll(newArticles);
          page++;
          isLoading = false;
        });
      }
    } else {
      throw Exception('Failed to fetch news');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  void loadMoreData() {
    fetchNews();
  }

  void navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchPage()),
    );
  }

  void navigateToFavorite() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FavoritePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tesla News'),
      ),
      body: ListView.builder(
        itemCount: articles.length + 1,
        itemBuilder: (context, index) {
          if (index == articles.length) {
            if (isLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (isLastPage) {
              return Center(child: Text('No more articles'));
            } else {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  child: Text('Load More'),
                  onPressed: loadMoreData,
                ),
              );
            }
          }

          final article = articles[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: article['urlToImage'] != null
                  ? Image.network(
                      article['urlToImage'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Container(),
              title: Text(article['title']),
              subtitle: Text(article['description']),
              onTap: () {
                // Add the desired action when the item is tapped
                print('Article tapped: ${article['title']}');
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 56.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: navigateToSearch,
              ),
              IconButton(
                icon: Icon(Icons.favorite),
                onPressed: navigateToFavorite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                // Perform search operation based on the entered value
              },
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                // Display search results here
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: Center(
        child: Text('Favorite articles'),
      ),
    );
  }
}
