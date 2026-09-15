import 'package:flutter/material.dart';
import '''
package:syncfusion_flutter_datepicker/datepicker.dart''';
import 'package:larnity/src/core/theme/app_colors.dart';

// Controller class to manage dropdown state externally
class DatePickerDropdownController {
  _DatePickerDropdownState? _state;

  void _attach(_DatePickerDropdownState state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  /// Close the dropdown from outside
  void close() {
    _state?._closeDropdown();
  }

  /// Open the dropdown from outside
  void open() {
    _state?._openDropdown();
  }

  /// Toggle the dropdown from outside
  void toggle() {
    _state?._toggleDropdown();
  }

  /// Check if dropdown is currently open
  bool get isOpen => _state?._isOpen ?? false;
}

class DatePickerDropdown extends StatefulWidget {
  const DatePickerDropdown({
    super.key,
    this.selectedDate,
    this.onDateSelected,
    this.minDate,
    this.maxDate,
    this.dateFormat = 'MMM dd, yyyy',
    this.placeholder = 'Select Date',
    this.enableRangeSelection = false,
    this.enableMultiSelection = false,
    this.buttonDecoration,
    this.buttonPadding,
    this.buttonTextStyle,
    this.overlayWidth = 320,
    this.overlayHeight = 450,
    this.controller,
    this.readOnly = false,
    this.showTodayButton = true,
    this.showClearButton = true,
    this.headerStyle,
    this.yearCellStyle,
    this.monthCellStyle,
    this.initialDisplayDate,
    this.allowViewNavigation = true,
    this.enablePastDates = true,
    this.weekendDays = const <int>[DateTime.saturday, DateTime.sunday],
    this.specialDates,
    this.blackoutDates,
    this.selectableDayPredicate,
    this.overlayAlignment = Alignment.centerLeft,
    this.gapFromButton = 8.0,
    this.buttonHeight = 48.0,
    this.overlayColor,
    this.overlayBorderRadius = 12.0,
    this.elevation = 8.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.barrierColor,
    this.onSelectionChanged,
    this.showActionButtons = true,
    this.confirmButtonText = 'Select',
    this.cancelButtonText = 'Cancel',
    this.todayButtonText = 'Today',
    this.clearButtonText = 'Clear',
    required this.button,
  });
  final Widget button;
  // Basic properties
  final DateTime? selectedDate;
  final Function(DateTime?)? onDateSelected;
  final DateTime? minDate;
  final DateTime? maxDate;
  final String dateFormat;
  final String placeholder;
  final bool enableRangeSelection;
  final bool enableMultiSelection;

  // Button styling
  final BoxDecoration? buttonDecoration;
  final EdgeInsets? buttonPadding;
  final TextStyle? buttonTextStyle;
  final double buttonHeight;

  // Overlay properties
  final double overlayWidth;
  final double overlayHeight;
  final AlignmentGeometry overlayAlignment;
  final double gapFromButton;
  final Color? overlayColor;
  final double overlayBorderRadius;
  final double elevation;
  final Duration animationDuration;
  final Color? barrierColor;

  // Controller
  final DatePickerDropdownController? controller;
  final bool readOnly;

  // Calendar features
  final bool showTodayButton;
  final bool showClearButton;
  final bool showActionButtons;
  final DateRangePickerHeaderStyle? headerStyle;
  final DateRangePickerYearCellStyle? yearCellStyle;
  final DateRangePickerMonthCellStyle? monthCellStyle;
  final DateTime? initialDisplayDate;
  final bool allowViewNavigation;
  final bool enablePastDates;
  final List<int> weekendDays;
  final List<DateTime>? specialDates;
  final List<DateTime>? blackoutDates;
  final bool Function(DateTime)? selectableDayPredicate;
  final Function(DateRangePickerSelectionChangedArgs)? onSelectionChanged;

  // Button texts
  final String confirmButtonText;
  final String cancelButtonText;
  final String todayButtonText;
  final String clearButtonText;

  @override
  State<DatePickerDropdown> createState() => _DatePickerDropdownState();
}

class _DatePickerDropdownState extends State<DatePickerDropdown>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  DateTime? _tempSelectedDate;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _tempSelectedDate = widget.selectedDate;

