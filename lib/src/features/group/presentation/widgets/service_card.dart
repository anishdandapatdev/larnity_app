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
import 'package:larnity/src/features/group/data/models/product_model.dart';
import 'package:larnity/src/features/group/presentation/views/service_room_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceCard extends ConsumerWidget {
  final ProductModel service;

  const ServiceCard({super.key, required this.service});

  Future<void> _launchWhatsApp() async {
    final message = Uri.encodeComponent("I wanna buy this service: ${service.name}");
    final whatsappUrl = "https://wa.me/${service.whatsappNumber}?text=$message";
    final uri = Uri.tryParse(whatsappUrl);
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: service.imageUrl.isNotEmpty
                ? Image.network(
                    service.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppColors.darkBgContainer,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryOrange,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primaryOrange.withValues(alpha: 0.3),
                        child: const Center(
                          child: HugeIcon(
                            icon: HugeIconsStrokeRounded.image02,
                            color: AppColors.creamWhite,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    color: AppColors.primaryOrange.withValues(alpha: 0.3),
                    child: const Center(
                      child: HugeIcon(
                        icon: HugeIconsStrokeRounded.image02,
                        color: AppColors.creamWhite,
                        size: 40,
                      ),
                    ),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          service.name,
                          style: AppTextStyles.headline4(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AppDropdown(
                        button: const Icon(Icons.more_vert, color: AppColors.white),
                        overlayWidth: 160,
                        overlayAlignment: Alignment.centerRight,
                        onItemSelected: (value) {
                          if (value == 'delete') {
                            ref
                                .read(serviceProductProvider(service.groupId).notifier)
                                .deleteProduct(
                                  productId: service.id!,
                                  successCallBack: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Service deleted')),
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
                                  style: AppTextStyles.overLine(color: AppColors.white),
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
                                  style: AppTextStyles.overLine(color: AppColors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description,
                    style: AppTextStyles.overLine(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              if (service.discountPrice != null && service.discountPrice! > 0) ...[
                                TextSpan(
                                  text: "₹${service.discountPrice} ",
                                  style: AppTextStyles.bodyText1(color: AppColors.primaryOrange),
                                ),
                                TextSpan(
                                  text: "₹${service.price}",
                                  style: AppTextStyles.bodyText1(color: AppColors.creamWhite).copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: AppColors.creamWhite,
                                  ),
                                ),
                              ] else ...[
                                TextSpan(
                                  text: "₹${service.price}",
                                  style: AppTextStyles.bodyText1(color: AppColors.primaryOrange),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...List.generate(5, (index) {
                            return HugeIcon(
                              icon: HugeIconsStrokeRounded.star,
                              color: index < service.rating
                                  ? AppColors.primaryOrange
                                  : AppColors.creamWhite,
                              size: 14,
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  AppButton(
                    onPressed: _launchWhatsApp,
                    label: AppStrings.buyNow,
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
          ),
        ],
      ),
    );
  }
}
