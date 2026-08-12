import 'dart:convert';

import 'package:clean_architecture_tdd/core/errors/exceptions.dart';
import 'package:clean_architecture_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:http/http.dart' as http;

const numberTriviaBaseUrl = 'http://number-trivia.com';
const numberTriviaJsonQuery = '?json';
const numberTriviaRequestTimeout = Duration(seconds: 5);

abstract class NumberTriviaRemoteDataSource {
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number);
  Future<NumberTriviaModel> getRandomNumberTrivia();
}

class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  NumberTriviaRemoteDataSourceImpl({required this.client});

  final http.Client client;

  Future<NumberTriviaModel> _getTriviaFromUrl(String url) async {
    try {
      final response = await client
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(numberTriviaRequestTimeout);
      if (response.statusCode != 200) {
        throw ServerException();
      }
      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw ServerException();
      }
      return NumberTriviaModel.fromJson(decoded);
    } on Exception {
      throw ServerException();
    }
  }

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) =>
      _getTriviaFromUrl('$numberTriviaBaseUrl/$number$numberTriviaJsonQuery');

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() =>
      _getTriviaFromUrl('$numberTriviaBaseUrl/random$numberTriviaJsonQuery');
}
