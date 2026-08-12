// The abstract base class is part of the course's clean architecture pattern.
// ignore_for_file: one_member_abstracts

import 'package:clean_architecture_tdd/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}

abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}
