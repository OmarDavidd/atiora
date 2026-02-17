import 'package:atiora/core/di/injection_container.dart';
import 'package:atiora/core/di/providers/auth_provider.dart';
import 'package:atiora/core/utils/app_colors.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';
import 'package:atiora/features/books/presentation/widgets/add_book_modal.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Atiora",
          style: GoogleFonts.jaini(
            fontSize: 30,
            fontWeight: FontWeight.w300,
            color: AppColors.neutral0,
            letterSpacing: 6,
            height: 1.0,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBookModal(context),
        icon: Icon(Icons.add),
        label: Text("Añadir libro"),
      ),
    );
  }
}

void _showAddBookModal(BuildContext context) {
  final authProvider = sl<AuthProvider>();
  final userId = authProvider.currentUser?.id.toString() ?? 'guest_user';

  final repository = sl<BooksRepository>(param1: userId);
  showDialog(
    context: context,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: AddBookModal(repository: repository),
    ),
  );
}
