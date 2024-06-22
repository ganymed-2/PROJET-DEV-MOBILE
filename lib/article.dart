class Article {
  final int id;
  final String title;
  final String content;
  final String timestamp;

  Article(
      {required this.id,
      required this.title,
      required this.content,
      required this.timestamp});

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      timestamp: map['timestamp'],
    );
  }
}
