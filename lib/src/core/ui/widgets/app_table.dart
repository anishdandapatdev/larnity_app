import 'package:flutter/material.dart';

class TableColumn {
  final String title;
  final double width;
  final Widget Function(int rowIndex) cellBuilder;

  TableColumn({
    required this.title,
    this.width = 120.0,
    required this.cellBuilder,
  });
}

class AppTable extends StatelessWidget {
  final List<TableColumn> columns;
  final int rowCount;
  final double headerHeight;
  final double rowHeight;
  final Color headerColor;
  final Color borderColor;
  final TextStyle? headerTextStyle;
  final EdgeInsetsGeometry cellPadding;

  /// NEW: Optional table constraints
  final double? height;
  final double? width;

  /// NEW: Widget to show when no rows exist
  final Widget? emptyWidget;

  const AppTable({
    super.key,
    required this.columns,
    required this.rowCount,
    this.headerHeight = 50.0,
    this.rowHeight = 60.0,
    this.headerColor = const Color(0xFF2D2D2D),
    this.borderColor = const Color(0xFF444444),
    this.headerTextStyle,
    this.cellPadding = const EdgeInsets.symmetric(
      horizontal: 12.0,
      vertical: 8.0,
    ),
    this.height,
    this.width,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    final ScrollController horizontalController = ScrollController();
    final ScrollController verticalController = ScrollController();

    Widget bodyContent;
    if (rowCount == 0) {
      // Show empty widget in center
      bodyContent = SizedBox(
        height: height != null ? height! - headerHeight : 200,
        child: Center(
          child:
              emptyWidget ??
              const Text(
                "No data available",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
        ),
      );
    } else if (height != null) {
      // Scrollable vertically
      bodyContent = Expanded(
        child: Scrollbar(
          controller: verticalController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: verticalController,
            child: Column(
              children: List.generate(rowCount, (rowIndex) {
                return _buildRow(rowIndex);
              }),
            ),
          ),
        ),
      );
    } else {
      // Non-scrollable
      bodyContent = Column(
        children: List.generate(rowCount, (rowIndex) {
          return _buildRow(rowIndex);
        }),
      );
    }

    return Container(
      height: height, // expands if null
      width: width, // expands if null
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Scrollbar(
        controller: horizontalController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: horizontalController,
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: columns.fold(0, (sum, col) => sum + col.width),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  height: headerHeight,
                  decoration: BoxDecoration(
                    color: headerColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(7.0),
                      topRight: Radius.circular(7.0),
                    ),
                  ),
                  child: Row(
                    children: columns.map((column) {
                      return Container(
                        width: column.width,
                        height: headerHeight,
                        padding: cellPadding,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: borderColor, width: 0.5),
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            column.title,
                            style:
                                headerTextStyle ??
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Body
                bodyContent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(int rowIndex) {
    return Container(
      height: rowHeight,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: Row(
        children: columns.map((column) {
          return Container(
            width: column.width,
            height: rowHeight,
            padding: cellPadding,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: borderColor, width: 0.5)),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: column.cellBuilder(rowIndex),
            ),
          );
        }).toList(),
      ),
    );
  }
}
