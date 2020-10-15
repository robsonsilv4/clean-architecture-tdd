import 'dart:convert';

import 'package:clean_architecture_tdd/core/errors/exceptions.dart';
import 'package:clean_architecture_tdd/features/number_trivia/data/data_sources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  NumberTriviaLocalDataSourceImpl localDataSource;
  MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    localDataSource = NumberTriviaLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(
      json.decode(fixture('trivia_cached.json')),
    );

    test(
      'should return NumberTrivia from SharedPreferences when there is one in the cache',
      () async {
        when(mockSharedPreferences.getString(any)).thenReturn(
          fixture('trivia_cached.json'),
        );

        final result = await localDataSource.getLastNumberTrivia();

        verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a cache exception when there is not a cached value',
      () async {
        when(mockSharedPreferences.getString(any)).thenReturn(null);

        final call = localDataSource.getLastNumberTrivia;

        expect(() => call(), throwsA(TypeMatcher<CacheExpection>()));
      },
    );
  });

  group('cacheNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(
      text: 'Test trivia.',
      number: 1,
    );

    test(
      'should call SharedPreferences to cache the data',
      () async {
        localDataSource.cacheNumberTrivia(tNumberTriviaModel);

        final expectedJsonString = json.encode(tNumberTriviaModel.toJson());

        verify(
          mockSharedPreferences.setString(
            CACHED_NUMBER_TRIVIA,
            expectedJsonString,
          ),
        );
      },
    );
  });
}
