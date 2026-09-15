import 'dart:async';

import 'package:flutter/material.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';

// Controller class to manage dropdown state externally
class AppDropdownController {
  _AppDropdownState? _state;

  void _attach(_AppDropdownState state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  /// Close the dropdown from outside
  void close() {
    _state?.closeDropdown();
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

class AppDropdownItem<T> {
  const AppDropdownItem({
    required this.value,
    this.child,
    this.label,
    this.queryString,
    this.height = 40,
  });

  final T value;
  final Widget? child;
  final String? label;
  final String? queryString;
  final double height;
}

class AppDropdown<T> extends StatefulWidget {
  const AppDropdown({
    required this.button,
    required this.items,
    this.top,
    this.bottom,
    this.customItems,
    this.selectedValue,
    super.key,
    this.onItemSelected,
    this.overlayWidth,
    this.overlayPadding,
    this.decoration,
    this.overlayAlignment = Alignment.centerLeft,
    this.itemBorderRadius,
    this.itemGap,
    this.selectedItemBackgroundColor,
    this.selectedItemForegroundColor,
    this.overlayColor,
    this.overlayRadius,
    this.itemsAlignment,
    this.overlayHeight,
    this.readOnly = false,
    this.enableSearch = false,
    this.itemPadding,
    this.alignWithDevice = false,
    this.gapFromButton = 0,
    this.controller,
    // New real-time search properties
    this.onSearchQuery,
    this.searchDebounceMs = 300,
    this.showLoadingIndicator = true,
    this.emptySearchMessage = 'No results found',
    this.searchHintText = 'Search...',
    this.minSearchLength = 0,
  });

  final bool enableSearch;
  final AppDropdownController? controller;

  // Real-time search properties
  final Future<List<AppDropdownItem<T>>> Function(String query)? onSearchQuery;
  final int searchDebounceMs;
  final bool showLoadingIndicator;
  final String emptySearchMessage;
  final String searchHintText;
  final int minSearchLength;

  final T? selectedValue;
  final Widget button;
  final Widget? top;
  final Widget? bottom;
  final List<AppDropdownItem<T>> items;
  final List<Widget>? customItems;
  final void Function(T)? onItemSelected;
  final double? overlayWidth;
  final double? itemBorderRadius;
  final double? overlayRadius;
  final double? overlayHeight;
  final EdgeInsetsGeometry? overlayPadding;
  final EdgeInsetsGeometry? itemPadding;
  final int? itemGap;
  final BoxDecoration? decoration;
  final Color? selectedItemBackgroundColor;
  final Color? selectedItemForegroundColor;
  final Color? overlayColor;
  final AlignmentGeometry overlayAlignment;
  final AlignmentGeometry? itemsAlignment;
  final bool readOnly;
  final bool alignWithDevice;
  final double gapFromButton;

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  final _buttonKey = GlobalKey();

  double _overlayHeight = 0;

  final TextEditingController _searchController = TextEditingController();
  List<AppDropdownItem<T>> _filteredItems = [];
  String _currentSearchQuery = '';
  bool _isLoading = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _calculateOverlayHeight();
    // Attach controller if provided
    widget.controller?._attach(this);
  }

  @override
  void dispose() {
    // Remove overlay first, before disposing
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    // Cancel debounce timer
    _debounceTimer?.cancel();
    // Detach controller
    widget.controller?._detach();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _currentSearchQuery = query;

    // Cancel previous timer
    _debounceTimer?.cancel();

    // If real-time search is enabled
    if (widget.onSearchQuery != null) {
      if (query.length >= widget.minSearchLength) {
        // Set loading state immediately for better UX
        if (mounted) {
          setState(() {
            _isLoading = true;
          });
          _rebuildOverlay();
        }

        // Start debounce timer
        _debounceTimer = Timer(
          Duration(milliseconds: widget.searchDebounceMs),
          () {
            _performRealTimeSearch(query);
          },
        );
      } else {
        // Show original items if query is too short
        setState(() {
          _filteredItems = widget.items;
          _isLoading = false;
        });
        _calculateOverlayHeight();
        _rebuildOverlay();
      }
    } else {
      // Fallback to local search
      _performLocalSearch(query);
    }
  }

  Future<void> _performRealTimeSearch(String query) async {
    try {
      final results = await widget.onSearchQuery!(query);

      if (mounted && _currentSearchQuery == query) {
        setState(() {
          _filteredItems = results;
          _isLoading = false;
        });
        _calculateOverlayHeight();
        _rebuildOverlay();
      }
    } catch (error) {
      if (mounted && _currentSearchQuery == query) {
        setState(() {
          _filteredItems = [];
          _isLoading = false;
        });
        _calculateOverlayHeight();
        _rebuildOverlay();
      }
      // You might want to show an error message or handle the error
      debugPrint('Real-time search error: $error');
    }
  }

  void _performLocalSearch(String query) {
    final filtered = widget.items.where((item) {
      return (item.queryString ?? item.label ?? '').toLowerCase().contains(
        query.toLowerCase(),
      );
    }).toList();

    setState(() {
      _filteredItems = filtered;
    });
    _calculateOverlayHeight();
    _rebuildOverlay();
  }

  void _rebuildOverlay() {
    if (_isOpen && _overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _calculateOverlayHeight() {
    if (widget.overlayHeight == null) {
      double baseHeight = widget.enableSearch ? 60.0 : 0.0;

      if (_isLoading) {
        baseHeight += 60.0; // Height for loading indicator
      } else if (_filteredItems.isEmpty && _currentSearchQuery.isNotEmpty) {
        baseHeight += 60.0; // Height for empty message
      } else {
        baseHeight += _filteredItems.fold(
          0.0,
          (sum, item) => sum + item.height + (widget.itemGap ?? 8),
        );
      }

      _overlayHeight = baseHeight > 0.4.sh ? 0.4.sh : baseHeight;
    } else {
      _overlayHeight = widget.overlayHeight!;
    }
  }

  void closeDropdown() {
    _removeOverlay();
  }

  void _openDropdown() {
    if (!widget.readOnly && !_isOpen) {
      _createOverlay();
      setState(() => _isOpen = true);
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (_isOpen) {
      setState(() {
        _isOpen = false;
        _searchController.clear();
        _currentSearchQuery = '';
        _filteredItems = widget.items;
        _isLoading = false;
      });
      _debounceTimer?.cancel();
    }
  }

  void _toggleDropdown() {
    if (!widget.readOnly) {
      if (_isOpen) {
        _removeOverlay();
      } else {
        _createOverlay();
        setState(() => _isOpen = true);
      }
    }
  }

  void _createOverlay() {
    _overlayEntry = _customDropdownOverlay();
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _customDropdownOverlay() {
    final renderBox = context.findRenderObject()! as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;
    final buttonWidth = _getButtonWidth();
    final showAbove =
        offset.dy + _overlayHeight > MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: _removeOverlay,
          behavior: HitTestBehavior.translucent,
          child: ColoredBox(
            color: Colors.transparent,
            child: Stack(
              children: [
                widget.alignWithDevice
                    ? Positioned(
                        left:
                            (screenWidth - (widget.overlayWidth ?? 0.9.sw)) / 2,
                        top: showAbove
                            ? offset.dy -
                                  _overlayHeight -
                                  (5 + widget.gapFromButton)
                            : offset.dy +
                                  buttonSize.height +
                                  (5 + widget.gapFromButton),
                        child: _DropdownContainer(
                          items: _filteredItems,
                          buttonWidth: buttonWidth,
                          screenWidth: screenWidth,
                          searchController: _searchController,
                          currentSearchQuery: _currentSearchQuery,
                          onSearchChanged: _onSearchChanged,
                          onItemSelected: (value) {
                            widget.onItemSelected?.call(value);
                            _removeOverlay();
                          },
                          selectedValue: widget.selectedValue,
                          widget: widget,
                          overlayHeight: _overlayHeight,
                          isLoading: _isLoading,
                        ),
                      )
                    : CompositedTransformFollower(
                        link: _layerLink,
                        showWhenUnlinked: false,
                        offset: _getOffset(buttonSize, showAbove),
                        child: _DropdownContainer(
                          items: _filteredItems,
                          buttonWidth: buttonWidth,
                          screenWidth: screenWidth,
                          searchController: _searchController,
                          currentSearchQuery: _currentSearchQuery,
                          onSearchChanged: _onSearchChanged,
                          onItemSelected: (value) {
                            widget.onItemSelected?.call(value);
                            _removeOverlay();
                          },
                          selectedValue: widget.selectedValue,
                          widget: widget,
                          overlayHeight: _overlayHeight,
                          isLoading: _isLoading,
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _getButtonWidth() {
    final renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? 0;
  }

  Offset _getOffset(Size buttonSize, bool showAbove) {
    final dx = switch (widget.overlayAlignment) {
      Alignment.centerLeft => 0.0,
      Alignment.center => (buttonSize.width - (widget.overlayWidth ?? 0)) / 2,
      Alignment.centerRight => buttonSize.width - (widget.overlayWidth ?? 0),
      _ => 0.0,
    };
    final dy = showAbove
        ? -_overlayHeight - (5 + widget.gapFromButton)
        : buttonSize.height + (5 + widget.gapFromButton);
    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        key: _buttonKey,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleDropdown,
          child: widget.button,
        ),
      ),
    );
  }
}

class _DropdownContainer<T> extends StatelessWidget {
  const _DropdownContainer({
    required this.items,
    required this.buttonWidth,
    required this.screenWidth,
    required this.searchController,
    required this.currentSearchQuery,
    required this.onSearchChanged,
    required this.onItemSelected,
    required this.selectedValue,
    required this.widget,
    required this.overlayHeight,
    required this.isLoading,
  });

  final List<AppDropdownItem<T>> items;
  final double buttonWidth;
  final double screenWidth;
  final TextEditingController searchController;
  final String currentSearchQuery;
  final Function(String) onSearchChanged;
  final Function(T) onItemSelected;
  final T? selectedValue;
  final AppDropdown<T> widget;
  final double overlayHeight;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final containerWidth = widget.alignWithDevice
        ? (widget.overlayWidth ?? 0.9.sw)
        : (widget.overlayWidth ?? buttonWidth);

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: overlayHeight,
          minWidth: containerWidth,
          maxWidth: containerWidth,
        ),
        child: Container(
          padding: widget.overlayPadding,
          decoration:
              widget.decoration ??
              BoxDecoration(
                border: Border.all(color: AppColors.borderBrown),
                color: widget.overlayColor ?? AppColors.black,
                borderRadius: BorderRadius.circular(widget.overlayRadius ?? 8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
          child: Column(
            children: [
              if (widget.top != null) widget.top!,
              if (widget.enableSearch)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: widget.searchHintText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 8,
                      ),
                      isDense: true,
                      suffixIcon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              Expanded(child: _buildContent(context, containerWidth)),
              if (widget.bottom != null) widget.bottom!,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, double containerWidth) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (items.isEmpty && currentSearchQuery.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            widget.emptySearchMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = item.value == selectedValue;
        return InkWell(
          onTap: () => onItemSelected(item.value),
          child: Container(
            padding: widget.itemPadding ?? EdgeInsets.symmetric(horizontal: 16),
            height: item.height,
            decoration: BoxDecoration(
              color: isSelected
                  ? widget.selectedItemBackgroundColor ??
                        Theme.of(context).colorScheme.surface
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(widget.itemBorderRadius ?? 4),
            ),
            alignment: widget.itemsAlignment,
            child: Align(
              alignment: Alignment.centerLeft,
              child:
                  item.child ??
                  SizedBox(
                    width: containerWidth,
                    child: Text(
                      item.label!,
                      style: TextStyle(
                        color: isSelected
                            ? widget.selectedItemForegroundColor ??
                                  Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) =>
          widget.itemGap != null ? widget.itemGap!.ph : 8.ph,
    );
  }
}
