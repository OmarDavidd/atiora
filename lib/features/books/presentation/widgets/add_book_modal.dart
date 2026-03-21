import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:uuid/uuid.dart';

import 'package:atiora/core/di/injection_container.dart';
import 'package:atiora/core/di/providers/auth_provider.dart';
import 'package:atiora/core/storage/hive_service.dart';
import 'package:atiora/core/utils/constants.dart';
import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/domain/entities/add_book_draft.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';
import 'package:atiora/features/books/presentation/helpers/add_book_validation_helper.dart';
import 'package:atiora/features/books/presentation/widgets/add_book_body.dart';
import 'package:atiora/features/books/presentation/widgets/add_book_validation_tips.dart';

class AddBookModal extends StatefulWidget {
  final BooksRepository repository;
  final HiveService hiveService;

  AddBookModal({super.key, required this.repository, HiveService? hiveService})
    : hiveService = hiveService ?? HiveService.instance;

  @override
  State<AddBookModal> createState() => _AddBookModalState();
}

class _AddBookModalState extends State<AddBookModal> {
  static const _uuid = Uuid();

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _authorFocusNode = FocusNode();
  final _scrollController = ScrollController();
  final _titleFieldKey = GlobalKey();
  final _genresKey = GlobalKey();
  final _pagesKey = GlobalKey();
  final _statusKey = GlobalKey();
  Timer? _draftDebounce;
  List<String> selectedGenres = [];
  int _totalPages = 1;
  int _currentPage = 1;
  bool isLoading = false;
  String? _status;
  int _rating = 0;
  String? _errorMessage;
  bool _hasLoadedDraft = false;
  String? _currentUserId;
  bool _isOffline = false;
  bool _hasPendingQueue = false;
  List<AddBookValidationTip> _validationTips = [];
  bool _showGenresError = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool get _hasUnsavedChanges {
    return _titleController.text.trim().isNotEmpty ||
        _authorController.text.trim().isNotEmpty ||
        selectedGenres.isNotEmpty ||
        _totalPages != 1 ||
        _currentPage != 1 ||
        (_status?.isNotEmpty ?? false) ||
        _rating != 0;
  }

  AddBookDraft _buildDraft() {
    return AddBookDraft(
      title: _titleController.text,
      author: _authorController.text,
      genres: List<String>.from(selectedGenres),
      totalPages: _totalPages,
      currentPage: _currentPage,
      status: _status,
      rating: _rating,
    );
  }

