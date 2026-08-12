import 'package:clean_architecture_tdd/core/errors/exceptions.dart';
import 'package:clean_architecture_tdd/core/errors/failures.dart';
import 'package:clean_architecture_tdd/core/network/network_info.dart';
import 'package:clean_architecture_tdd/features/number_trivia/data/data_sources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_tdd/features/number_trivia/data/data_sources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture_tdd/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:clean_architecture_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  setUpAll(() {
    registerFallbackValue(const NumberTriviaModel(number: 0, text: ''));
  });

  late NumberTriviaRepositoryImpl repositoryImpl;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repositoryImpl = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(void Function() body) {
    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockLocalDataSource.cacheNumberTrivia(any()),
        ).thenAnswer((_) async {});
      });

      body();
    });
  }

  void runTestsOffline(void Function() body) {
    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    const tText = 'Test trivia.';
    const tNumberTriviaModel = NumberTriviaModel(
      number: tNumber,
      text: tText,
    );
    const tNumberTrivia = tNumberTriviaModel;

    test('should check if device is online', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.getConcreteNumberTrivia(any()),
      ).thenAnswer((_) async => tNumberTriviaModel);
      when(
        () => mockLocalDataSource.cacheNumberTrivia(any()),
      ).thenAnswer((_) async {});

      await repositoryImpl.getConcreteNumberTrivia(tNumber);

      verify(() => mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test(
        'should return remote data when the call to remote data source is '
        'successful',
        () async {
          when(
            () => mockRemoteDataSource.getConcreteNumberTrivia(any()),
          ).thenAnswer(
            (_) async => tNumberTriviaModel,
          );

          final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

          verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          expect(
            result,
            equals(const Right<Failure, NumberTrivia>(tNumberTrivia)),
          );
        },
      );

      test(
        'should cache the data locally when the call to remote data source is '
        'successful',
        () async {
          when(
            () => mockRemoteDataSource.getConcreteNumberTrivia(any()),
          ).thenAnswer(
            (_) async => tNumberTriviaModel,
          );

          await repositoryImpl.getConcreteNumberTrivia(tNumber);

          verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verify(
            () => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel),
          );
        },
      );

      test(
        'should return server failure when the call to remote data source is '
        'unsuccessful',
        () async {
          when(
            () => mockRemoteDataSource.getConcreteNumberTrivia(any()),
          ).thenThrow(
            ServerException(),
          );

          final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

          verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left<Failure, NumberTrivia>(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      test(
        'should return last locally data when the cached data is present',
        () async {
          when(
            () => mockLocalDataSource.getLastNumberTrivia(),
          ).thenAnswer(
            (_) async => tNumberTriviaModel,
          );

          final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(
            result,
            equals(const Right<Failure, NumberTrivia>(tNumberTrivia)),
          );
        },
      );

      test(
        'should return cache failure when there is no cached present',
        () async {
          when(
            () => mockLocalDataSource.getLastNumberTrivia(),
          ).thenThrow(CacheException());

          final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left<Failure, NumberTrivia>(CacheFailure())));
        },
      );
    });
  });

  group('getRandomNumberTrivia', () {
    const tNumberTriviaModel = NumberTriviaModel(
      number: 123,
      text: 'Test trivia.',
    );
    const tNumberTrivia = tNumberTriviaModel;

    test('should check if device is online', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.getRandomNumberTrivia(),
      ).thenAnswer((_) async => tNumberTriviaModel);
      when(
        () => mockLocalDataSource.cacheNumberTrivia(any()),
      ).thenAnswer((_) async {});

      await repositoryImpl.getRandomNumberTrivia();

      verify(() => mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test(
        'should return remote data when the call to remote data source is '
        'successful',
        () async {
          when(() => mockRemoteDataSource.getRandomNumberTrivia()).thenAnswer(
            (_) async => tNumberTriviaModel,
          );

          final result = await repositoryImpl.getRandomNumberTrivia();

          verify(() => mockRemoteDataSource.getRandomNumberTrivia());
          expect(
            result,
            equals(const Right<Failure, NumberTrivia>(tNumberTrivia)),
          );
        },
      );

      test(
        'should cache the data locally when the call to remote data source is '
        'successful',
        () async {
          when(() => mockRemoteDataSource.getRandomNumberTrivia()).thenAnswer(
            (_) async => tNumberTriviaModel,
          );

          await repositoryImpl.getRandomNumberTrivia();

          verify(() => mockRemoteDataSource.getRandomNumberTrivia());
          verify(
            () => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel),
          );
        },
      );

      test(
        'should return server failure when the call to remote data source is '
        'unsuccessful',
        () async {
          when(
            () => mockRemoteDataSource.getRandomNumberTrivia(),
          ).thenThrow(
            ServerException(),
          );

          final result = await repositoryImpl.getRandomNumberTrivia();

          verify(() => mockRemoteDataSource.getRandomNumberTrivia());
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left<Failure, NumberTrivia>(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      test(
        'should return last locally data when the cached data is present',
        () async {
          when(
            () => mockLocalDataSource.getLastNumberTrivia(),
          ).thenAnswer(
            (_) async => tNumberTriviaModel,
          );

          final result = await repositoryImpl.getRandomNumberTrivia();

          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(
            result,
            equals(const Right<Failure, NumberTrivia>(tNumberTrivia)),
          );
        },
      );

      test(
        'should return cache failure when there is no cached present',
        () async {
          when(
            () => mockLocalDataSource.getLastNumberTrivia(),
          ).thenThrow(CacheException());

          final result = await repositoryImpl.getRandomNumberTrivia();

          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left<Failure, NumberTrivia>(CacheFailure())));
        },
      );
    });
  });
}
