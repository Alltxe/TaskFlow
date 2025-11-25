import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/data/repositories/auth_repository.dart';
import 'package:taskflow/domain/usecases/auth/logout_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'logout_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LogoutUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LogoutUseCase(mockRepository);
  });

  group('LogoutUseCase -', () {
    test('should call repository logout', () async {
      // arrange
      when(mockRepository.logout()).thenAnswer((_) async => {});

      // act
      await useCase();

      // assert
      verify(mockRepository.logout());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw exception when repository throws', () async {
      // arrange
      when(mockRepository.logout()).thenThrow(Exception('Logout failed'));

      // act & assert
      expect(() => useCase(), throwsA(isA<Exception>()));
      verify(mockRepository.logout());
    });
  });
}
