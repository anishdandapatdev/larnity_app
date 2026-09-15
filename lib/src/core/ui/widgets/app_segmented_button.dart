import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';

class AppSegmentedButton extends StatefulWidget {
  const AppSegmentedButton({
    required this.buttonItems,
    required this.pageController,
    this.height,
    this.width,
    this.backgroundColor,
    this.selectedButtonColor,
    this.isScrollable = false,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.selectedBorderColor,
    this.unselectedBorderColor,
    super.key,
  });

  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? selectedButtonColor;
  final List<AppSegmentedButtonItem> buttonItems;
  final PageController pageController;
  final bool isScrollable;
  final TextStyle? selectedLabelStyle;
  final TextStyle? unselectedLabelStyle;
  final Color? selectedBorderColor;
  final Color? unselectedBorderColor;

  @override
  State<AppSegmentedButton> createState() => _AppSegmentedButtonState();
}

class _AppSegmentedButtonState extends State<AppSegmentedButton> {
  int selectedSegmentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _buttonKeys = [];

  @override
  void initState() {
    super.initState();
    _buttonKeys.addAll(
      List.generate(widget.buttonItems.length, (_) => GlobalKey()),
    );
  }

  void _scrollToSelected(int index) {
    final keyContext = _buttonKeys[index].currentContext;
    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final segmentCount = widget.buttonItems.length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: AppSizes.xxxs),
      width: widget.width,
      height: widget.height ?? 44,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.darkBg,
        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          if (!widget.isScrollable)
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              alignment: Alignment(
                (selectedSegmentIndex / (segmentCount - 1)) * 2 - 1,
                0,
              ),
              child: FractionallySizedBox(
                widthFactor: 1 / segmentCount,
                heightFactor: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.skyBlue.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          if (widget.isScrollable)
            SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: widget.buttonItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = index == selectedSegmentIndex;

                  return Container(
                    key: _buttonKeys[index],
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        backgroundColor: isSelected
                            ? (widget.selectedButtonColor ??
                                  AppColors.primaryOrange)
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? (widget.selectedBorderColor ??
                                    Colors.transparent)
                              : (widget.unselectedBorderColor ??
                                    Colors.transparent),
                        ),
                      ),
                      onPressed: () {
                        widget.pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        setState(() {
                          selectedSegmentIndex = index;
                        });
                        _scrollToSelected(index);
                      },
                      child: Row(
                        children: [
                          if (item.prefixIcon != null && isSelected) ...[
                            HugeIcon(
                              icon: HugeIconsStrokeRounded.abacus,       size: 16,
                              color: isSelected
                                  ? (widget.selectedLabelStyle?.color ??
                                        AppColors.darkBg)
                                  : (widget.unselectedLabelStyle?.color ??
                                        AppColors.black),
                            ),
                            5.pw,
                          ],
                          if (item.isDone) ...[
                            HugeIcon(
                              icon: HugeIconsStrokeRounded.abacus,
                              size: 16,
                              color: AppColors.white,
                            ),
                            5.pw,
                          ],
                          Text(
                            item.label,
                            style: isSelected
                                ? (widget.selectedLabelStyle ??
                                      AppTextStyles.bodyText1().copyWith(
                                        fontSize: 12,
                                        color: AppColors.darkBg,
                                      ))
                                : (widget.unselectedLabelStyle ??
                                      AppTextStyles.bodyText1().copyWith(
                                        fontSize: 12,
                                        color: AppColors.black,
                                      )),
                          ),
                          if (item.suffixIcon != null) ...[
                            5.pw,
                            HugeIcon(
                              icon: HugeIconsStrokeRounded.abacus,       size: 16,
                              color: isSelected
                                  ? (widget.selectedLabelStyle?.color ??
                                        AppColors.darkBg)
                                  : (widget.unselectedLabelStyle?.color ??
                                        AppColors.black),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
          else
            Row(
              children: widget.buttonItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = index == selectedSegmentIndex;

                return Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      overlayColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      widget.pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      setState(() {
                        selectedSegmentIndex = index;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (item.prefixIcon != null) ...[
                          HugeIcon(
                            icon: HugeIconsStrokeRounded.abacus,     size: 16,
                            color: isSelected
                                ? AppColors.darkBg
                                : AppColors.black,
                          ),
                          5.pw,
                        ],
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyText1().copyWith(
                            fontSize: 12,
                            color: isSelected
                                ? AppColors.darkBg
                                : AppColors.black,
                          ),
                        ),
                        if (item.suffixIcon != null) ...[
                          5.pw,
                          HugeIcon(
                            icon: HugeIconsStrokeRounded.abacus,     size: 16,
                            color: isSelected
                                ? AppColors.darkBg
                                : AppColors.black,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class AppSegmentedButtonItem {
  AppSegmentedButtonItem({
    required this.label,
    this.isDone = false,
    this.iconUrl,
    this.prefixIcon,
    this.suffixIcon,
  });

  final String label;
  final bool isDone;
  final String? iconUrl;
  final List<List<dynamic>>? prefixIcon;
  final List<List<dynamic>>? suffixIcon;
}
