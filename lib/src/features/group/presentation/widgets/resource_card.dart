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
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/features/group/data/models/resource_model.dart';
import 'package:larnity/src/features/group/presentation/provider/treasure_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceCard extends ConsumerWidget {
  final ResourceModel resource;

  const ResourceCard({super.key, required this.resource});

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBgContainer,
        borderRadius: BorderRadius.circular(AppSizes.xs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.xs),
                  topRight: Radius.circular(AppSizes.xs),
                ),
                image: resource.resourceImg.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(resource.resourceImg),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.xs),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        resource.resourceName,
                        style: AppTextStyles.headline4(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppDropdown(
                      button: const Icon(
                        Icons.more_vert,
                        color: AppColors.white,
                      ),
                      overlayWidth: 160,
                      overlayAlignment: Alignment.centerRight,
                      onItemSelected: (value) {
                        if (value == 'delete') {
                          ref
                              .read(treasureProvider(resource.groupId).notifier)
                              .deleteResource(
                                resourceId: resource.id!,
                                successCallBack: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Resource deleted'),
                                    ),
                                  );
                                },
                              );
                        }
                      },
                      items: [
                        AppDropdownItem(
                          value: "edit",
                          child: Row(
                            children: [
                              const HugeIcon(
                                icon: HugeIconsStrokeRounded.edit03,
                                color: AppColors.primaryOrange,
                              ),
                              AppSizes.xxxs.pw,
                              Text(
                                AppStrings.edit,
                                style: AppTextStyles.overLine(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppDropdownItem(
                          value: "delete",
                          child: Row(
                            children: [
                              const HugeIcon(
                                icon: HugeIconsStrokeRounded.delete01,
                                color: AppColors.red,
                              ),
                              AppSizes.xxxs.pw,
                              Text(
                                AppStrings.delete,
                                style: AppTextStyles.overLine(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                AppSizes.xs.ph,
                AppButton(
                  onPressed: () {
                    if (resource.resourceLink.isNotEmpty) {
                      var url = resource.resourceLink;
                      if (!url.startsWith('http')) {
                        url = 'https://$url';
                      }
                      _launchUrl(url);
                    }
                  },
                  label: AppStrings.access,
                  prefix: const HugeIcon(
                    icon: HugeIconsStrokeRounded.cloudDownload,
                    color: AppColors.black,
                  ),
                  labelStyle: AppTextStyles.button(color: AppColors.black),
                  bgColor: AppColors.primaryOrange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
