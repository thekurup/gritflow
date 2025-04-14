abstract class QuoteState {
  const QuoteState();
}

class QuoteInitial extends QuoteState {
  const QuoteInitial();
}

class QuoteLoading extends QuoteState {
  const QuoteLoading();
}

class QuoteLoaded extends QuoteState {
  final String quote;
  
  const QuoteLoaded(this.quote);
}

class QuoteError extends QuoteState {
  final String message;
  
  const QuoteError(this.message);
}