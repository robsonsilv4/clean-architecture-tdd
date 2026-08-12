import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../errors/failures.dart';

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
