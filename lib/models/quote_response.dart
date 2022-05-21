import 'package:indra/models/quote.dart';

class QuoteResponse {
  final Quote quote;

  const QuoteResponse({
    required this.quote,
  });

  factory QuoteResponse.fromJson(Map<String, dynamic> json) {
    var quotes = json['contents']['quotes'] as List;
    return QuoteResponse(
      quote: Quote.fromJson(quotes[0]),
    );
  }
}
