import 'dart:async';

import 'package:clean_architecture_tdd/core/errors/failures.dart';
import 'package:clean_architecture_tdd/core/use_cases/use_case.dart';
import 'package:clean_architecture_tdd/core/utils/input_converter.dart';
import 'package:clean_architecture_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd/features/number_trivia/domain/use_cases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_tdd/features/number_trivia/domain/use_cases/get_random_number_trivia.dart';
import 'package:clean_architecture_tdd/features/number_trivia/presentation/bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  setUpAll(() {
    registerFallbackValue(const Params(number: 0));
    registerFallbackValue(NoParams());
  });

  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;
  late NumberTriviaBloc bloc;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
      getRandomNumberTrivia: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state should be Empty', () {
    expect(bloc.state, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    const tNumberString = '1';
    const tNumberParded = 1;
    const tNumberTrivia = NumberTrivia(text: 'Test trivia.', number: 1);

    void setUpMockInputConverterSuccess() =>
        when(
          () => mockInputConverter.stringToUnsignedInteger(any()),
        ).thenReturn(
          const Right(tNumberParded),
        );

    test(
      'should call the InputConverter to validate and convert the string to '
      'an unsigned integer',
      () async {
        setUpMockInputConverterSuccess();
        when(() => mockGetConcreteNumberTrivia(any())).thenAnswer(
          (_) async => const Right(tNumberTrivia),
        );

        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(
          () => mockInputConverter.stringToUnsignedInteger(any()),
        );

        verify(
          () => mockInputConverter.stringToUnsignedInteger(tNumberString),
        );
      },
    );

    test('should emit error when the input is invalid', () async {
      when(
        () => mockInputConverter.stringToUnsignedInteger(any()),
      ).thenReturn(
        Left(InvalidInputFailure()),
      );

      final expected = [
        Error(message: invalidInputFailureMessage),
      ];
      unawaited(expectLater(bloc.stream, emitsInOrder(expected)));

      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });

    test(
      'should get data from concrete use case',
      () async {
        setUpMockInputConverterSuccess();
        when(() => mockGetConcreteNumberTrivia(any())).thenAnswer(
          (_) async => const Right(tNumberTrivia),
        );

        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(() => mockGetConcreteNumberTrivia(any()));

        verify(
          () => mockGetConcreteNumberTrivia(
            const Params(number: tNumberParded),
          ),
        );
      },
    );

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async {
        setUpMockInputConverterSuccess();
        when(() => mockGetConcreteNumberTrivia(any())).thenAnswer(
          (_) async => const Right(tNumberTrivia),
        );

        final expected = [
          Loading(),
          Loaded(trivia: tNumberTrivia),
        ];
        unawaited(expectLater(bloc.stream, emitsInOrder(expected)));

        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
    );

    test(
      'should emit [Loading, Error] when gotting data fails',
      () async {
        setUpMockInputConverterSuccess();
        when(() => mockGetConcreteNumberTrivia(any())).thenAnswer(
          (_) async => Left(ServerFailure()),
        );

        final expected = [
          Loading(),
          Error(message: serverFailureMessage),
        ];
        unawaited(expectLater(bloc.stream, emitsInOrder(expected)));

        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
    );

    test(
      '''
should emit [Loading, Error] with a proper message
      for the error when getting data fails''',
      () async {
        setUpMockInputConverterSuccess();
        when(() => mockGetConcreteNumberTrivia(any())).thenAnswer(
          (_) async => Left(CacheFailure()),
        );

        final expected = [
          Loading(),
          Error(message: cacheFailureMessage),
        ];
        unawaited(expectLater(bloc.stream, emitsInOrder(expected)));

        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
    );

    test(
      'should emit [Loading, Error] when the use case throws an exception',
      () async {
        setUpMockInputConverterSuccess();
        when(() => mockGetConcreteNumberTrivia(any())).thenThrow(
          Exception('unexpected'),
        );

        final expected = [
          Loading(),
          Error(message: serverFailureMessage),
        ];
        unawaited(expectLater(bloc.stream, emitsInOrder(expected)));

        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
    );
  });

  group('GetTriviaForRandomNumber', () {
    const tNumberTrivia = NumberTrivia(text: 'Test trivia.', number: 1);

    test(
      'should get data from random use case',
      () async {
        when(() => mockGetRandomNumberTrivia(any())).thenAnswer(
          (_) async => const Right(tNumberTrivia),
        );

        bloc.add(GetTriviaForRandomNumber());
        await untilCalled(() => mockGetRandomNumberTrivia(any()));

        verify(() => mockGetRandomNumberTrivia(NoParams()));
      },
    );

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async {
        when(() => mockGetRandomNumberTrivia(any())).thenAnswer(
          (_) async => const Right(tNumberTrivia),
        );

        final expected = [
          Loading(),
          Loaded(trivia: tNumberTrivia),
        ];
        unawaited(expectLater(bloc.stream, emitsInOrder(expected)));

        bloc.add(GetTriviaForRandomNumber());
      },
    );

    test(
      'should emit [Loading, Error] when gotting data fails',
      () async {
        when(() => mockGetRandomNumberTrivia(any())).thenAnswer(
          (_) async => Left(ServerFailure()),
        );

        final expected = [
          Loading(),
          Error(message: serverFailureMessage),
        ];
        unawaited(expectLater(bloc.stream, emitsInOrder(expected)));

        bloc.add(GetTriviaForRandomNumber());
      },
    );

    test(
      '''
should emit [Loading, Error] with a proper message
      for the error when getting data fails''',
      () async {
        when(() => mockGetRandomNumberTrivia(any())).thenAnswer(
          (_) async => Left(CacheFailure()),
        );

        final expected = [
          Loading(),
          Error(message: cacheFailureMessage),
        ];
        unawaited(expectLater(bloc.stream, emitsInOrder(expected)));

        bloc.add(GetTriviaForRandomNumber());
      },
    );

    test(
      'should emit [Loading, Error] when the use case throws an exception',
      () async {
        when(() => mockGetRandomNumberTrivia(any())).thenThrow(
          Exception('unexpected'),
        );

        final expected = [
          Loading(),
          Error(message: serverFailureMessage),
        ];
        unawaited(expectLater(bloc.stream, emitsInOrder(expected)));

        bloc.add(GetTriviaForRandomNumber());
      },
    );
  });
}
