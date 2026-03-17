import 'package:atiora/core/storage/hive_service.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';
import 'package:get_it/get_it.dart';

class ClearLocalDataUseCase {
  final HiveService _hiveService;
  final BooksRepository _booksRepository;

  ClearLocalDataUseCase(this._hiveService, this._booksRepository);

  Future<void> execute() async {
    await _hiveService.clearAllBooks();
    _booksRepository.resetSync();
  }
}

void registerClearLocalData(GetIt getIt) {
  getIt.registerLazySingleton<ClearLocalDataUseCase>(
    () => ClearLocalDataUseCase(getIt<HiveService>(), getIt<BooksRepository>()),
  );
}
