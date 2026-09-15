import 'package:flutter/material.dart';
import 'package:larnity/src/core/theme/app_colors.dart';

// Controller class to manage dropdown state externally
class TimePickerDropdownController {
  _TimePickerDropdownState? _state;

  void _attach(_TimePickerDropdownState state) {
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

  /// Set time externally
  void setTime({int? hour, int? minute, String? period}) {
    _state?._setTime(hour: hour, minute: minute, period: period);
  }

  /// Get current selected time
  TimeValue? get currentTime => _state?._currentTime;
}

// Time value model
class TimeValue {
  final int hour;
  final int minute;
  final String period; // "AM" or "PM"

  const TimeValue({
    required this.hour,
    required this.minute,
    required this.period,
  });

  @override
  String toString() {
    return '$hour:$minute $period';
  }

  // Convert to 24-hour format
  String to24HourFormat() {
    int h = hour;
    if (period == 'PM' && hour != 12) {
      h += 12;
    } else if (period == 'AM' && hour == 12) {
      h = 0;
    }
    return '${h.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}

class TimePickerDropdown extends StatefulWidget {
  const TimePickerDropdown({
    required this.button,
    super.key,
    this.selectedTime,
    this.onTimeSelected,
    this.timeFormat = 'hh:mm a',
    this.placeholder = 'Select Time',
    this.overlayWidth = 280,
    this.overlayHeight = 300,
    this.controller,
    this.readOnly = false,
    this.overlayAlignment = Alignment.centerLeft,
    this.gapFromButton = 8.0,
    this.overlayColor,
    this.overlayBorderRadius = 12.0,
    this.elevation = 8.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.barrierColor,
    this.showActionButtons = true,
    this.confirmButtonText = 'Select',
    this.cancelButtonText = 'Cancel',
    this.is24HourFormat = false,
    this.minuteInterval = 1,
    this.selectedTimeDecoration,
    this.unselectedTimeDecoration,
    this.timeTextStyle,
    this.selectedTimeTextStyle,
    this.itemHeight = 40.0,
    this.scrollPhysics,
    this.headerText = 'Select Time',
    this.showHeader = true,
  });

  // Required button widget
  final Widget button;

  // Basic properties
  final TimeOfDay? selectedTime;
  final Function(TimeOfDay?)? onTimeSelected;
  final String timeFormat;
  final String placeholder;
  final bool is24HourFormat;
  final int minuteInterval;

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
  final TimePickerDropdownController? controller;
  final bool readOnly;

  // Action buttons
  final bool showActionButtons;
  final String confirmButtonText;
  final String cancelButtonText;

  // Time picker styling
  final BoxDecoration? selectedTimeDecoration;
  final BoxDecoration? unselectedTimeDecoration;
  final TextStyle? timeTextStyle;
  final TextStyle? selectedTimeTextStyle;
  final double itemHeight;
  final ScrollPhysics? scrollPhysics;

  // Header
  final String headerText;
  final bool showHeader;

  @override
  State<TimePickerDropdown> createState() => _TimePickerDropdownState();
}

class _TimePickerDropdownState extends State<TimePickerDropdown>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  final _buttonKey = GlobalKey();
  // TimeOfDay? _tempSelectedTime;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  // Scroll controllers
  final ScrollController _hourController = ScrollController();
  final ScrollController _minuteController = ScrollController();
  final ScrollController _periodController = ScrollController();

  int _selectedHour = 12;
  int _selectedMinute = 0;
  String _selectedPeriod = 'AM';

  TimeValue get _currentTime => TimeValue(
    hour: _selectedHour,
    minute: _selectedMinute,
    period: _selectedPeriod,
  );

  @override
  void initState() {
    super.initState();
    // _tempSelectedTime = widget.selectedTime;
    _initializeTime();

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

  void _initializeTime() {
    if (widget.selectedTime != null) {
      final time = widget.selectedTime!;
      if (widget.is24HourFormat) {
        _selectedHour = time.hour;
      } else {
        _selectedHour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
        _selectedPeriod = time.period == DayPeriod.am ? 'AM' : 'PM';
      }
      _selectedMinute = time.minute;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    widget.controller?._detach();
    super.dispose();
  }

  void _setTime({int? hour, int? minute, String? period}) {
    setState(() {
      if (hour != null && hour >= 1 && hour <= 12) {
        _selectedHour = hour;
      }
      if (minute != null && minute >= 0 && minute <= 59) {
        _selectedMinute = minute;
      }
      if (period != null && (period == 'AM' || period == 'PM')) {
        _selectedPeriod = period;
      }
    });
  }

  @override
  void didUpdateWidget(TimePickerDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTime != oldWidget.selectedTime) {
      setState(() {
        _initializeTime();
      });
    }
  }

  String formatTime(TimeOfDay? time) {
    if (time == null) return widget.placeholder;

    switch (widget.timeFormat) {
      case 'HH:mm':
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      case 'hh:mm a':
        final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
        final period = time.period == DayPeriod.am ? 'AM' : 'PM';
        return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
      case 'h:mm a':
        final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
        final period = time.period == DayPeriod.am ? 'AM' : 'PM';
        return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
      default:
        return time.format(context);
    }
  }

  void _updateTempSelectedTime() {
    TimeOfDay timeToSet;

    if (widget.is24HourFormat) {
      timeToSet = TimeOfDay(hour: _selectedHour, minute: _selectedMinute);
    } else {
      int hour24 = _selectedHour;
      if (_selectedPeriod == 'PM' && _selectedHour != 12) {
        hour24 = _selectedHour + 12;
      } else if (_selectedPeriod == 'AM' && _selectedHour == 12) {
        hour24 = 0;
      }
      timeToSet = TimeOfDay(hour: hour24, minute: _selectedMinute);
    }

    if (!widget.showActionButtons) {
      widget.onTimeSelected?.call(timeToSet);
      _closeDropdown();
    }
  }

  // void _confirmSelection() {
  //   if (_tempSelectedTime != null) {
  //     widget.onTimeSelected?.call(_tempSelectedTime);
  //   }
  //   _closeDropdown();
  // }

  void _refreshUI() {
    setState(() {
      // Force UI rebuild to reflect the latest selected values
    });
  }

  void _openDropdown() {
    if (!widget.readOnly && !_isOpen) {
      setState(() {
        _isOpen = true;
        _initializeTime();
      });
      _createOverlay();
      _animationController.forward();

      // Scroll to current values after overlay is created
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentValues();
      });
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

  void _scrollToCurrentValues() {
    // Scroll to current hour
    if (_hourController.hasClients) {
      final hourIndex = widget.is24HourFormat
          ? _selectedHour
          : _selectedHour - 1;
      _hourController.animateTo(
        hourIndex * widget.itemHeight,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    // Scroll to current minute
    if (_minuteController.hasClients) {
      final minuteIndex = _selectedMinute ~/ widget.minuteInterval;
      _minuteController.animateTo(
        minuteIndex * widget.itemHeight,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    // Scroll to current period (if not 24h format)
    if (!widget.is24HourFormat && _periodController.hasClients) {
      final periodIndex = _selectedPeriod == 'AM' ? 0 : 1;
      _periodController.animateTo(
        periodIndex * widget.itemHeight,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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
                child: CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: _getOffset(buttonSize, showAbove),
                  child: _TimePickerContainer(
                    selectedHour: _selectedHour,
                    selectedMinute: _selectedMinute,
                    selectedPeriod: _selectedPeriod,
                    onTimeSelected: (hour, minute, period) {
                      setState(() {
                        _selectedHour = hour;
                        _selectedMinute = minute;
                        _selectedPeriod = period;
                      });
                      
                      // Convert 12h format to 24h for TimeOfDay
                      int hour24 = hour;
                      if (period == 'PM' && hour != 12) {
                        hour24 = hour + 12;
                      } else if (period == 'AM' && hour == 12) {
                        hour24 = 0;
                      }
                      
                      final timeOfDay = TimeOfDay(hour: hour24, minute: minute);
                      widget.onTimeSelected?.call(timeOfDay);
                      
                      _removeOverlay();
                    },
                    selectedTimeDecoration: widget.selectedTimeDecoration,
                    minuteInterval: widget.minuteInterval,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  double getButtonWidth() {
    final renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? 0;
  }

  Offset _getOffset(Size buttonSize, bool showAbove) {
    final dx = switch (widget.overlayAlignment) {
      Alignment.centerLeft => 0.0,
      Alignment.center => (buttonSize.width - (widget.overlayWidth)) / 2,
      Alignment.centerRight => buttonSize.width - (widget.overlayWidth),
      _ => 0.0,
    };
    final dy = showAbove
        ? -300 -
              (5 + widget.gapFromButton) // Fixed height for time picker
        : buttonSize.height + (5 + widget.gapFromButton);
    return Offset(dx, dy);
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

  Widget buildDropdownContent() {
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
            // Header
            if (widget.showHeader)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.headerText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // Time picker
            Expanded(child: _buildTimePicker()),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Row(
      children: [
        // Hour column
        Expanded(
          child: _buildTimeColumn(
            items: _getHourItems(),
            controller: _hourController,
            onItemTap: (index, value) {
              setState(() {
                _selectedHour = value;
                _updateTempSelectedTime();
                _scrollToCurrentValues();
                _refreshUI();
              });
            },
            selectedValue: _selectedHour,
          ),
        ),

        // Separator
        Container(
          width: 1,
          height: double.infinity,
          color: AppColors.borderBrown,
          margin: const EdgeInsets.symmetric(horizontal: 8),
        ),

        // Minute column
        Expanded(
          child: _buildTimeColumn(
            items: _getMinuteItems(),
            controller: _minuteController,
            onItemTap: (index, value) {
              setState(() {
                _selectedMinute = value;
                _updateTempSelectedTime();
                _scrollToCurrentValues();
                _refreshUI();
              });
            },
            selectedValue: _selectedMinute,
          ),
        ),

        // AM/PM column (if not 24h format)
        if (!widget.is24HourFormat) ...[
          Container(
            width: 1,
            height: double.infinity,
            color: AppColors.borderBrown,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Expanded(child: _buildPeriodColumn()),
        ],
      ],
    );
  }

  Widget _buildTimeColumn({
    required List<int> items,
    required ScrollController controller,
    required Function(int, int) onItemTap,
    required int selectedValue,
  }) {
    return ListView.builder(
      controller: controller,
      physics: widget.scrollPhysics ?? const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final value = items[index];
        final isSelected = value == selectedValue;

        return GestureDetector(
          onTap: () {
            onItemTap(index, value);
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: widget.itemHeight,
            alignment: Alignment.center,
            decoration: isSelected
                ? widget.selectedTimeDecoration ??
                      BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                : widget.unselectedTimeDecoration ??
                      BoxDecoration(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text(
              value.toString().padLeft(2, '0'),
              style: isSelected
                  ? widget.selectedTimeTextStyle ??
                        TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )
                  : widget.timeTextStyle ??
                        const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeriodColumn() {
    final periods = ['AM', 'PM'];

    return ListView.builder(
      controller: _periodController,
      physics: widget.scrollPhysics ?? const BouncingScrollPhysics(),
      itemCount: periods.length,
      itemBuilder: (context, index) {
        final period = periods[index];
        final isSelected = period == _selectedPeriod;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPeriod = period;
              _updateTempSelectedTime();
              _scrollToCurrentValues();
              _refreshUI();
            });
          },
          child: Container(
            height: widget.itemHeight,
            alignment: Alignment.center,
            decoration: isSelected
                ? widget.selectedTimeDecoration ??
                      BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                : widget.unselectedTimeDecoration ??
                      BoxDecoration(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text(
              period,
              style: isSelected
                  ? widget.selectedTimeTextStyle ??
                        TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )
                  : widget.timeTextStyle ??
                        const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  List<int> _getHourItems() {
    if (widget.is24HourFormat) {
      return List.generate(24, (index) => index);
    } else {
      return List.generate(12, (index) => index + 1);
    }
  }

  List<int> _getMinuteItems() {
    return List.generate(
      60 ~/ widget.minuteInterval,
      (index) => index * widget.minuteInterval,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        key: _buttonKey,
        child: GestureDetector(onTap: _toggleDropdown, child: widget.button),
      ),
    );
  }
}

class _TimePickerContainer extends StatefulWidget {
  const _TimePickerContainer({
    required this.selectedHour,
    required this.selectedMinute,
    required this.selectedPeriod,
    required this.onTimeSelected,
    required this.selectedTimeDecoration,
    required this.minuteInterval,
  });

  final int selectedHour;
  final int selectedMinute;
  final String selectedPeriod;
  final Function(int, int, String) onTimeSelected;
  final BoxDecoration? selectedTimeDecoration;
  final int minuteInterval;

  @override
  State<_TimePickerContainer> createState() => _TimePickerContainerState();
}

class _TimePickerContainerState extends State<_TimePickerContainer> {
  late int _selectedHour;
  late int _selectedMinute;
  late String _selectedPeriod;

  late final ScrollController _hourScrollController;
  late final ScrollController _minuteScrollController;
  late final ScrollController _periodScrollController;

  List<int> get _hours => List.generate(12, (i) => i + 1);

  List<int> get _minutes {
    final minutes = <int>[];
    for (int i = 0; i < 60; i += widget.minuteInterval) {
      minutes.add(i);
    }
    return minutes;
  }

  List<String> get _periods => ['AM', 'PM'];

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.selectedHour;
    _selectedMinute = widget.selectedMinute;
    _selectedPeriod = widget.selectedPeriod;

    // Calculate initial scroll offsets (item height is 40.0)
    final hourIndex = _hours.indexOf(_selectedHour);
    final minuteIndex = _minutes.indexOf(_selectedMinute);
    final periodIndex = _periods.indexOf(_selectedPeriod);

    _hourScrollController = ScrollController(
      initialScrollOffset: (hourIndex >= 0 ? hourIndex : 0) * 40.0,
    );
    _minuteScrollController = ScrollController(
      initialScrollOffset: (minuteIndex >= 0 ? minuteIndex : 0) * 40.0,
    );
    _periodScrollController = ScrollController(
      initialScrollOffset: (periodIndex >= 0 ? periodIndex : 0) * 40.0,
    );
  }

  @override
  void dispose() {
    _hourScrollController.dispose();
    _minuteScrollController.dispose();
    _periodScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      color: AppColors.black,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 350,
          minWidth: 300,
          maxWidth: 300,
        ),
        child: Column(
          children: [
            // Time picker columns
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Hour column
                  _buildTimeColumn(
                    items: _hours,
                    selectedItem: _selectedHour,
                    controller: _hourScrollController,
                    formatter: (value) => value.toString().padLeft(2, '0'),
                    onItemSelected: (value) {
                      setState(() {
                        _selectedHour = value;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  // Minute column
                  _buildTimeColumn(
                    items: _minutes,
                    selectedItem: _selectedMinute,
                    controller: _minuteScrollController,
                    formatter: (value) => value.toString().padLeft(2, '0'),
                    onItemSelected: (value) {
                      setState(() {
                        _selectedMinute = value;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  // Period column (AM/PM)
                  _buildTimeColumn(
                    items: _periods,
                    selectedItem: _selectedPeriod,
                    controller: _periodScrollController,
                    formatter: (value) => value.toString(),
                    onItemSelected: (value) {
                      setState(() {
                        _selectedPeriod = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.borderBrown),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onTimeSelected(_selectedHour, _selectedMinute, _selectedPeriod);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Set Time",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn<T>({
    required List<T> items,
    required T selectedItem,
    required ScrollController controller,
    required String Function(T) formatter,
    required Function(T) onItemSelected,
  }) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: controller,
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item == selectedItem;
                return GestureDetector(
                  onTap: () => onItemSelected(item),
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: isSelected
                        ? BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          )
                        : null,
                    child: Text(
                      formatter(item),
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
