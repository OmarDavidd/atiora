import 'package:atiora/core/di/injection_container.dart';
import 'package:atiora/core/di/providers/auth_provider.dart';
import 'package:atiora/core/utils/app_colors.dart';
import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';
import 'package:atiora/features/books/presentation/widgets/custom_genres_widget.dart';
import 'package:atiora/features/books/presentation/widgets/pages_config_widget.dart';
import 'package:atiora/features/books/presentation/widgets/progress_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AddBookModal extends StatefulWidget {
  final BooksRepository repository;
  const AddBookModal({super.key, required this.repository});

  @override
  State<AddBookModal> createState() => _AddBookModalState();
}

class _AddBookModalState extends State<AddBookModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  List<String> selectedGenres = [];
  int _totalPages = 1;
  int _currentPage = 1;
  bool isLoading = false;
  String? _errorMessage;
  String? _status;
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text(
                    "Añadir libro",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(flex: 2),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                validator: (value) =>
                    (value ?? '').trim().isEmpty ? 'Título requerido' : null,
                decoration: InputDecoration(
                  labelText: "Título *",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.book),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: "Autor",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Géneros",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              CustomGenresWidget(
                selectedGenres: selectedGenres,
                onGenreToggled: (genre) => setState(() {
                  if (selectedGenres.contains(genre)) {
                    selectedGenres.remove(genre);
                  } else {
                    selectedGenres.add(genre);
                  }
                }),
              ),
              SizedBox(height: 20),

              PagesConfigWidget(
                totalPages: _totalPages,
                currentPage: _currentPage,
                onTotalPagesChanged: (val) => setState(() => _totalPages = val),
                onCurrentPageChanged: (val) =>
                    setState(() => _currentPage = val),
              ),
              if (_errorMessage != null) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: AppColors.neutral0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ProgressSectionWidget(
                status: _status,
                rating: _rating,
                onStatusChanged: (val) {
                  setState(() {
                    _status = val;
                    if (_status != 'Completado') {
                      _rating = 0;
                    }
                  });
                },
                onRatingChanged: (val) {
                  setState(() => _rating = val);
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveBook,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Guardar libro",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveBook() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    if (selectedGenres.isEmpty) {
      setState(() => _errorMessage = 'Selecciona al menos un género');
      return;
    }

    if (_currentPage > _totalPages || _totalPages < 1 || _currentPage < 1) {
      setState(() => _errorMessage = 'Página actual ≤ total páginas');
      return;
    }

    if (_status == null) {
      setState(() => _errorMessage = 'Selecciona status');
      return;
    }
    if (_status == 'Completado' && _rating == 0) {
      setState(() => _errorMessage = 'Dale una calificación');
      return;
    }

    setState(() => isLoading = true);
    try {
      final authProvider = sl<AuthProvider>();
      final currentUser = authProvider.currentUser;

      print('Current user: $currentUser'); // DEBUG

      if (currentUser == null) {
        throw Exception('No autenticado');
      }

      final uuid = const Uuid().v4();
      final now = DateTime.now();

      final book = BookModel(
        id: uuid,
        userId: currentUser.id,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        genre: selectedGenres,
        totalPages: _totalPages,
        currentPage: _currentPage,
        status: _status!,
        rating: _rating.toDouble(),
        createdAt: now,
        updatedAt: now,
      );

      print('Saving book: ${book.toString()}'); // DEBUG

      await widget.repository.addBook(book);

      if (mounted) {
        Navigator.pop(context, book);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }
}
