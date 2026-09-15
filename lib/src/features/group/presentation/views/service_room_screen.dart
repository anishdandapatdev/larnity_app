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
import 'package:larnity/src/features/group/presentation/widgets/add_service.dart';
import 'package:larnity/src/features/group/presentation/widgets/service_card.dart';

/// Dedicated Riverpod provider for services so the state is independent
/// from the product-room provider (which uses type 'Product').
final serviceProductProvider = NotifierProvider.autoDispose
    .family<ProductNotifier, ProductState, String>(ProductNotifier.new);

class ServiceRoomScreen extends ConsumerStatefulWidget {
  const ServiceRoomScreen({super.key});

  @override
  ConsumerState<ServiceRoomScreen> createState() => _ServiceRoomScreenState();
}

class _ServiceRoomScreenState extends ConsumerState<ServiceRoomScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final groupId = ref.read(groupProvider).group?.id;
      if (groupId != null) {
        ref.read(serviceProductProvider(groupId).notifier).fetchProducts(type: 'SERVICE');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupId = ref.watch(groupProvider).group?.id;

    if (groupId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Service Room")),
        backgroundColor: AppColors.bgBlue,
        body: const Center(
          child: Text(
            "No group selected",
            style: TextStyle(color: AppColors.white),
          ),
        ),
      );
    }

    final state = ref.watch(serviceProductProvider(groupId));
    final services = state.products ?? [];
    final isLoading = state.fetchState == AsyncState.loading && services.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text("Service Room")),
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
                      AppStrings.serviceRoom,
                      style: AppTextStyles.headline2(color: AppColors.white),
                    ),
                    Text(
                      "${services.length} ${AppStrings.servicesAvailable}",
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
                        child: AddService(),
                      ),
                    );
                  },
                  prefix: const HugeIcon(
                    icon: HugeIconsStrokeRounded.addCircle,
                    color: AppColors.black,
                  ),
                  label: AppStrings.addService,
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
                  : services.isEmpty
                      ? const Center(
                          child: Text(
                            "No services added yet.",
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
                          itemCount: services.length,
                          itemBuilder: (context, index) {
                            return ServiceCard(service: services[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
