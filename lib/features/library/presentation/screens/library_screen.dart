import 'package:atiora/core/di/injection_container.dart';
import 'package:atiora/core/navigation/app_router.dart';
import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';
import 'package:atiora/features/books/presentation/bloc/books_bloc.dart';
import 'package:atiora/features/books/presentation/bloc/books_event.dart';
import 'package:atiora/features/books/presentation/bloc/books_state.dart';
import 'package:atiora/features/books/presentation/widgets/add_book_modal.dart';
import 'package:atiora/features/library/presentation/widgets/library_book_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  static const _filters = [
    _LibraryFilter('todos', 'Todos'),
    _LibraryFilter('leyendo', 'Leyendo'),
    _LibraryFilter('completado', 'Completados'),
    _LibraryFilter('pausado', 'Pausados'),
    _LibraryFilter('pendiente', 'Pendientes'),
  ];

  late final BooksBloc _booksBloc;
  String _activeFilter = _filters.first.value;

  @override
  void initState() {
    super.initState();
    _booksBloc = sl<BooksBloc>()..add(LoadBooks());
  }

  @override
  void dispose() {
    _booksBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BooksBloc>.value(
      value: _booksBloc,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildTabs(context),
                const SizedBox(height: 16),
                Expanded(child: _buildContent(context)),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openAddBookModal(context),
          icon: const Icon(Icons.add),
          label: const Text('Agregar libro'),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      titleSpacing: 24,
      centerTitle: false,
      title: Text(
        'Biblioteca',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          tooltip: 'Filtrar biblioteca',
          icon: const Icon(Icons.filter_list),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildTabs(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: _filters.map((filter) {
          final isActive = _activeFilter == filter.value;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(filter.label),
              selected: isActive,
              onSelected: (_) => _onFilterChanged(filter.value),
              selectedColor: colors.primary.withValues(alpha: 0.18),
              backgroundColor: colors.surfaceContainerHighest,
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isActive ? colors.primary : colors.onSurfaceVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: BorderSide(
                  color: isActive
                      ? colors.primary
                      : colors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return BlocBuilder<BooksBloc, BooksState>(
      builder: (context, state) {
        if (state is BooksLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is BooksError) {
          return _LibraryMessage(
            icon: Icons.error_outline,
            message: state.message,
            onRetry: () => _booksBloc.add(LoadBooks()),
          );
        }
        if (state is BooksLoaded) {
          final books = _filteredBooks(state.books);
          if (books.isEmpty) {
            return _LibraryMessage(
              icon: Icons.menu_book_outlined,
              message: _emptyMessage,
              onRetry: state.books.isEmpty
                  ? () => _openAddBookModal(context)
                  : null,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _booksBloc.add(LoadBooks()),
            child: ListView.separated(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.only(bottom: 120),
              itemBuilder: (context, index) {
                final book = books[index];
                return LibraryBookCard(
                  book: book,
                  onTap: () => _openBookDetail(context, book),
                );
              },
              separatorBuilder: (context, _) => const SizedBox(height: 16),
              itemCount: books.length,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _onFilterChanged(String value) {
    if (_activeFilter == value) return;
    setState(() => _activeFilter = value);
  }

  List<BookModel> _filteredBooks(List<BookModel> books) {
    final sorted = List<BookModel>.from(books)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    if (_activeFilter == 'todos') {
      return sorted;
    }
    return sorted
        .where(
          (book) => book.status.toLowerCase() == _activeFilter.toLowerCase(),
        )
        .toList();
  }

  Future<void> _openAddBookModal(BuildContext context) async {
    final repository = sl<BooksRepository>();
    final result = await showDialog<BookModel?>(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: AddBookModal(repository: repository),
      ),
    );
    if (result != null) {
      _booksBloc.add(LoadBooks());
    }
  }

  void _openBookDetail(BuildContext context, BookModel book) {
    Navigator.of(context).pushNamed(
      AppRouter.bookDetail,
      arguments: {'bookId': book.id, 'booksBloc': _booksBloc},
    );
  }

  String get _emptyMessage {
    switch (_activeFilter) {
      case 'leyendo':
        return 'Aún no tienes libros en lectura activa.';
      case 'completado':
        return 'Cuando termines un libro lo verás aquí.';
      case 'pausado':
        return 'Ningún libro está pausado en este momento.';
      case 'pendiente':
        return 'No hay lecturas pendientes por comenzar.';
      default:
        return 'Comienza añadiendo tus primeros libros.';
    }
  }
}

class _LibraryFilter {
  final String value;
  final String label;

  const _LibraryFilter(this.value, this.label);
}

class _LibraryMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  const _LibraryMessage({
    required this.icon,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          SizedBox(
            width: 260,
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Actualizar')),
          ],
        ],
      ),
    );
  }
}
