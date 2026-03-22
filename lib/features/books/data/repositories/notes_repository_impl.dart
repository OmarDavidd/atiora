import 'package:atiora/core/errors/app_exception.dart';
import 'package:atiora/core/storage/hive_service.dart';
import 'package:atiora/core/utils/constants.dart';
import 'package:atiora/data/models/note_model.dart';
import 'package:atiora/features/books/data/datasources/notes_local_datasource.dart';
import 'package:atiora/features/books/data/datasources/notes_remote_datasource.dart';
import 'package:atiora/features/books/domain/repositories/notes_repository.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource _local;
  final NotesRemoteDataSource _remote;
  final ConnectivityPlatform _connectivity;
  final HiveService _hive;

  NotesRepositoryImpl(
    this._local,
    this._remote, {
    ConnectivityPlatform? connectivity,
    HiveService? hive,
  }) : _connectivity = connectivity ?? ConnectivityPlatform.instance,
       _hive = hive ?? HiveService.instance;

  @override
  Future<List<NoteModel>> getNotesByBook(String bookId) async {
    try {
      await processPendingNotesOperations();
    } catch (_) {}

    try {
      final remoteNotes = await _remote.getNotesByBook(bookId);
      await _syncLocalNotes(remoteNotes, bookId);
      return remoteNotes;
    } catch (e) {
      final localNotes = await _local.getNotesByBook(bookId);
      return localNotes;
    }
  }

  Future<void> _syncLocalNotes(
    List<NoteModel> remoteNotes,
    String bookId,
  ) async {
    await _hive.deleteNote(bookId);
    for (final note in remoteNotes) {
      await _local.addNote(note);
    }
  }

  @override
  Future<NoteModel?> getNote(String id) async {
    return await _local.getNote(id);
  }

  @override
  Future<void> addNote(NoteModel note) async {
    final isOnline = await _isOnline();

    try {
      await _local.addNote(note);
    } catch (e, stackTrace) {
      throw AppException.cache(
        'No pudimos guardar la nota localmente',
        cause: e,
        stackTrace: stackTrace,
      );
    }

    if (isOnline) {
      try {
        await _remote.addNote(note);
      } catch (e, stackTrace) {
        final pendingNote = note.copyWith(updatedAt: DateTime.now());
        await _local.updateNote(pendingNote);
        await _queueOperation(
          PendingOperationType.noteAdd,
          payload: pendingNote.toJson(),
        );
        throw AppException.network(
          'Error al sincronizar la nota; guardada offline',
          cause: e,
          stackTrace: stackTrace,
        );
      }
    } else {
      await _queueOperation(
        PendingOperationType.noteAdd,
        payload: note.toJson(),
      );
    }
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    final isOnline = await _isOnline();
    final updatedNote = note.copyWith(updatedAt: DateTime.now());

    try {
      await _local.updateNote(updatedNote);
    } catch (e, stackTrace) {
      throw AppException.cache(
        'No pudimos actualizar la nota localmente',
        cause: e,
        stackTrace: stackTrace,
      );
    }

    if (isOnline) {
      try {
        await _remote.updateNote(updatedNote);
      } catch (e, stackTrace) {
        await _local.updateNote(
          updatedNote.copyWith(updatedAt: DateTime.now()),
        );
        await _queueOperation(
          PendingOperationType.noteUpdate,
          payload: updatedNote.toJson(),
        );
        throw AppException.network(
          'Error al actualizar la nota en la nube; reintentaremos',
          cause: e,
          stackTrace: stackTrace,
        );
      }
    } else {
      await _queueOperation(
        PendingOperationType.noteUpdate,
        payload: updatedNote.toJson(),
      );
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    final isOnline = await _isOnline();

    try {
      await _local.deleteNote(id);
    } catch (e, stackTrace) {
      throw AppException.cache(
        'No pudimos eliminar la nota localmente',
        cause: e,
        stackTrace: stackTrace,
      );
    }

    if (isOnline) {
      try {
        await _remote.deleteNote(id);
      } catch (e, stackTrace) {
        await _queueOperation(PendingOperationType.noteDelete, noteId: id);
        throw AppException.network(
          'No se pudo eliminar la nota en la nube; reintentaremos',
          cause: e,
          stackTrace: stackTrace,
        );
      }
    } else {
      await _queueOperation(PendingOperationType.noteDelete, noteId: id);
    }
  }

  Future<bool> _isOnline() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    if (connectivityResults.isEmpty) {
      return false;
    }
    return connectivityResults.any(
      (result) => result != ConnectivityResult.none,
    );
  }

  @override
  Future<void> processPendingNotesOperations() async {
    if (!await _isOnline()) return;

    final pending = await _hive.getPendingOperations();
    final noteOps = pending.where((entry) {
      final type = entry.value['type'] as String?;
      return type == PendingOperationType.noteAdd ||
          type == PendingOperationType.noteUpdate ||
          type == PendingOperationType.noteDelete;
    }).toList();

    for (final entry in noteOps) {
      final key = entry.key;
      final op = entry.value;
      final type = op['type'] as String?;

      try {
        switch (type) {
          case PendingOperationType.noteAdd:
            final payload = Map<String, dynamic>.from(op['payload'] as Map);
            final note = NoteModel.fromJson(payload);
            await _remote.addNote(note);
            break;
          case PendingOperationType.noteUpdate:
            final payload = Map<String, dynamic>.from(op['payload'] as Map);
            final note = NoteModel.fromJson(payload);
            await _remote.updateNote(note);
            break;
          case PendingOperationType.noteDelete:
            await _remote.deleteNote(op['noteId'] as String);
            break;
        }
        await _hive.removePendingOperation(key);
      } catch (_) {
        await _hive.removePendingOperation(key);
      }
    }
  }

  Future<void> _queueOperation(
    String type, {
    Map<String, dynamic>? payload,
    String? noteId,
  }) async {
    await _hive.enqueuePendingOperation({
      'type': type,
      if (payload != null) 'payload': payload,
      if (noteId != null) 'noteId': noteId,
    });
  }
}
