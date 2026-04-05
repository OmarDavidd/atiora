import 'package:atiora/core/di/injection_container.dart';
import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/data/models/note_model.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';
import 'package:atiora/features/books/domain/repositories/notes_repository.dart';
import 'package:atiora/features/books/presentation/bloc/books_bloc.dart';
import 'package:atiora/features/books/presentation/bloc/notes_event.dart';
import 'package:atiora/features/books/presentation/bloc/books_event.dart';
import 'package:atiora/features/books/presentation/bloc/books_state.dart';
import 'package:atiora/features/books/presentation/bloc/notes_bloc.dart';
import 'package:atiora/features/books/presentation/bloc/notes_state.dart';
import 'package:atiora/features/books/presentation/widgets/add_book_modal.dart';
import 'package:atiora/features/books/presentation/widgets/add_note_modal.dart';
import 'package:atiora/features/books/presentation/widgets/info_book_section.dart';
import 'package:atiora/features/books/presentation/widgets/notes_section.dart';
import 'package:atiora/features/books/presentation/widgets/progress_input_dialog.dart';
import 'package:atiora/features/books/presentation/widgets/rating_input_dialog.dart';
import 'package:atiora/features/books/presentation/widgets/stats_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late final NotesBloc _notesBloc;

  @override
  void initState() {
    super.initState();
    _notesBloc = sl<NotesBloc>();
    _notesBloc.add(LoadNotes(widget.bookId));
  }

  @override
  void dispose() {
    _notesBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _notesBloc,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 30,
          title: Text(
            "Detalles",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar libro',
              onPressed: () => _onEditTap(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Eliminar libro',
              onPressed: () => _onDeleteTap(context),
            ),
          ],
        ),
        body: BlocListener<BooksBloc, BooksState>(
          listener: (context, state) {
            if (state is BookUpdateError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is BookDeleteError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: BlocBuilder<BooksBloc, BooksState>(
            builder: (context, state) {
              if (state is BooksLoaded) {
                if (state.books.isEmpty) {
                  return const Center(child: Text('Libro no encontrado'));
                }

                final bookIndex = state.books.indexWhere(
                  (b) => b.id == widget.bookId,
                );
                final book = bookIndex != -1 ? state.books[bookIndex] : null;

                if (book == null) {
                  return const Center(child: Text('Libro no encontrado'));
                }

                return _buildContent(context, book);
              } else if (state is BooksLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is BooksError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BookModel book) {
    return RefreshIndicator(
      onRefresh: () async {
        _notesBloc.add(LoadNotes(widget.bookId));
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InfoBookSection(book: book),
              const SizedBox(height: 20),
              StatsSection(
                book: book,
                onProgressTap: (b) => _onProgressTap(context, b),
                onRatingTap: (b) => _onRatingTap(context, b),
              ),
              const SizedBox(height: 30),
              BlocBuilder<NotesBloc, NotesState>(
                builder: (context, state) {
                  List<NoteModel> notes = [];
                  bool isLoading = false;
                  String? errorMessage;

                  if (state is NotesLoaded && state.bookId == widget.bookId) {
                    notes = state.notes;
                  } else if (state is NotesLoading) {
                    isLoading = true;
                  } else if (state is NotesError &&
                      state.bookId == widget.bookId) {
                    errorMessage = state.message;
                    notes = state.previousNotes;
                  }

                  return NotesSection(
                    notes: notes,
                    isLoading: isLoading,
                    errorMessage: errorMessage,
                    onAddNote: () => _showAddNoteModal(context, book),
                    onEditNote: (note) => _showEditNoteModal(context, note),
                    onDeleteNote: (note) => _confirmDeleteNote(context, note),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onEditTap(BuildContext context) async {
    final bloc = context.read<BooksBloc>();
    final state = bloc.state;
    if (state is! BooksLoaded) return;

    final book = state.books.firstWhere(
      (b) => b.id == widget.bookId,
      orElse: () => throw StateError('Book not found'),
    );

    final repository = sl<BooksRepository>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar libro'),
        content: const Text('¿Deseas editar este libro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Editar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: AddBookModal(
          repository: repository,
          booksBloc: bloc,
          bookToEdit: book,
        ),
      ),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Libro actualizado')));
    }
  }

  Future<void> _onDeleteTap(BuildContext context) async {
    final bloc = context.read<BooksBloc>();
    final state = bloc.state;
    if (state is! BooksLoaded) return;

    final book = state.books.firstWhere(
      (b) => b.id == widget.bookId,
      orElse: () => throw StateError('Book not found'),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar libro'),
        content: Text(
          '¿Estás seguro de eliminar "${book.title}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    bloc.add(DeleteBookEvent(widget.bookId));

    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Libro eliminado')));
    }
  }

  void _onProgressTap(BuildContext context, BookModel book) {
    final bloc = context.read<BooksBloc>();
    showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProgressInputDialog(
        initialPage: book.currentPage,
        totalPages: book.totalPages,
      ),
    ).then((value) {
      if (value == null) return;
      final normalizedStatus = book.status.toLowerCase().trim();
      final newStatus = value >= book.totalPages
          ? 'Completado'
          : (value > 0 || normalizedStatus == 'leyendo'
                ? 'Leyendo'
                : 'Pendiente');
      bloc.add(
        UpdateBookState(
          bookId: book.id,
          newState: newStatus,
          updatedPage: value,
        ),
      );
    });
  }

  void _onRatingTap(BuildContext context, BookModel book) {
    final bloc = context.read<BooksBloc>();
    showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RatingInputDialog(initialValue: book.rating.toDouble()),
    ).then((value) {
      if (value == null) return;
      final normalizedStatus = book.status.toLowerCase().trim();
      final newStatus = value > 0 && normalizedStatus != 'completado'
          ? 'Completado'
          : book.status;
      bloc.add(
        UpdateBookState(bookId: book.id, newState: newStatus, rating: value),
      );
    });
  }

  Future<void> _showAddNoteModal(BuildContext context, BookModel book) async {
    final repository = sl<NotesRepository>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: _notesBloc,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AddNoteModal(
            repository: repository,
            notesBloc: _notesBloc,
            bookId: widget.bookId,
          ),
        ),
      ),
    );
  }

  Future<void> _showEditNoteModal(BuildContext context, NoteModel note) async {
    final repository = sl<NotesRepository>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: _notesBloc,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AddNoteModal(
            repository: repository,
            notesBloc: _notesBloc,
            bookId: widget.bookId,
            noteToEdit: note,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteNote(BuildContext context, NoteModel note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar nota'),
        content: const Text('¿Estás seguro de eliminar esta nota?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _notesBloc.add(DeleteNote(note.id, widget.bookId));
    }
  }
}
