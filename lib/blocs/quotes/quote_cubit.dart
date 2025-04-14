import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gritflow/blocs/quotes/quote_service.dart';

import 'package:gritflow/blocs/quotes/quote_state.dart';


class QuoteCubit extends Cubit<QuoteState> {
  // QuoteService as a dependency
  final QuoteService _quoteService;
  
  // Constructor takes QuoteService as a parameter
  QuoteCubit({required QuoteService quoteService})
      : _quoteService = quoteService,
        super(const QuoteInitial());
  
  Future<void> fetchQuote() async {
    try {
      // Emit loading state
      emit(const QuoteLoading());
      
      // Use the service to fetch a quote
      final quote = await _quoteService.fetchQuote();
      
      // Emit loaded state with the quote
      emit(QuoteLoaded(quote));
    } catch (e) {
      // Emit error state if something goes wrong
      emit(const QuoteError("Failed to fetch quote"));
    }
  }
}