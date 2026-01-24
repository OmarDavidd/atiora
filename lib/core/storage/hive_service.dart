import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/book_model.dart';
import '../../data/models/note_model.dart';
import '../../data/models/profile_model.dart';

class HiveService {
  static HiveService? _instance;
  static HiveService get instance => _instance ??= HiveService._();
  HiveService._();

  late Box<Map<String, dynamic>> booksBox;
  late Box<Map<String, dynamic>> notesBox;
  late Box<Map<String, dynamic>> profileBox;

  Future<void> init() async {
    await Hive.initFlutter();

    booksBox = await Hive.openBox('books');
    notesBox = await Hive.openBox('notes');
    profileBox = await Hive.openBox('profiles');
  }

  // BOOKS
  Future<void> saveBook(BookModel book) => booksBox.put(book.id, book.toJson());
  BookModel? getBook(String id) {
    final json = booksBox.get(id);
    return json != null ? BookModel.fromJson(json) : null;
  }

  List<BookModel> getAllBooks() {
    return booksBox.values.map((json) => BookModel.fromJson(json)).toList();
  }

  Future<void> deleteBook(String id) => booksBox.delete(id);

  // NOTES
  Future<void> saveNote(NoteModel note) => notesBox.put(note.id, note.toJson());
  NoteModel? getNote(String id) {
    final json = notesBox.get(id);
    return json != null ? NoteModel.fromJson(json) : null;
  }

  List<NoteModel> getNotesByBook(String bookId) {
    return notesBox.values
        .where((json) => (json as Map)['book_id'] == bookId)
        .map((json) => NoteModel.fromJson(json))
        .toList();
  }

  // PROFILE
  Future<void> saveProfile(ProfileModel profile) =>
      profileBox.put(profile.userId, profile.toJson());
  ProfileModel? getProfile(String userId) {
    final json = profileBox.get(userId);
    return json != null ? ProfileModel.fromJson(json) : null;
  }

  Future<void> close() async {
    await Hive.close();
  }
}
