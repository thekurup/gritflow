import 'dart:math';

// Abstract class (interface) for the quote service
abstract class QuoteService {
  // Method to fetch a quote asynchronously
  Future<String> fetchQuote();
}

// Implementation of the QuoteService
class DefaultQuoteService implements QuoteService {
  // Mock quotes list
  final List<String> _quotes = [
    "Start your day with water. One glass will energize you!",
    "Small steps every day lead to big results.",
    "Today is your opportunity to build the tomorrow you want.",
    "Your habits shape your future self.",
    "Consistency is the key to lasting change.",
    "Every effort counts, no matter how small.",
    "Take a deep breath and believe in yourself.",
    "Drink water first thing in the morning to boost your metabolism.",
    "The perfect time to start was yesterday. The next best time is now.",
    "You don't have to be perfect to make progress.",
  ];
  
  @override
  Future<String> fetchQuote() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Get random quote
    final random = Random();
    return _quotes[random.nextInt(_quotes.length)];
  }
}