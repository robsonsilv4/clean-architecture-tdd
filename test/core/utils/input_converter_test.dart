import 'package:clean_architecture_tdd/core/errors/failures.dart';
import 'package:clean_architecture_tdd/core/utils/input_converter.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group('stringToUnsignedInt', () {
    test(
      'should return an integer when the string represents an unsigned integer',
      () async {
        const string = '123';

        final result = inputConverter.stringToUnsignedInteger(string);

        expect(result, const Right<Failure, int>(123));
      },
    );

    test(
      'should return a failure when the string is not an integer',
      () async {
        const string = 'abc';

        final result = inputConverter.stringToUnsignedInteger(string);

        expect(result, Left<Failure, int>(InvalidInputFailure()));
      },
    );

    test(
      'should return a failure when the string is a negative integer',
      () async {
        const string = '-123';

        final result = inputConverter.stringToUnsignedInteger(string);

        expect(result, Left<Failure, int>(InvalidInputFailure()));
      },
    );
  });
}
