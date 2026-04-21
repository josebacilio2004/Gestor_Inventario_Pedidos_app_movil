import 'package:flutter/material.dart';
import 'package:gestor_invetarios_pedidos_app/core/theme/app_theme.dart';

class CustomDataTable extends StatelessWidget {
  final List<String> headers;
  final List<List<dynamic>> rows;
  final List<double> columnWidths;
  final Function(int)? onEdit;
  final Function(int)? onDelete;
  final bool showActions;

  const CustomDataTable({
    super.key,
    required this.headers,
    required this.rows,
    required this.columnWidths,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
              child: Row(
                children: [
                  ...List.generate(headers.length, (i) => SizedBox(
                    width: columnWidths[i],
                    child: Text(
                      headers[i].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textGray,
                        letterSpacing: 1.2,
                      ),
                    ),
                  )),
                  if (showActions)
                    const SizedBox(
                      width: 80,
                      child: Text(
                        'ACCIONES',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textGray,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Rows
            ...rows.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              final isLast = index == rows.length - 1;

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  color: index % 2 == 0 ? Colors.transparent : Colors.white.withOpacity(0.01),
                  border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.03))),
                ),
                child: Row(
                  children: [
                    ...List.generate(row.length, (i) {
                      final cellContent = row[i];
                      return SizedBox(
                        width: columnWidths[i],
                        child: _buildCell(cellContent),
                      );
                    }),
                    if (showActions)
                      SizedBox(
                        width: 80,
                        child: Row(
                          children: [
                            _actionIcon(Icons.edit_outlined, Colors.blueAccent, () {
                              if (onEdit != null) onEdit!(index);
                            }),
                            const SizedBox(width: 8),
                            _actionIcon(Icons.delete_outline, Colors.redAccent, () {
                              if (onDelete != null) onDelete!(index);
                            }),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(dynamic content) {
    if (content is Widget) return content;

    final str = content.toString();
    Color textColor = Colors.white70;
    FontWeight weight = FontWeight.w500;

    if (str.contains('S/')) {
      textColor = str.contains('0.00') ? AppTheme.textGray : (str.contains('✅') ? AppTheme.successGreen : Colors.white);
      weight = FontWeight.w900;
    } else if (str == 'COMPLETADO' || str == 'ACEPTADO' || str == 'OK') {
      textColor = AppTheme.successGreen;
      weight = FontWeight.w900;
    } else if (str == 'PENDIENTE' || str == 'VENCIDO') {
      textColor = AppTheme.errorRed;
      weight = FontWeight.w900;
    }

    return Text(
      str,
      style: TextStyle(
        fontSize: 10,
        color: textColor,
        fontWeight: weight,
      ),
    );
  }

  Widget _actionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}
