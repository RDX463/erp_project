import 'package:flutter/material.dart';
import '../services/sentiment_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _controller = TextEditingController();
  String _sentiment = '';
  double _score = 0.0;
  bool _isLoading = false;

  void _analyzeFeedback() async {
    setState(() {
      _isLoading = true;
    });
    final service = SentimentService();
    final result = await service.analyzeSentiment(_controller.text);
    setState(() {
      _sentiment = result['sentiment'];
      _score = result['score'];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback Analysis')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter feedback',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _analyzeFeedback,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Analyze Sentiment'),
            ),
            const SizedBox(height: 16),
            if (_sentiment.isNotEmpty)
              Text(
                'Sentiment: $_sentiment (Confidence: ${(_score * 100).toStringAsFixed(2)}%)',
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}