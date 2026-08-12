import 'package:clean_architecture_tdd/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class InvalidInputFailure extends Failure {}

class InputConverter {
  Either<Failure, int> stringToUnsignedInteger(String string) {
    try {
      final integer = int.parse(string);
      if (integer < 0) {
        throw const FormatException();
      }
      return Right(integer);
    } on FormatException {
      return Left(InvalidInputFailure());
    }
  }
}