    // Initialize animation controller
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Attach controller if provided
    widget.controller?._attach(this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    widget.controller?._detach();
    super.dispose();
  }

  @override
  void didUpdateWidget(DatePickerDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      setState(() {
        _tempSelectedDate = widget.selectedDate;
      });
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return widget.placeholder;

    switch (widget.dateFormat) {
      case 'MMM dd, yyyy':
        return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
      case 'dd/MM/yyyy':
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      case 'MM/dd/yyyy':
        return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
      case 'yyyy-MM-dd':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case 'EEEE, MMMM dd, yyyy':
        return '${_getDayName(date.weekday)}, ${_getFullMonthName(date.month)} ${date.day}, ${date.year}';
      default:
        return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }

  String _getFullMonthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }

  String _getDayName(int weekday) {
    const days = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday];
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (!widget.enableRangeSelection && !widget.enableMultiSelection) {
      if (args.value is DateTime) {
        setState(() {
          _tempSelectedDate = args.value as DateTime;
        });
        widget.onDateSelected?.call(_tempSelectedDate);
        _closeDropdown(); // close immediately
      }
    }
    widget.onSelectionChanged?.call(args);
  }

  void _clearSelection() {
    setState(() {
      _tempSelectedDate = null;
    });
  }

  void _selectToday() {
    final today = DateTime.now();
    if (_isDateSelectable(today)) {
      setState(() {
        _tempSelectedDate = today;
      });
    }
  }

  bool _isDateSelectable(DateTime date) {
    // Check min/max dates
    if (widget.minDate != null && date.isBefore(widget.minDate!)) {
      return false;
    }
    if (widget.maxDate != null && date.isAfter(widget.maxDate!)) {
      return false;
    }

    // Check past dates
    if (!widget.enablePastDates) {
      final today = DateTime.now();
      final dateOnly = DateTime(date.year, date.month, date.day);
      final todayOnly = DateTime(today.year, today.month, today.day);
      if (dateOnly.isBefore(todayOnly)) {
        return false;
      }
    }

    // Check blackout dates
    if (widget.blackoutDates != null) {
      for (var blackoutDate in widget.blackoutDates!) {
        if (date.year == blackoutDate.year &&
            date.month == blackoutDate.month &&
            date.day == blackoutDate.day) {
          return false;
        }
      }
    }

    // Check custom predicate
    if (widget.selectableDayPredicate != null) {
      return widget.selectableDayPredicate!(date);
    }

    return true;
  }

  void _openDropdown() {
    if (!widget.readOnly && !_isOpen) {
      setState(() {
        _isOpen = true;
        _tempSelectedDate = widget.selectedDate;
      });
      _createOverlay();
      _animationController.forward();
    }
  }

  void _closeDropdown() {
    if (_isOpen) {
      _animationController.reverse().then((_) {
        _removeOverlay();
        if (mounted) {
          setState(() {
            _isOpen = false;
          });
        }
      });
    }
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _createOverlay() {
    _overlayEntry = _customDropdownOverlay();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _customDropdownOverlay() {
    final renderBox = context.findRenderObject()! as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final showAbove =
        offset.dy +
            buttonSize.height +
            widget.gapFromButton +
            widget.overlayHeight >
        screenHeight;

    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Barrier
            GestureDetector(
              onTap: _closeDropdown,
              behavior: HitTestBehavior.translucent,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: widget.barrierColor ?? Colors.transparent,
              ),
            ),

            // Dropdown content
            Positioned(
              left: _calculateHorizontalPosition(
                offset,
                buttonSize,
                screenWidth,
              ),
              top: showAbove
                  ? offset.dy - widget.overlayHeight - widget.gapFromButton
                  : offset.dy + buttonSize.height + widget.gapFromButton,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    alignment: showAbove
                        ? Alignment.bottomCenter
                        : Alignment.topCenter,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: _buildDropdownContent(),
              ),
            ),
          ],
        );
      },
    );
  }

  double _calculateHorizontalPosition(
    Offset offset,
    Size buttonSize,
    double screenWidth,
  ) {
    switch (widget.overlayAlignment) {
      case Alignment.centerLeft:
        return offset.dx;
      case Alignment.center:
        final centerPosition =
            offset.dx + (buttonSize.width - widget.overlayWidth) / 2;
        return centerPosition.clamp(
          8.0,
          screenWidth - widget.overlayWidth - 8.0,
        );
      case Alignment.centerRight:
        final rightPosition =
            offset.dx + buttonSize.width - widget.overlayWidth;
        return rightPosition.clamp(
          8.0,
          screenWidth - widget.overlayWidth - 8.0,
        );
      default:
        return offset.dx;
    }
  }

  Widget _buildDropdownContent() {
    return Material(
      elevation: widget.elevation,
      borderRadius: BorderRadius.circular(widget.overlayBorderRadius),
      color: Colors.transparent,
      child: Container(
        width: widget.overlayWidth,
        height: widget.overlayHeight,
        decoration: BoxDecoration(
          color: widget.overlayColor ?? AppColors.black,
          borderRadius: BorderRadius.circular(widget.overlayBorderRadius),
          border: Border.all(color: AppColors.borderBrown),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: widget.elevation,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Calendar
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildCalendar(),
              ),
            ),

            // Header with action buttons
            if (widget.showTodayButton || widget.showClearButton)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.showClearButton)
                      TextButton(
                        onPressed: _clearSelection,
                        child: Text(
                          widget.clearButtonText,
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    const Spacer(),
                    if (widget.showTodayButton)
                      TextButton(
                        onPressed: _selectToday,
                        child: Text(
                          widget.todayButtonText,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: Theme.of(context).primaryColor,
          surface: widget.overlayColor ?? AppColors.black,
        ),
      ),
      child: SfDateRangePicker(
        initialSelectedDate: _tempSelectedDate,
        initialDisplayDate:
            widget.initialDisplayDate ?? _tempSelectedDate ?? DateTime.now(),
        minDate: widget.minDate,
        maxDate: widget.maxDate,
        enablePastDates: widget.enablePastDates,
        allowViewNavigation: widget.allowViewNavigation,
        headerStyle:
            widget.headerStyle ??
            DateRangePickerHeaderStyle(
              backgroundColor: Colors.transparent,
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
        monthCellStyle:
            widget.monthCellStyle ??
            DateRangePickerMonthCellStyle(
              cellDecoration: BoxDecoration(color: Colors.transparent),
              textStyle: const TextStyle(color: Colors.white),
              todayTextStyle: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
              leadingDatesTextStyle: TextStyle(color: Colors.grey[600]),
              trailingDatesTextStyle: TextStyle(color: Colors.grey[600]),
              weekendTextStyle: TextStyle(color: Colors.grey[400]),
              specialDatesTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
              blackoutDateTextStyle: const TextStyle(
                color: Colors.red,
                decoration: TextDecoration.lineThrough,
              ),
            ),
        yearCellStyle:
            widget.yearCellStyle ??
            DateRangePickerYearCellStyle(
              cellDecoration: BoxDecoration(color: Colors.transparent),
              textStyle: const TextStyle(color: Colors.white),
              todayTextStyle: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
              leadingDatesTextStyle: TextStyle(color: Colors.grey[600]),
              disabledDatesTextStyle: TextStyle(color: Colors.grey[700]),
            ),
        selectionMode: widget.enableRangeSelection
            ? DateRangePickerSelectionMode.range
            : widget.enableMultiSelection
            ? DateRangePickerSelectionMode.multiple
            : DateRangePickerSelectionMode.single,
        onSelectionChanged: _onSelectionChanged,
        // specialDates: widget.specialDates,
        // blackoutDates: widget.blackoutDates,
        selectableDayPredicate: widget.selectableDayPredicate,
        // weekendDays: widget.weekendDays,
        showNavigationArrow: true,
        navigationDirection: DateRangePickerNavigationDirection.vertical,
        backgroundColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(onTap: _toggleDropdown, child: widget.button),
    );
  }
}
