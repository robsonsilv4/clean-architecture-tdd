import 'package:clean_architecture_tdd/core/utils/input_converter.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group('stringToUnsignedInt', () async {
    test(
      'should return an integer when the string represents an unsigned integer',
      () async {
        final string = '123';

        final result = inputConverter.stringToUnsignedInteger(string);

        expect(result, Right(123));
      },
    );

    test(
      'should return a failure when the string is not an integer',
      () async {
        final string = 'abc';

        final result = inputConverter.stringToUnsignedInteger(string);

        expect(result, Left(InvalidInputFailure()));
      },
    );

    test(
      'should return a failure when the string is a negative integer',
      () async {
        final string = '-123';

        final result = inputConverter.stringToUnsignedInteger(string);

        expect(result, Left(InvalidInputFailure()));
      },
    );
  });
}
