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
import 'package:larnity/src/features/group/presentation/provider/product_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductCard extends ConsumerWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  Future<void> _launchWhatsApp() async {
    final priceInfo = (product.discountPrice != null && product.discountPrice! > 0)
        ? 'Price: ₹${product.discountPrice} (was ₹${product.price})'
        : 'Price: ₹${product.price}';

    final message = Uri.encodeComponent(
      'Hi! I\'m interested in buying this product:\n\n'
      '🛍️ *${product.name}*\n'
      '📝 ${product.description}\n'
      '💰 $priceInfo\n\n'
      'Please let me know how to proceed. Thank you!',
    );
    final whatsappUrl = 'https://wa.me/${product.whatsappNumber}?text=$message';
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
          // Product image
          SizedBox(
            height: 180,
            width: double.infinity,
            child: product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl,
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

          // Product details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + menu
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: AppTextStyles.headline4(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AppDropdown(
                        button: const Icon(Icons.more_vert, color: AppColors.white, size: 18),
                        overlayWidth: 160,
                        overlayAlignment: Alignment.centerRight,
                        onItemSelected: (value) {
                          if (value == 'delete') {
                            ref
                                .read(productProvider(product.groupId).notifier)
                                .deleteProduct(
                                  productId: product.id!,
                                  successCallBack: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Product deleted')),
                                    );
                                  },
                                );
                          }
                        },
                        items: [
                          AppDropdownItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const HugeIcon(
                                  icon: HugeIconsStrokeRounded.edit03,
                                  color: AppColors.primaryOrange,
                                ),
                                AppSizes.xxxs.pw,
                                Text(AppStrings.edit,
                                    style: AppTextStyles.overLine(color: AppColors.white)),
                              ],
                            ),
                          ),
                          AppDropdownItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const HugeIcon(
                                  icon: HugeIconsStrokeRounded.delete01,
                                  color: AppColors.red,
                                ),
                                AppSizes.xxxs.pw,
                                Text(AppStrings.delete,
                                    style: AppTextStyles.overLine(color: AppColors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  AppSizes.xs.ph,

                  // Description
                  Text(
                    product.description,
                    style: AppTextStyles.overLine(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSizes.xs.ph,

                  // Price + star rating — Flexible prevents right overflow
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: product.discountPrice != null && product.discountPrice! > 0
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '₹${product.discountPrice}',
                                    style: AppTextStyles.bodyText1(
                                        color: AppColors.primaryOrange),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '₹${product.price}',
                                    style: AppTextStyles.overLine(color: AppColors.creamWhite)
                                        .copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: AppColors.creamWhite,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              )
                            : Text(
                                '₹${product.price}',
                                style: AppTextStyles.bodyText1(color: AppColors.primaryOrange),
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                      const SizedBox(width: 4),
                      // Compact single-star + number rating
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const HugeIcon(
                            icon: HugeIconsStrokeRounded.star,
                            color: AppColors.primaryOrange,
                            size: 13,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${product.rating}',
                            style: AppTextStyles.overLine(color: AppColors.creamWhite),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Buy Now button
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
