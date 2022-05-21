class Quote {
  final String quote;
  final String author;
  final String title;

  Quote({
    required this.quote,
    required this.author,
    required this.title,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      quote: json['quote'],
      author: json['author'],
      title: json['title'],
    );
  }
}
