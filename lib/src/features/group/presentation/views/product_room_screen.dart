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
import 'package:larnity/src/features/group/presentation/provider/product_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/features/group/presentation/widgets/add_product.dart';
import 'package:larnity/src/features/group/presentation/widgets/product_card.dart';

class ProductRoomScreen extends ConsumerStatefulWidget {
  const ProductRoomScreen({super.key});

  @override
  ConsumerState<ProductRoomScreen> createState() => _ProductRoomScreenState();
}

class _ProductRoomScreenState extends ConsumerState<ProductRoomScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final groupId = ref.read(groupProvider).group?.id;
      if (groupId != null) {
        ref.read(productProvider(groupId).notifier).fetchProducts(type: 'PRODUCT');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupId = ref.watch(groupProvider).group?.id;

    if (groupId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Product Room"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(Routes.group);
              }
            },
          ),
        ),
        backgroundColor: AppColors.bgBlue,
        body: const Center(
          child: Text(
            "No group selected",
            style: TextStyle(color: AppColors.white),
          ),
        ),
      );
    }

    final productState = ref.watch(productProvider(groupId));
    final products = productState.products ?? [];
    final isLoading = productState.fetchState == AsyncState.loading && products.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Room"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(Routes.group);
            }
          },
        ),
      ),
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
                      AppStrings.productRoom,
                      style: AppTextStyles.headline2(color: AppColors.white),
                    ),
                    Text(
                      "${products.length} ${AppStrings.productsAvailable}",
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
                        child: AddProduct(),
                      ),
                    );
                  },
                  prefix: const HugeIcon(
                    icon: HugeIconsStrokeRounded.addCircle,
                    color: AppColors.black,
                  ),
                  label: AppStrings.addProduct,
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
                  : products.isEmpty
                      ? const Center(
                          child: Text(
                            "No products added yet.",
                            style: TextStyle(color: AppColors.skyBlue),
                          ),
                        )
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppSizes.xs,
                            mainAxisSpacing: AppSizes.xs,
                            childAspectRatio: 0.42, // Increased height
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return ProductCard(product: products[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
