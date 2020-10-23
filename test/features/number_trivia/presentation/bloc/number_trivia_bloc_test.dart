import 'package:clean_architecture_tdd/core/errors/failures.dart';
import 'package:clean_architecture_tdd/core/use_cases/use_case.dart';
import 'package:clean_architecture_tdd/core/utils/input_converter.dart';
import 'package:clean_architecture_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd/features/number_trivia/domain/use_cases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_tdd/features/number_trivia/domain/use_cases/get_random_number_trivia.dart';
import 'package:clean_architecture_tdd/features/number_trivia/presentation/bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConverter mockInputConverter;
  NumberTriviaBloc bloc;

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

  test('initial state should be Empty', () {
    expect(bloc.initialState, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    final tNumberString = "1";
    final tNumberParded = 1;
    final tNumberTrivia = NumberTrivia(text: 'Test trivia.', number: 1);

    void setUpMockInputConverterSuccess() => when(
          mockInputConverter.stringToUnsignedInteger(any),
        ).thenReturn(
          Right(tNumberParded),
        );

    test(
      'should call the InputConverter to validate and convert the string to an unsigned integer',
      () async {
        setUpMockInputConverterSuccess();

        bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(mockInputConverter.stringToUnsignedInteger(any));

        verify(
          mockInputConverter.stringToUnsignedInteger(tNumberString),
        );
      },
    );

    test('should emit error when the input is invalid', () async {
      when(
        mockInputConverter.stringToUnsignedInteger(any),
      ).thenReturn(
        Left(InvalidInputFailure()),
      );

      final expected = [
        Empty(),
        Error(message: INVALID_INPUT_FAILURE_MESSAGE),
      ];
      expectLater(
        bloc.state,
        emitsInOrder(expected),
      );

      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
    });

    test(
      'should get data from concrete use case',
      () async {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any)).thenAnswer(
          (_) async => Right(tNumberTrivia),
        );

        bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(mockGetConcreteNumberTrivia(any));

        verify(mockGetConcreteNumberTrivia(Params(number: tNumberParded)));
      },
    );

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any)).thenAnswer(
          (_) async => Right(tNumberTrivia),
        );

        final expected = [
          Empty(),
          Loading(),
          Loaded(trivia: tNumberTrivia),
        ];
        expectLater(bloc.state, emitsInOrder(expected));

        bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
      },
    );

    test(
      'should emit [Loading, Error] when gotting data fails',
      () async {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any)).thenAnswer(
          (_) async => Left(ServerFailure()),
        );

        final expected = [
          Empty(),
          Loading(),
          Error(message: SERVER_FAILURE_MESSAGE),
        ];
        expectLater(bloc.state, emitsInOrder(expected));

        bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
      },
    );

    test(
      '''should emit [Loading, Error] with a proper message
      for the error when getting data fails''',
      () async {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any)).thenAnswer(
          (_) async => Left(CacheFailure()),
        );

        final expected = [
          Empty(),
          Loading(),
          Error(message: CACHE_FAILURE_MESSAGE),
        ];
        expectLater(bloc.state, emitsInOrder(expected));

        bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
      },
    );
  });

  group('GetTriviaForRandomNumber', () {
    final tNumberTrivia = NumberTrivia(text: 'Test trivia.', number: 1);

    test(
      'should get data from random use case',
      () async {
        when(mockGetRandomNumberTrivia(any)).thenAnswer(
          (_) async => Right(tNumberTrivia),
        );

        bloc.dispatch(GetTriviaForRandomNumber());
        await untilCalled(mockGetRandomNumberTrivia(any));

        verify(mockGetRandomNumberTrivia(NoParams()));
      },
    );

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async {
        when(mockGetRandomNumberTrivia(any)).thenAnswer(
          (_) async => Right(tNumberTrivia),
        );

        final expected = [
          Empty(),
          Loading(),
          Loaded(trivia: tNumberTrivia),
        ];
        expectLater(bloc.state, emitsInOrder(expected));

        bloc.dispatch(GetTriviaForRandomNumber());
      },
    );

    test(
      'should emit [Loading, Error] when gotting data fails',
      () async {
        when(mockGetRandomNumberTrivia(any)).thenAnswer(
          (_) async => Left(ServerFailure()),
        );

        final expected = [
          Empty(),
          Loading(),
          Error(message: SERVER_FAILURE_MESSAGE),
        ];
        expectLater(bloc.state, emitsInOrder(expected));

        bloc.dispatch(GetTriviaForRandomNumber());
      },
    );

    test(
      '''should emit [Loading, Error] with a proper message
      for the error when getting data fails''',
      () async {
        when(mockGetRandomNumberTrivia(any)).thenAnswer(
          (_) async => Left(CacheFailure()),
        );

        final expected = [
          Empty(),
          Loading(),
          Error(message: CACHE_FAILURE_MESSAGE),
        ];
        expectLater(bloc.state, emitsInOrder(expected));

        bloc.dispatch(GetTriviaForRandomNumber());
      },
    );
  });
}
