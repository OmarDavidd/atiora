import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:atiora/core/di/injection_container.dart';
import 'package:atiora/core/di/providers/auth_provider.dart';
import 'package:atiora/core/utils/app_colors.dart';
import 'package:atiora/core/utils/constants.dart';
import 'package:atiora/core/utils/helpers.dart';
import 'package:atiora/data/models/note_model.dart';
import 'package:atiora/features/books/domain/repositories/notes_repository.dart';
import 'package:atiora/features/books/presentation/bloc/notes_bloc.dart';
import 'package:atiora/features/books/presentation/bloc/notes_event.dart';

class AddNoteModal extends StatefulWidget {
  final NotesRepository repository;
  final NotesBloc notesBloc;
  final String bookId;
  final NoteModel? noteToEdit;

  const AddNoteModal({
    super.key,
    required this.repository,
    required this.notesBloc,
    required this.bookId,
    this.noteToEdit,
  });

  bool get isEditing => noteToEdit != null;

  @override
  State<AddNoteModal> createState() => _AddNoteModalState();
}

class _AddNoteModalState extends State<AddNoteModal> {
  static const _uuid = Uuid();

  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _pageController = TextEditingController();
  final _contentFocusNode = FocusNode();
  String _selectedType = AppConstants.noteTypeResumen;
  bool isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadNoteData(widget.noteToEdit!);
    }
  }

  void _loadNoteData(NoteModel note) {
    _contentController.text = note.content;
    _selectedType = note.noteType;
    if (note.pageNumber != null) {
      _pageController.text = note.pageNumber.toString();
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _pageController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + viewInsets),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              _buildHeader(theme),
              const SizedBox(height: 20),
              _buildTypeSelector(theme),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildContentField(theme, isDark),
                      const SizedBox(height: 16),
                      _buildPageField(theme, isDark),
                    ],
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                _buildError(theme),
              ],
              const SizedBox(height: 20),
              _buildActions(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.isEditing ? 'Editar nota' : 'Nueva nota',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
        ),
      ],
    );
  }

  Widget _buildTypeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de nota',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.noteTypes.map((type) {
            final isSelected = _selectedType == type;
            final color = AppHelpers.getNoteTypeColor(type);
            final icon = AppHelpers.getNoteTypeIcon(type);

            return GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.15)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? color
                        : theme.colorScheme.outline.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 6),
                    Text(
                      _formatTypeLabel(type),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected ? color : theme.colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContentField(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contenido',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _contentController,
          focusNode: _contentFocusNode,
          maxLines: null,
          minLines: 4,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: 'Escribe tu nota, reflexión, análisis...',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            filled: true,
            fillColor: isDark
                ? theme.colorScheme.surfaceContainerHighest
                : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: theme.textTheme.bodyMedium,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El contenido es obligatorio';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPageField(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Página (opcional)',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _pageController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Número de página',
            prefixIcon: Icon(
              Icons.book_outlined,
              color: theme.colorScheme.outline,
            ),
            filled: true,
            fillColor: isDark
                ? theme.colorScheme.surfaceContainerHighest
                : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final page = int.tryParse(value);
              if (page == null || page < 1) {
                return 'Ingresa un número válido';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildError(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: isLoading ? null : _saveNote,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(widget.isEditing ? 'Guardar' : 'Añadir'),
          ),
        ),
      ],
    );
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = sl<AuthProvider>();
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        setState(() {
          _errorMessage = 'Debes iniciar sesión para añadir notas';
          isLoading = false;
        });
        return;
      }

      final now = DateTime.now();
      final pageNumber = _pageController.text.isNotEmpty
          ? int.tryParse(_pageController.text)
          : null;

      if (widget.isEditing) {
        final updatedNote = widget.noteToEdit!.copyWith(
          content: _contentController.text.trim(),
          noteType: _selectedType,
          pageNumber: pageNumber,
          updatedAt: now,
        );
        widget.notesBloc.add(UpdateNote(updatedNote));
      } else {
        final newNote = NoteModel(
          id: _uuid.v4(),
          bookId: widget.bookId,
          userId: currentUser.id,
          noteType: _selectedType,
          content: _contentController.text.trim(),
          pageNumber: pageNumber,
          createdAt: now,
          updatedAt: now,
        );
        widget.notesBloc.add(AddNote(newNote));
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al guardar la nota';
        isLoading = false;
      });
    }
  }

  String _formatTypeLabel(String type) {
    switch (type) {
      case 'resumen':
        return 'Resumen';
      case 'análisis':
        return 'Análisis';
      case 'cita':
        return 'Cita';
      case 'reflexión':
        return 'Reflexión';
      case 'pregunta':
        return 'Pregunta';
      default:
        return type;
    }
  }
}
