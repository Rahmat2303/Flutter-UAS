import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apple News',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class MyAppState extends ChangeNotifier {
  List<dynamic> favoriteArticles = [];

  void addToFavorites(dynamic article) {
    favoriteArticles.add(article);
    notifyListeners();
  }

  void removeFromFavorites(dynamic article) {
    favoriteArticles.remove(article);
    notifyListeners();
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
    final pageSize = 4;

    final url =
        'https://newsapi.org/v2/everything?q=apple&from=2023-07-02&to=2023-07-02&sortBy=popularity&apiKey=$apiKey&page=$page&pageSize=$pageSize';

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
        title: Text('Apple News'),
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
          final isFavorite = Provider.of<MyAppState>(context)
              .favoriteArticles
              .contains(article);

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
              trailing: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  final appState =
                      Provider.of<MyAppState>(context, listen: false);

                  if (isFavorite) {
                    appState.removeFromFavorites(article);
                  } else {
                    appState.addToFavorites(article);
                  }
                },
              ),
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

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> searchResults = [];
  bool isLoading = false;

  Future<void> searchNews(String keyword) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      searchResults.clear();
    });

    final apiKey = '2e8488957a83447eaa39850372f3d93b';
    final pageSize = 4;

    final url =
        'https://newsapi.org/v2/everything?q=$keyword&from=2023-06-03&sortBy=publishedAt&apiKey=$apiKey&page=1&pageSize=$pageSize';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final newArticles = jsonData['articles'] as List<dynamic>;

      setState(() {
        searchResults.addAll(newArticles);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to search news');
    }
  }

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
                searchNews(value);
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final article = searchResults[index];
                      final isFavorite = Provider.of<MyAppState>(context)
                          .favoriteArticles
                          .contains(article);

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
                          trailing: IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : null,
                            ),
                            onPressed: () {
                              final appState = Provider.of<MyAppState>(context,
                                  listen: false);

                              if (isFavorite) {
                                appState.removeFromFavorites(article);
                              } else {
                                appState.addToFavorites(article);
                              }
                            },
                          ),
                          onTap: () {
                            // Add the desired action when the item is tapped
                            print('Article tapped: ${article['title']}');
                          },
                        ),
                      );
                    },
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
      body: Consumer<MyAppState>(
        builder: (context, appState, _) {
          final favoriteArticles = appState.favoriteArticles;

          if (favoriteArticles.isEmpty) {
            return Center(child: Text('No favorite articles'));
          }

          return ListView.builder(
            itemCount: favoriteArticles.length,
            itemBuilder: (context, index) {
              final article = favoriteArticles[index];

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
                  trailing: IconButton(
                    icon: Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      final appState =
                          Provider.of<MyAppState>(context, listen: false);
                      appState.removeFromFavorites(article);
                    },
                  ),
                  onTap: () {
                    // Add the desired action when the item is tapped
                    print('Favorite article tapped: ${article['title']}');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
