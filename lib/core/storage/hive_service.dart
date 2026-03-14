import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/book_model.dart';
import '../../data/models/note_model.dart';
import '../../data/models/profile_model.dart';
import 'package:atiora/features/books/domain/entities/add_book_draft.dart';

class HiveService {
  static HiveService? _instance;
  static HiveService get instance => _instance ??= HiveService._();
  HiveService._();

  late Box<dynamic> booksBox;
  late Box<dynamic> notesBox;
  late Box<dynamic> profileBox;
  late Box<dynamic> pendingOpsBox;
  late Box<dynamic> draftsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    booksBox = await Hive.openBox('books');
    notesBox = await Hive.openBox('notes');
    profileBox = await Hive.openBox('profiles');
    pendingOpsBox = await Hive.openBox('pending_ops');
    draftsBox = await Hive.openBox('drafts');
  }

  Future<void> saveBook(BookModel book) async {
    await booksBox.put(book.id, book.toJson());
  }

  Future<void> clearAllBooks() async {
    await booksBox.clear();
  }

  Future<void> saveAllBooks(List<BookModel> books) async {
    final map = {for (var b in books) b.id: b.toJson()};
    await booksBox.putAll(map);
  }

  List<BookModel> getAllBooks() {
    final List<BookModel> books = [];
    for (int i = 0; i < booksBox.length; i++) {
      final dynamic raw = booksBox.getAt(i);
      if (raw != null) {
        try {
          final Map<String, dynamic> json = <String, dynamic>{};
          final map = raw as Map<dynamic, dynamic>;
          map.forEach((dynamic k, dynamic v) => json[k.toString()] = v);
          final book = BookModel.fromJson(json);
          books.add(book);
        } catch (e) {
          debugPrint('HiveService.getAllBooks skipping invalid entry: $e');
        }
      }
    }
    return books;
  }

  BookModel? getBook(String id) {
    final raw = booksBox.get(id);
    if (raw == null) return null;
    final Map<String, dynamic> json = {};
    (raw as Map).forEach((k, v) => json[k.toString()] = v);
    return BookModel.fromJson(json);
  }

  Future<void> deleteBook(String id) => booksBox.delete(id);

  Future<void> saveNote(NoteModel note) => notesBox.put(note.id, note.toJson());
  Future<void> saveProfile(ProfileModel profile) =>
      profileBox.put(profile.userId, profile.toJson());

  Future<void> saveAddBookDraft(String userId, AddBookDraft draft) async {
    await draftsBox.put(_addBookDraftKey(userId), draft.toJson());
  }

  AddBookDraft? getAddBookDraft(String userId) {
    final raw = draftsBox.get(_addBookDraftKey(userId));
    if (raw is! Map) return null;
    final normalized = <String, dynamic>{};
    raw.forEach((key, value) => normalized[key.toString()] = value);
    return AddBookDraft.fromJson(normalized);
  }

  Future<void> clearAddBookDraft(String userId) async {
    await draftsBox.delete(_addBookDraftKey(userId));
  }

  Future<String> enqueuePendingOperation(Map<String, dynamic> operation) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await pendingOpsBox.put(id, operation);
    return id;
  }

  List<MapEntry<String, Map<String, dynamic>>> getPendingOperations() {
    final ops = <MapEntry<String, Map<String, dynamic>>>[];
    for (final key in pendingOpsBox.keys) {
      final value = pendingOpsBox.get(key);
      if (value is Map) {
        final Map<String, dynamic> normalized = {};
        value.forEach((key, val) => normalized[key.toString()] = val);
        ops.add(MapEntry(key.toString(), normalized));
      }
    }
    return ops;
  }

  Future<void> removePendingOperation(String key) async =>
      pendingOpsBox.delete(key);

  Future<void> close() async => await Hive.close();

  String _addBookDraftKey(String userId) => 'add_book_$userId';
}
