import 'package:flutter/material.dart';
import 'package:atiora/core/utils/helpers.dart';
import 'package:atiora/data/models/note_model.dart';

class RecentNotesSection extends StatelessWidget {
  final List<NoteModel> notes;
  final bool isLoading;
  final VoidCallback? onViewAll;
  final Function(NoteModel)? onNoteTap;

  const RecentNotesSection({
    super.key,
    required this.notes,
    this.isLoading = false,
    this.onViewAll,
    this.onNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_alt_outlined,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'NOTAS RECIENTES',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            if (onViewAll != null)
              TextButton(onPressed: onViewAll, child: const Text('Ver todas')),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (notes.isEmpty)
          _buildEmpty(context, isDark)
        else
          _buildNotesList(context, isDark),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 32,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'Aún no hay notas',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList(BuildContext context, bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final note = notes[index];
        return GestureDetector(
          onTap: onNoteTap != null ? () => onNoteTap!(note) : null,
          child: _RecentNoteCard(note: note, isDark: isDark),
        );
      },
    );
  }
}

class _RecentNoteCard extends StatelessWidget {
  final NoteModel note;
  final bool isDark;

  const _RecentNoteCard({required this.note, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final noteColor = AppHelpers.getNoteTypeColor(note.noteType);
    final noteIcon = AppHelpers.getNoteTypeIcon(note.noteType);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: noteColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(noteIcon, color: noteColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.content,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatType(note.noteType),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: noteColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (note.pageNumber != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.book_outlined,
                        size: 12,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'pg.${note.pageNumber}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatType(String type) {
    switch (type.toLowerCase()) {
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
