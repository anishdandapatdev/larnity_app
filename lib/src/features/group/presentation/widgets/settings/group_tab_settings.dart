import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/manage_group_tab_card.dart';

class GroupTabSettings extends ConsumerStatefulWidget {
  const GroupTabSettings({super.key});

  @override
  ConsumerState<GroupTabSettings> createState() => _GroupTabSettingsState();
}

class _GroupTabSettingsState extends ConsumerState<GroupTabSettings> {
  final Map<String, bool> _tabs = {
    'discussion': true,
    'showcase': true,
    'stage': true,
    'events': true,
    'members': true,
    'resources': true,
    'challenges': true,
    'courses': true,
    'products': true,
    'jobs': true,
    'quizzes': true,
  };

  bool _initialized = false;
  final bool _isLoading = false;

  void _initFromGroup() {
    if (_initialized) return;
    final group = ref.read(groupProvider).group;
    if (group == null) return;

    final visibility = group.landingSettings?['tabVisibility'];
    if (visibility is Map) {
      for (final key in _tabs.keys) {
        if (visibility.containsKey(key)) {
          _tabs[key] = visibility[key] == true;
        }
      }
    }
    _initialized = true;
  }

  Future<void> _updateTab(String key, bool value) async {
    setState(() {
      _tabs[key] = value;
    });
    await _saveTabs();
  }

  Future<void> _saveTabs() async {
    final group = ref.read(groupProvider).group;
    if (group == null) return;

    final currentSettings =
        Map<String, dynamic>.from(group.landingSettings ?? {});
    currentSettings['tabVisibility'] = Map<String, bool>.from(_tabs);

    final updated = group.copyWith(landingSettings: currentSettings);
    await ref.read(groupProvider.notifier).updateGroup(
          group: updated,
          successCallBack: () {
            if (mounted) {
              showSuccessToast(content: "Tab settings updated");
            }
          },
          failureCallBack: (err) {
            if (mounted) {
              showErrorToast(content: err);
            }
          },
        );
  }

  Future<void> _resetToDefault() async {
    setState(() {
      _tabs.updateAll((key, val) => true);
    });
    await _saveTabs();
  }

  @override
  Widget build(BuildContext context) {
    _initFromGroup();

    final tabConfigs = [
      {
        'key': 'discussion',
        'title': 'Discussion Room',
        'icon': HugeIconsStrokeRounded.home03,
      },
      {
        'key': 'showcase',
        'title': 'Showcase Room',
        'icon': HugeIconsStrokeRounded.geometricShapes01,
      },
      {
        'key': 'stage',
        'title': 'Stage Room',
        'icon': HugeIconsStrokeRounded.computerVideo,
      },
      {
        'key': 'events',
        'title': 'Event Room',
        'icon': HugeIconsStrokeRounded.calendar03,
      },
      {
        'key': 'members',
        'title': 'Member Room',
        'icon': HugeIconsStrokeRounded.userMultiple,
      },
      {
        'key': 'resources',
        'title': 'Resource Room',
        'icon': HugeIconsStrokeRounded.sourceCodeSquare,
      },
      {
        'key': 'challenges',
        'title': 'Challenge Room',
        'icon': HugeIconsStrokeRounded.adventure,
      },
      {
        'key': 'courses',
        'title': 'Course Room',
        'icon': HugeIconsStrokeRounded.notebook02,
      },
      {
        'key': 'products',
        'title': 'Digital Product Room',
        'icon': HugeIconsStrokeRounded.shoppingBag01,
      },
      {
        'key': 'jobs',
        'title': 'Job Room',
        'icon': HugeIconsStrokeRounded.documentValidation,
      },
      {
        'key': 'quizzes',
        'title': 'Quiz Room',
        'icon': HugeIconsStrokeRounded.id,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.manageGroupTabs,
                style: AppTextStyles.headline4(color: AppColors.white),
              ),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          Text(
            AppStrings.manageGroupTabsDesc,
            style: AppTextStyles.overLine(color: AppColors.skyBlue),
          ),
          AppSizes.md.ph,
          SizedBox(
            height: 0.5.sh,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...tabConfigs.map((config) {
                    final key = config['key'] as String;
                    final title = config['title'] as String;
                    final icon = config['icon'] as List<List<dynamic>>;
                    final isEnabled = _tabs[key] ?? true;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.xs),
                      child: ManageGroupTabCard(
                        icon: icon,
                        title: title,
                        value: isEnabled,
                        onSwitch: (val) => _updateTab(key, val),
                      ),
                    );
                  }),
                  AppSizes.xs.ph,
                  AppButton(
                    isLoading: _isLoading,
                    onPressed: _resetToDefault,
                    label: AppStrings.resetAllToDefault,
                    labelStyle: AppTextStyles.bodyText2(color: AppColors.white),
                    bgColor: AppColors.darkBrown,
                    radius: AppSizes.xxxs,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

