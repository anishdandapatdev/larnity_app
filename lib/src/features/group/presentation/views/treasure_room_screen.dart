import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/treasure_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/add_resource.dart';
import 'package:larnity/src/features/group/presentation/widgets/resource_card.dart';

class TreasureRoomScreen extends ConsumerStatefulWidget {
  const TreasureRoomScreen({super.key});

  @override
  ConsumerState<TreasureRoomScreen> createState() => _TreasureRoomScreenState();
}

class _TreasureRoomScreenState extends ConsumerState<TreasureRoomScreen> {
  @override
  Widget build(BuildContext context) {
    final groupId = ref.watch(groupProvider).group?.id;

    if (groupId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Treasure Room")),
        backgroundColor: AppColors.bgBlue,
        body: const Center(
          child: Text(
            "No group selected",
            style: TextStyle(color: AppColors.white),
          ),
        ),
      );
    }

    final treasureState = ref.watch(treasureProvider(groupId));
    final resources = treasureState.resources ?? [];
    final isLoading =
        treasureState.fetchState == AsyncState.loading && resources.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text("Treasure Room")),
      backgroundColor: AppColors.bgBlue,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: Column(
          children: [
            AppSizes.xs.ph,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.treasureRoom,
                      style: AppTextStyles.headline2(color: AppColors.white),
                    ),
                    Text(
                      "${resources.length} ${AppStrings.resourcesAvailable}",
                      style: AppTextStyles.overLine(),
                    ),
                  ],
                ),
                AppButton(
                  isExpanded: false,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const Dialog(
                        backgroundColor: AppColors.bgBlue,
                        child: AddResource(),
                      ),
                    );
                  },
                  prefix: const HugeIcon(
                    icon: HugeIconsStrokeRounded.addCircle,
                    color: AppColors.black,
                  ),
                  label: AppStrings.addResource,
                  labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
                  bgColor: AppColors.primaryOrange,
                  radius: AppSizes.xxxs,
                ),
              ],
            ),
            AppSizes.xxxlg.ph,
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryOrange,
                      ),
                    )
                  : resources.isEmpty
                  ? const Center(
                      child: Text(
                        "No resources added yet.",
                        style: TextStyle(color: AppColors.skyBlue),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppSizes.xs,
                            mainAxisSpacing: AppSizes.xs,
                            childAspectRatio: 0.7,
                          ),
                      itemCount: resources.length,
                      itemBuilder: (context, index) {
                        return ResourceCard(resource: resources[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