  @override
  void initState() {
    super.initState();
    _hydrateDraft();
    _listenToConnectivity();
    _refreshPendingQueue();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        _handleClose(shouldPop: true);
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + viewInsets),
        child: AddBookBody(
          formKey: _formKey,
          scrollController: _scrollController,
          titleController: _titleController,
          authorController: _authorController,
          titleFocusNode: _titleFocusNode,
          authorFocusNode: _authorFocusNode,
          titleFieldKey: _titleFieldKey,
          genresKey: _genresKey,
          pagesKey: _pagesKey,
          statusKey: _statusKey,
          selectedGenres: selectedGenres,
          totalPages: _totalPages,
          currentPage: _currentPage,
          status: _status,
          rating: _rating,
          validationTips: _validationTips,
          errorMessage: _errorMessage,
          isLoading: isLoading,
          isOffline: _isOffline,
          hasPendingQueue: _hasPendingQueue,
          showGenresError: _showGenresError,
          canReset: _hasUnsavedChanges,
          onTitleChanged: () {
            setState(() => _removeTipSync('title'));
            _persistDraft();
          },
          onAuthorChanged: _persistDraft,
          onGenreChanged: (genre) {
            setState(() {
              if (selectedGenres.contains(genre)) {
                selectedGenres.remove(genre);
              } else {
                selectedGenres.add(genre);
              }
              _removeTipSync('genres');
              _showGenresError = selectedGenres.isEmpty;
            });
            _persistDraft();
          },
          onTotalPagesChanged: (val) {
            setState(() {
              _totalPages = val;
              _removeTipSync('pages');
            });
            _persistDraft();
          },
          onCurrentPageChanged: (val) {
            setState(() {
              _currentPage = val;
              _removeTipSync('pages');
            });
            _persistDraft();
          },
          onStatusChanged: (val) {
            setState(() {
              _status = val;
              if (_status != AppConstants.statusCompletado) {
                _rating = 0;
              }
              _removeTipSync('status');
              _removeTipSync('rating');
            });
            _persistDraft();
          },
          onRatingChanged: (val) {
            setState(() {
              _rating = val;
              _removeTipSync('rating');
            });
            _persistDraft();
          },
          onSave: _saveBook,
          onReset: _handleReset,
          onExit: () => _handleClose(),
        ),
      ),
    );
  }

  Future<void> _saveBook() async {
    setState(() {
      _errorMessage = null;
    });

    final tips = _collectValidationTips();
    final isFormValid = _formKey.currentState!.validate();
    if (tips.isNotEmpty || !isFormValid) {
      setState(() {
        _showGenresError = selectedGenres.isEmpty;
      });
      _showValidationTips(tips);
      if (tips.isNotEmpty) {
        tips.first.onTap?.call();
      }
      return;
    }

    _clearValidationTips();
    setState(() {
      _showGenresError = false;
    });

    setState(() => isLoading = true);
    try {
      FocusScope.of(context).unfocus();
      final authProvider = sl<AuthProvider>();
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        setState(
          () => _errorMessage = 'Debes iniciar sesión para añadir libros',
        );
        return;
      }

      final now = DateTime.now();

      final book = BookModel(
        id: _uuid.v4(),
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

      await widget.repository.addBook(book);
      _refreshPendingQueue();
      await _clearDraft();

      if (mounted) {
        Navigator.pop(context, book);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error al guardar el libro');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<bool> _handleClose({bool shouldPop = false}) async {
    if (!_hasUnsavedChanges || isLoading) {
      if (shouldPop) {
        return true;
      }
      if (mounted) {
        Navigator.pop(context);
      }
      return false;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Descartar cambios'),
        content: const Text(
          'Perderás la información ingresada. ¿Deseas salir sin guardar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Seguir editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _draftDebounce?.cancel();
      if (_hasUnsavedChanges) {
        await _clearDraft();
      }
      if (shouldPop) {
        return true;
      }
      if (mounted) {
        Navigator.pop(context);
      }
      return false;
    }

    return false;
  }

  Future<void> _handleReset() async {
    if (!_hasUnsavedChanges || isLoading) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Limpiar formulario'),
        content: const Text(
          'Se borrarán todos los campos completados. ¿Quieres continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Limpiar todo'),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    setState(() {
      _titleController.clear();
      _authorController.clear();
      selectedGenres.clear();
      _totalPages = 1;
      _currentPage = 1;
      _status = null;
      _rating = 0;
      _errorMessage = null;
      _validationTips = [];
      _showGenresError = false;
    });
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    await _clearDraft();
  }

  @override
  void dispose() {
    _draftDebounce?.cancel();
    if (_hasUnsavedChanges && _currentUserId != null) {
      _clearDraft();
    }
    _titleController.dispose();
    _authorFocusNode.dispose();
    _scrollController.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _hydrateDraft() async {
    final authProvider = sl<AuthProvider>();
    final currentUser = authProvider.currentUser;
    _currentUserId = currentUser?.id;
    if (currentUser == null || _hasLoadedDraft) {
      return;
    }
    final draft = widget.repository.getAddBookDraft(currentUser.id);
    if (draft != null) {
      setState(() {
        _applyDraft(draft);
        _hasLoadedDraft = true;
      });
    } else {
      setState(() {
        _hasLoadedDraft = true;
      });
    }
  }

  Future<void> _persistDraft() async {
    _draftDebounce?.cancel();
    _draftDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (_currentUserId == null) return;
      await widget.repository.saveAddBookDraft(_currentUserId!, _buildDraft());
    });
  }

  Future<void> _clearDraft() async {
    if (_currentUserId == null) return;
    await widget.repository.clearAddBookDraft(_currentUserId!);
  }

  void _listenToConnectivity() {
    ConnectivityPlatform.instance.checkConnectivity().then(_updateOfflineState);
    _connectivitySubscription = ConnectivityPlatform
        .instance
        .onConnectivityChanged
        .listen(_updateOfflineState);
  }

  void _updateOfflineState(List<ConnectivityResult> results) {
    final offline =
        results.isEmpty ||
        results.every((result) => result == ConnectivityResult.none);
    if (mounted && offline != _isOffline) {
      setState(() {
        _isOffline = offline;
      });
    }
  }

  Future<void> _refreshPendingQueue() async {
    final hasPending =
        (await widget.hiveService.getPendingOperations()).isNotEmpty;
    if (mounted && hasPending != _hasPendingQueue) {
      setState(() {
        _hasPendingQueue = hasPending;
      });
    }
  }

  List<AddBookValidationTip> _collectValidationTips() {
    return AddBookValidationHelper.collect(
      title: _titleController.text,
      selectedGenres: List<String>.from(selectedGenres),
      totalPages: _totalPages,
      currentPage: _currentPage,
      status: _status,
      rating: _rating,
      onTitleTap: () {
        _scrollToKey(_titleFieldKey);
        _titleFocusNode.requestFocus();
      },
      onGenresTap: () => _scrollToKey(_genresKey),
      onPagesTap: () => _scrollToKey(_pagesKey),
      onStatusTap: () => _scrollToKey(_statusKey),
      onRatingTap: () => _scrollToKey(_statusKey),
    );
  }

  void _scrollToKey(GlobalKey key) {
    final targetContext = key.currentContext;
    if (targetContext == null) return;
    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: 0.1,
    );
  }

  void _showValidationTips(List<AddBookValidationTip> tips) {
    setState(() {
      _validationTips = tips;
    });
  }

  void _clearValidationTips() {
    if (_validationTips.isEmpty) return;
    setState(() {
      _validationTips = [];
    });
  }

  void _removeTipSync(String id) {
    _validationTips = _validationTips.where((tip) => tip.id != id).toList();
  }

  void _applyDraft(AddBookDraft draft) {
    _titleController.text = draft.title;
    _authorController.text = draft.author;
    selectedGenres = List<String>.from(draft.genres);
    _totalPages = draft.totalPages;
    _currentPage = draft.currentPage;
    _status = draft.status;
    _rating = draft.rating;
  }
}
