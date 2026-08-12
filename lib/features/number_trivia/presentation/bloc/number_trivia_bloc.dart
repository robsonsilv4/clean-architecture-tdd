import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../../../core/utils/input_converter.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/use_cases/get_concrete_number_trivia.dart';
import '../../domain/use_cases/get_random_number_trivia.dart';
import 'bloc.dart';

const String SERVER_FAILURE_MESSAGE = 'Server failure.';
const String CACHE_FAILURE_MESSAGE = 'Cache failure.';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.getConcreteNumberTrivia,
    required this.getRandomNumberTrivia,
    required this.inputConverter,
  }) : super(Empty()) {
    on<GetTriviaForConcreteNumber>((event, emit) async {
      final inputEither = inputConverter.stringToUnsignedInteger(
        event.numberString,
      );
      inputEither.fold(
        (failure) => emit(Error(message: INVALID_INPUT_FAILURE_MESSAGE)),
        (integer) async {
          emit(Loading());
          final failureOrTrivia = await getConcreteNumberTrivia(
            Params(number: integer),
          );
          emit(_eitherLoadedOrErrorState(failureOrTrivia));
        },
      );
    });

    on<GetTriviaForRandomNumber>((event, emit) async {
      emit(Loading());
      final failureOrTrivia = await getRandomNumberTrivia(
        NoParams(),
      );
      emit(_eitherLoadedOrErrorState(failureOrTrivia));
    });
  }

  NumberTriviaState _eitherLoadedOrErrorState(
    Either<Failure, NumberTrivia> failureOrTrivia,
  ) {
    return failureOrTrivia.fold(
      (failure) => Error(
        message: _mapFailureToMessage(failure),
      ),
      (trivia) => Loaded(trivia: trivia),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected error.';
    }
  }
}
