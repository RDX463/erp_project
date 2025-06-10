import 'dart:convert';
import 'package:http/http.dart' as http;

class SentimentService {
  static const String apiUrl =
      'https://api-inference.huggingface.co/models/distilbert-base-uncased-finetuned-sst-2-english';
  static const String apiKey = 'YOUR_HUGGING_FACE_API_KEY'; // Replace with your API key

  Future<Map<String, dynamic>> analyzeSentiment(String text) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'inputs': text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Extract the highest-scoring sentiment
        final sentiment = data[0][0]['label'];
        final score = data[0][0]['score'];
        return {'sentiment': sentiment, 'score': score};
      } else {
        return {'sentiment': 'Error', 'score': 0.0};
      }
    } catch (e) {
      return {'sentiment': 'Error', 'score': 0.0};
    }
  }
}