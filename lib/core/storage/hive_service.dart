import 'package:flutter/foundation.dart';
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

  Future<List<BookModel>> getAllBooks() async {
    final keys = booksBox.keys.toList();
    final rawBooks = <Map<dynamic, dynamic>>[];

    for (final key in keys) {
      final raw = booksBox.get(key);
      if (raw != null && raw is Map) {
        rawBooks.add(Map<dynamic, dynamic>.from(raw));
      }
    }

    if (rawBooks.isEmpty) return [];

    return compute(_parseBooks, rawBooks);
  }

  Future<BookModel?> getBook(String id) async {
    final raw = booksBox.get(id);
    if (raw == null) return null;
    if (raw is! Map) return null;

    final json = <String, dynamic>{};
    (raw as Map<dynamic, dynamic>).forEach((k, v) => json[k.toString()] = v);

    return compute(_parseBook, json);
  }

  Future<void> deleteBook(String id) => booksBox.delete(id);

  Future<void> saveNote(NoteModel note) => notesBox.put(note.id, note.toJson());

  Future<List<NoteModel>> getAllNotes() async {
    final keys = notesBox.keys.toList();
    final rawNotes = <Map<dynamic, dynamic>>[];

    for (final key in keys) {
      final raw = notesBox.get(key);
      if (raw != null && raw is Map) {
        rawNotes.add(Map<dynamic, dynamic>.from(raw));
      }
    }

    if (rawNotes.isEmpty) return [];

    return compute(_parseNotes, rawNotes);
  }

  Future<NoteModel?> getNote(String id) async {
    final raw = notesBox.get(id);
    if (raw == null) return null;
    if (raw is! Map) return null;

    final json = <String, dynamic>{};
    (raw as Map<dynamic, dynamic>).forEach((k, v) => json[k.toString()] = v);

    return NoteModel.fromJson(json);
  }

  Future<void> deleteNote(String id) => notesBox.delete(id);

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

  Future<List<MapEntry<String, Map<String, dynamic>>>>
  getPendingOperations() async {
    final ops = <MapEntry<String, Map<String, dynamic>>>[];

    for (final key in pendingOpsBox.keys) {
      final value = pendingOpsBox.get(key);
      if (value is Map) {
        final normalized = <String, dynamic>{};
        value.forEach((k, v) => normalized[k.toString()] = v);
        ops.add(MapEntry(key.toString(), normalized));
      }
    }

    return ops;
  }

  Future<void> removePendingOperation(String key) async =>
      pendingOpsBox.delete(key);

  Future<void> clearAllPendingOperations() async {
    await pendingOpsBox.clear();
  }

  Future<void> close() async => await Hive.close();

  String _addBookDraftKey(String userId) => 'add_book_$userId';
}

List<BookModel> _parseBooks(List<Map<dynamic, dynamic>> rawBooks) {
  final books = <BookModel>[];
  for (final raw in rawBooks) {
    try {
      final json = <String, dynamic>{};
      raw.forEach((k, v) => json[k.toString()] = v);
      books.add(BookModel.fromJson(json));
    } catch (_) {}
  }
  return books;
}

BookModel _parseBook(Map<String, dynamic> json) {
  return BookModel.fromJson(json);
}

List<NoteModel> _parseNotes(List<Map<dynamic, dynamic>> rawNotes) {
  final notes = <NoteModel>[];
  for (final raw in rawNotes) {
    try {
      final json = <String, dynamic>{};
      raw.forEach((k, v) => json[k.toString()] = v);
      notes.add(NoteModel.fromJson(json));
    } catch (_) {}
  }
  return notes;
}
