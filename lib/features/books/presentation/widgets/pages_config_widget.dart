import 'package:atiora/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:input_quantity/input_quantity.dart';

class PagesConfigWidget extends StatelessWidget {
  final int totalPages;
  final int currentPage;
  final ValueChanged<int> onTotalPagesChanged;
  final ValueChanged<int> onCurrentPageChanged;

  const PagesConfigWidget({
    super.key,
    required this.totalPages,
    required this.currentPage,
    required this.onTotalPagesChanged,
    required this.onCurrentPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Configuración de páginas",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.book,
                        color: AppColors.reading,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Total páginas",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.neutral400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InputQty.int(
                        key: ValueKey('totalPages_$totalPages'),
                        initVal: totalPages,
                        onQtyChanged: (val) {
                          if (val == null || val < 0) {
                            onTotalPagesChanged(0);
                          } else if (val > 5000) {
                            onTotalPagesChanged(5000);
                          } else {
                            onTotalPagesChanged(val as int);
                          }
                        },
                        maxVal: 5000,
                        minVal: 0,
                        decoration: QtyDecorationProps(
                          btnColor: Theme.of(context).primaryColor,
                          iconColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.visibility,
                        color: AppColors.completed,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Página actual",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.neutral400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InputQty.int(
                        key: ValueKey('currentPage_$currentPage'),
                        initVal: currentPage,
                        onQtyChanged: (val) {
                          if (val == null || val < 0) {
                            onCurrentPageChanged(0);
                          } else if (totalPages > 0 && val > totalPages) {
                            onCurrentPageChanged(totalPages);
                          } else {
                            onCurrentPageChanged(val as int);
                          }
                        },
                        maxVal: totalPages > 0 ? totalPages : 9999,
                        minVal: 0,
                        decoration: QtyDecorationProps(
                          btnColor: Theme.of(context).primaryColor,
                          iconColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
