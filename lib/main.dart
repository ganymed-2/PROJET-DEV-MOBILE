import 'package:flutter/material.dart';
import 'package:flutter_application_1/db_helper.dart';
import 'package:flutter_application_1/article.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Correction de ligne 10

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key); // Correction de ligne 22

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Article> _articles = [];

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    final dbHelper = DBHelper();
    final articlesData = await dbHelper.getAllArticles();
    if (mounted) {
      setState(() {
        _articles =
            articlesData.map((article) => Article.fromMap(article)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Blog App'),
      ),
      body: ListView.builder(
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          final article = _articles[index];
          return ListTile(
            title: Text(article.title),
            subtitle: Text(article.timestamp),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ArticleDetailsScreen(articleId: article.id)),
              ).then((_) {
                // Refresh articles when returning from details screen
                _loadArticles();
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AddArticleScreen(onArticleAdded: _loadArticles)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddArticleScreen extends StatefulWidget {
  final VoidCallback onArticleAdded;

  const AddArticleScreen({Key? key, required this.onArticleAdded})
      : super(key: key); // Correction de ligne 94

  @override
  AddArticleScreenState createState() => AddArticleScreenState();
}

class AddArticleScreenState extends State<AddArticleScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Article'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final title = _titleController.text;
                final content = _contentController.text;
                if (title.isNotEmpty && content.isNotEmpty) {
                  final dbHelper = DBHelper();
                  await dbHelper.addArticle(title, content);
                  if (mounted) {
                    widget.onArticleAdded();
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleDetailsScreen extends StatelessWidget {
  final int articleId;

  const ArticleDetailsScreen({Key? key, required this.articleId})
      : super(key: key); // Correction de ligne 151

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: DBHelper().getArticleById(articleId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Article not found'));
          } else {
            final article = Article.fromMap(snapshot.data!);
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(article.title,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text(article.content, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  Text(article.timestamp,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
