import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:intl/intl.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_table.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/manage_reasons.dart';

class LeaveReasonScreen extends ConsumerStatefulWidget {
  const LeaveReasonScreen({super.key});

  @override
  ConsumerState<LeaveReasonScreen> createState() => _LeaveReasonScreenState();
}

class _LeaveReasonScreenState extends ConsumerState<LeaveReasonScreen> {
  List<Map<String, dynamic>> _leaveRecords = [];
  bool _isLoading = false;
  String? _loadedGroupId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLeaveRecords();
    });
  }

  Future<void> _fetchLeaveRecords() async {
    final group = ref.read(groupProvider).group;
    if (group == null || group.id == null) return;
    if (_loadedGroupId == group.id && _leaveRecords.isNotEmpty) return;

    setState(() => _isLoading = true);
    _loadedGroupId = group.id;

    try {
      final client = ref.read(supabaseClientProvider);
      final response = await client
          .from('GroupMemberLeaves')
          .select()
          .eq('groupId', group.id!)
          .order('leftAt', ascending: false);

      if (mounted) {
        setState(() {
          _leaveRecords = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupProvider);
    final group = groupState.group;
    final isOwnerOrAdmin = ref.watch(isGroupAdminOrOwnerProvider);

    if (group == null) {
      return Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkBg,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text(
            "No group selected",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (!isOwnerOrAdmin) {
      return Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkBg,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text("Leave Reasons", style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: AppColors.primaryOrange),
                AppSizes.sm.ph,
                Text(
                  "Access Restricted",
                  style: AppTextStyles.headline2(color: AppColors.white),
                ),
                AppSizes.xs.ph,
                Text(
                  "Only group owners and admins can configure leave reasons.",
                  style: AppTextStyles.bodyText1(color: AppColors.skyBlue),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final dynamic rawReasons = group.landingSettings?['leaveReasons'];
    final List<String> configuredReasons = rawReasons is List
        ? rawReasons.map((e) => e.toString()).toList()
        : [
            "Too busy",
            "Content not relevant",
            "Financial reasons",
            "Found another community",
            "Other",
          ];

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Leave Reasons",
          style: AppTextStyles.headline3(color: AppColors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSizes.xs.ph,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.leaveReasons,
                        style: AppTextStyles.headline2(color: AppColors.white),
                      ),
                      Text(
                        AppStrings.leaveReasonsDesc,
                        style: AppTextStyles.overLine(color: AppColors.grey500),
                      ),
                    ],
                  ),
                ),
                AppButton(
                  isExpanded: false,
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                        backgroundColor: AppColors.darkBgContainer,
                        content: ManageReasons(),
                      ),
                    );
                    if (mounted) {
                      _fetchLeaveRecords();
                    }
                  },
                  prefix: const HugeIcon(
                    icon: HugeIconsStrokeRounded.addCircle,
                    color: AppColors.black,
                  ),
                  label: AppStrings.manageReasons,
                  labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
                  bgColor: AppColors.white,
                  radius: AppSizes.xxxs,
                ),
              ],
            ),
            AppSizes.sm.ph,
            Container(
              padding: const EdgeInsets.all(AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.darkBgContainer,
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                border: Border.all(
                  color: AppColors.skyBlue.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Configured Survey Reasons (${configuredReasons.length})",
                    style: AppTextStyles.button(color: AppColors.skyBlue),
                  ),
                  AppSizes.xxs.ph,
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: configuredReasons.map((reason) {
                      return Chip(
                        backgroundColor: AppColors.bgBlue,
                        side: BorderSide(
                          color: AppColors.skyBlue.withValues(alpha: 0.4),
                        ),
                        label: Text(
                          reason,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            AppSizes.sm.ph,
            Text(
              "Member Departure Feedback",
              style: AppTextStyles.headline3(color: AppColors.white),
            ),
            AppSizes.xs.ph,
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryOrange,
                      ),
                    )
                  : AppTable(
                      columns: [
                        TableColumn(
                          title: AppStrings.user,
                          width: 140,
                          cellBuilder: (index) {
                            final row = _leaveRecords[index];
                            final userName =
                                row['userName'] ?? row['userId'] ?? 'Unknown';
                            return Text(
                              userName.toString(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                        TableColumn(
                          title: AppStrings.reason,
                          width: 160,
                          cellBuilder: (index) {
                            final row = _leaveRecords[index];
                            return Text(
                              row['reason']?.toString() ?? 'No reason given',
                              style: const TextStyle(color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                        TableColumn(
                          title: 'Feedback',
                          width: 200,
                          cellBuilder: (index) {
                            final row = _leaveRecords[index];
                            return Text(
                              row['feedback']?.toString() ?? '-',
                              style: const TextStyle(color: Colors.grey),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                        TableColumn(
                          title: 'Left At',
                          width: 120,
                          cellBuilder: (index) {
                            final row = _leaveRecords[index];
                            final leftAtStr = row['leftAt']?.toString();
                            String formatted = '-';
                            if (leftAtStr != null) {
                              final dt = DateTime.tryParse(leftAtStr);
                              if (dt != null) {
                                formatted =
                                    DateFormat('MMM dd, yyyy').format(dt);
                              }
                            }
                            return Text(
                              formatted,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ],
                      rowCount: _leaveRecords.length,
                      emptyWidget: const Center(
                        child: Text(
                          "No members have left yet",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

