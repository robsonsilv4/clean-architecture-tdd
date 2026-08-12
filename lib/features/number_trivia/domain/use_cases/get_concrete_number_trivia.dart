import 'package:clean_architecture_tdd/core/errors/failures.dart';
import 'package:clean_architecture_tdd/core/use_cases/use_case.dart';
import 'package:clean_architecture_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class Params extends Equatable {
  const Params({required this.number});

  final int number;

  @override
  List<Object> get props => [number];
}

class GetConcreteNumberTrivia implements UseCase<NumberTrivia, Params> {
  GetConcreteNumberTrivia(this.repository);

  final NumberTriviaRepository repository;

  @override
  Future<Either<Failure, NumberTrivia>> call(Params params) async {
    return repository.getConcreteNumberTrivia(params.number);
  }
}
