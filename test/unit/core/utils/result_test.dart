import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_app/core/utils/result.dart';
import 'package:expense_tracker_app/core/exceptions/app_exceptions.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('should create success result with data', () {
        const data = 'test data';
        const result = Result.success(data);

        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
        expect(result.data, equals(data));
      });

      test('should execute success callback in when method', () {
        const data = 'test data';
        const result = Result.success(data);
        String? executedData;

        result.when(
          success: (data) => executedData = data,
          failure: (message, exception) => fail('Should not execute failure callback'),
        );

        expect(executedData, equals(data));
      });
    });

    group('Failure', () {
      test('should create failure result with message and exception', () {
        const message = 'Test error';
        final exception = AppException.validation('Validation failed');
        final result = Result<String>.failure(message, exception);

        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);
        expect(result.message, equals(message));
        expect(result.exception, equals(exception));
      });

      test('should execute failure callback in when method', () {
        const message = 'Test error';
        final exception = AppException.validation('Validation failed');
        final result = Result<String>.failure(message, exception);
        String? executedMessage;
        AppException? executedException;

        result.when(
          success: (data) => fail('Should not execute success callback'),
          failure: (message, exception) {
            executedMessage = message;
            executedException = exception;
          },
        );

        expect(executedMessage, equals(message));
        expect(executedException, equals(exception));
      });
    });

    group('Equality', () {
      test('should be equal for same success results', () {
        const result1 = Result.success('data');
        const result2 = Result.success('data');

        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('should be equal for same failure results', () {
        const message = 'Error';
        final exception = AppException.validation('Validation failed');
        final result1 = Result<String>.failure(message, exception);
        final result2 = Result<String>.failure(message, exception);

        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('should not be equal for different results', () {
        const successResult = Result.success('data');
        final failureResult = Result<String>.failure('Error', AppException.validation('Failed'));

        expect(successResult, isNot(equals(failureResult)));
      });
    });
  });
}