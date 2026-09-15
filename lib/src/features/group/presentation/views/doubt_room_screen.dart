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
import 'package:larnity/src/features/group/presentation/provider/supporter_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/new_supporter.dart';
import 'package:url_launcher/url_launcher.dart';

class DoubtRoomScreen extends ConsumerStatefulWidget {
  const DoubtRoomScreen({super.key});

  @override
  ConsumerState<DoubtRoomScreen> createState() => _DoubtRoomScreenState();
}

class _DoubtRoomScreenState extends ConsumerState<DoubtRoomScreen> {
  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupId = ref.watch(groupProvider).group?.id;

    if (groupId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Doubt Room")),
        body: const Center(
          child: Text(
            "No group selected",
            style: TextStyle(color: AppColors.white),
          ),
        ),
        backgroundColor: AppColors.bgBlue,
      );
    }

    final supporterState = ref.watch(supporterProvider(groupId));
    final supporters = supporterState.supporters ?? [];
    final isLoading =
        supporterState.fetchState == AsyncState.loading && supporters.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.bgBlue,
      appBar: AppBar(title: const Text("Doubt Room")),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.xs),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.supporterPage,
                      style: AppTextStyles.headline4(color: AppColors.white),
                    ),
                    Text(
                      "${supporters.length} ${AppStrings.supportersAvailable}",
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
                        child: NewSupporter(),
                      ),
                    );
                  },
                  prefix: const HugeIcon(
                    icon: HugeIconsStrokeRounded.addCircle,
                    color: AppColors.black,
                  ),
                  label: AppStrings.newSupporter,
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
                  : supporters.isEmpty
                  ? const Center(
                      child: Text(
                        "No supporters yet. Add one!",
                        style: TextStyle(color: AppColors.skyBlue),
                      ),
                    )
                  : ListView.builder(
                      itemCount: supporters.length,
                      itemBuilder: (context, index) {
                        final supporter = supporters[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSizes.xs),
                          padding: const EdgeInsets.all(AppSizes.xs),
                          decoration: BoxDecoration(
                            color: AppColors.darkBgContainer,
                            borderRadius: BorderRadius.circular(AppSizes.xs),
                            border: Border.all(
                              color: AppColors.skyBlue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.primaryOrange,
                                    backgroundImage:
                                        supporter.supporterImage != null
                                        ? NetworkImage(
                                            supporter.supporterImage!,
                                          )
                                        : null,
                                    child: supporter.supporterImage == null
                                        ? const Icon(
                                            Icons.person,
                                            color: AppColors.white,
                                          )
                                        : null,
                                  ),
                                  AppSizes.xs.pw,
                                  Expanded(
                                    child: Text(
                                      supporter.supporterName,
                                      style: AppTextStyles.headline3(
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              AppSizes.xs.ph,
                              Wrap(
                                spacing: AppSizes.xs,
                                runSpacing: AppSizes.xs,
                                children: [
                                  if (supporter.whatsappNumber != null &&
                                      supporter.whatsappNumber!.isNotEmpty)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        String waNum = supporter.whatsappNumber!
                                            .replaceAll('+', '')
                                            .replaceAll('-', '')
                                            .replaceAll(' ', '');
                                        if (!waNum.startsWith('91')) {
                                          waNum = '91$waNum';
                                        }
                                        _launchUrl("https://wa.me/$waNum");
                                      },
                                      icon: const HugeIcon(
                                        icon: HugeIconsStrokeRounded.message02,
                                        size: 16,
                                        color: AppColors.white,
                                      ),
                                      label: const Text("WhatsApp"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: AppColors.white,
                                      ),
                                    ),
                                  if (supporter.phoneNumber != null &&
                                      supporter.phoneNumber!.isNotEmpty)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        _launchUrl(
                                          "tel:${supporter.phoneNumber}",
                                        );
                                      },
                                      icon: const HugeIcon(
                                        icon: HugeIconsStrokeRounded.call,
                                        size: 16,
                                        color: AppColors.white,
                                      ),
                                      label: const Text("Call"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.skyBlue,
                                        foregroundColor: AppColors.white,
                                      ),
                                    ),
                                  if (supporter.link != null &&
                                      supporter.link!.isNotEmpty)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        var url = supporter.link!;
                                        if (!url.startsWith('http')) {
                                          url = 'https://$url';
                                        }
                                        _launchUrl(url);
                                      },
                                      icon: const HugeIcon(
                                        icon: HugeIconsStrokeRounded.link01,
                                        size: 16,
                                        color: AppColors.white,
                                      ),
                                      label: const Text("Book"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.primaryOrange,
                                        foregroundColor: AppColors.black,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
