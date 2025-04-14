import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:gritflow/blocs/quotes/quote_cubit.dart';
import 'package:gritflow/blocs/quotes/quote_state.dart';
import 'package:gritflow/blocs/quotes/quote_service.dart';

// This tells Mockito to create a fake QuoteService for us
@GenerateMocks([QuoteService])
import 'quote_service_test.mocks.dart'; // This file will be generated for us

void main() {
  // STEP 1: Create our mock and the component we're testing
  late MockQuoteService mockQuoteService;
  late QuoteCubit quoteCubit;

  // STEP 2: This runs before each test to set up fresh components
  setUp(() {
    // Create a fake QuoteService that we can control
    mockQuoteService = MockQuoteService();
    
    // Create our real QuoteCubit but with the fake service
    quoteCubit = QuoteCubit(quoteService: mockQuoteService);
  });

  // STEP 3: This runs after each test to clean up
  tearDown(() {
    // Always close cubits after testing
    quoteCubit.close();
  });

  // STEP 4: Group our tests together
  group('QuoteCubit Tests', () {
    // STEP 5: Test the initial state
    test('should start with QuoteInitial state', () {
      expect(quoteCubit.state, isA<QuoteInitial>());
    });

    // STEP 6: Test the successful quote fetch flow
    blocTest<QuoteCubit, QuoteState>(
      'when fetchQuote succeeds, it should emit loading then the quote',
      
      // STEP 7: Set up our fake service to return a specific quote
      build: () {
        // This tells our fake service: "When someone calls fetchQuote(), 
        // don't actually fetch anything, just return this test quote"
        when(mockQuoteService.fetchQuote())
            .thenAnswer((_) async => 'Stay strong, you\'re doing great!');
        
        return quoteCubit;
      },
      
      // STEP 8: Call the method we want to test
      act: (cubit) => cubit.fetchQuote(),
      
      // STEP 9: Wait a bit for async code to finish
      wait: const Duration(milliseconds: 100),
      
      // STEP 10: Check that we get the expected states in the right order
      // UPDATED: Using matchers instead of concrete instances
      expect: () => [
        // First state should be loading
        isA<QuoteLoading>(),
        
        // Second state should be loaded with our specific quote
        predicate<QuoteState>((state) => 
          state is QuoteLoaded && 
          state.quote == 'Stay strong, you\'re doing great!'
        ),
      ],
      
      // STEP 11: Verify that our service was actually called
      verify: (_) {
        // Make sure fetchQuote was called exactly once
        verify(mockQuoteService.fetchQuote()).called(1);
      },
    );

    // STEP 12: Test what happens when things go wrong
    blocTest<QuoteCubit, QuoteState>(
      'when fetchQuote fails, it should emit loading then error',
      
      build: () {
        // This time, tell our fake service to throw an error
        when(mockQuoteService.fetchQuote())
            .thenThrow(Exception('Something went wrong'));
        
        return quoteCubit;
      },
      
      act: (cubit) => cubit.fetchQuote(),
      
      // UPDATED: Using matchers for error state too
      expect: () => [
        // First state should be loading
        isA<QuoteLoading>(),
        
        // Second state should be error with our specific message
        predicate<QuoteState>((state) => 
          state is QuoteError && 
          state.message == 'Failed to fetch quote'
        ),
      ],
    );
  });
}