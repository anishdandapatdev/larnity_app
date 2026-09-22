import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/extensions/slugify_extension.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/explore/domain/category.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/package_subscription/presentation/providers/package_subscription_provider.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Category? _selectedCategory;
  GroupPrivacy _selectedPrivacy = GroupPrivacy.PUBLIC;

  @override
  void initState() {
    super.initState();
    // Default to a popular category if available
    if (categories.isNotEmpty) {
      _selectedCategory = categories.firstWhere(
        (c) => c.name != 'All',
        orElse: () => categories.first,
      );
    }
    _nameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String get _generatedSlug {
    final text = _nameController.text.trim();
    if (text.isEmpty) return 'your-community-name';
    return text.slugify();
  }

  void _handleCreateGroup() {
    final user = ref.read(authProvider).user;
    if (user == null || user.id == null || user.id!.isEmpty) {
      showErrorToast(content: "Please log in to create a group");
      return;
    }

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showErrorToast(content: "Please enter a group name");
      return;
    }

    if (_selectedCategory == null) {
      showErrorToast(content: "Please select a category");
      return;
    }

    final packageSubscriptionState = ref.read(packageSubscriptionProvider);
    final subscriptionId = packageSubscriptionState.activeSubscription?.id;

    final group = GroupModel(
      createdAt: DateTime.now(),
      name: name,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      slug: "$_generatedSlug-${DateTime.now().millisecondsSinceEpoch % 1000000}",
      userId: user.id,
      category: _selectedCategory!.name.slugify(),
      privacy: _selectedPrivacy,
      packageSubscriptionId: subscriptionId,
      status: GroupStatus.CREATED,
      active: true,
    );

    ref.read(groupProvider.notifier).createGroup(
      group: group,
      successCallBack: () {
        _showSuccessDialog(name);
        _nameController.clear();
        _descriptionController.clear();
      },
      failureCallBack: (err) {
        showErrorToast(content: err);
      },
    );
  }

  void _showSuccessDialog(String groupName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.primaryOrange.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: AppColors.green, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Community Created!',
                style: TextStyle(color: AppColors.white, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          '"$groupName" has been successfully created. You can now configure classroom courses, invite members, and start discussions!',
          style: const TextStyle(color: AppColors.creamWhite, fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Awesome',
              style: TextStyle(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupProvider);
    final isLoading = groupState.createState == AsyncState.loading;
    final packageSubscriptionState = ref.watch(packageSubscriptionProvider);

    return Scaffold(
      backgroundColor: AppColors.bgBlue,
      appBar: AppBar(
        backgroundColor: AppColors.bgBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(Routes.explore);
            }
          },
        ),
        title: const Text(
          'Create Community',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Badge & Title
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryOrange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(
                      icon: HugeIconsStrokeRounded.userGroup,
                      color: AppColors.primaryOrange,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'COMMUNITY BUILDER',
                      style: AppTextStyles.caption(
                        color: AppColors.primaryOrange,
                      ).copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Create New Group',
                style: AppTextStyles.headline2(
                  color: AppColors.white,
                ).copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Launch a vibrant space for courses, discussions, and member connections.',
                style: AppTextStyles.caption(
                  color: AppColors.creamWhite,
                ).copyWith(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),

              // Subscription Status Banner
              if (packageSubscriptionState.activeSubscription != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.darkBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, color: AppColors.green, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Active Subscription: ${packageSubscriptionState.totalGroupsCreated} group(s) created',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Section 1: Group Name
              Text(
                'Community Name',
                style: AppTextStyles.subtitle1(color: AppColors.white).copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.darkBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(color: AppColors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'e.g., NextGen Mobile Developers',
                    hintStyle: TextStyle(
                      color: AppColors.creamWhite.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                    prefixIcon: const HugeIcon(
                      icon: HugeIconsStrokeRounded.userGroup,
                      color: AppColors.creamWhite,
                      size: 18,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Live slug preview
              Row(
                children: [
                  Text(
                    'Slug: ',
                    style: AppTextStyles.caption(color: AppColors.creamWhite.withValues(alpha: 0.6)),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '/$_generatedSlug',
                        style: const TextStyle(
                          color: AppColors.primaryOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Section 2: Description (Optional)
              Text(
                'Description & Tagline',
                style: AppTextStyles.subtitle1(color: AppColors.white).copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.darkBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: const TextStyle(color: AppColors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Describe your community mission, courses, and who should join...',
                    hintStyle: TextStyle(
                      color: AppColors.creamWhite.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Section 3: Category Selection
              Text(
                'Select Category',
                style: AppTextStyles.subtitle1(color: AppColors.white).copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories
                    .where((c) => c.name != 'All')
                    .map((cat) {
                  final isSelected = _selectedCategory?.name == cat.name;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryOrange.withValues(alpha: 0.2)
                            : AppColors.darkBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryOrange
                              : Colors.white.withValues(alpha: 0.1),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HugeIcon(
                            icon: cat.icon,
                            color: isSelected ? AppColors.primaryOrange : AppColors.creamWhite,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat.name,
                            style: TextStyle(
                              color: isSelected ? AppColors.primaryOrange : AppColors.white,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Section 4: Privacy Selection
              Text(
                'Community Privacy',
                style: AppTextStyles.subtitle1(color: AppColors.white).copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildPrivacyCard(
                      title: 'Public',
                      subtitle: 'Anyone can discover and join this group freely.',
                      privacy: GroupPrivacy.PUBLIC,
                      icon: HugeIconsStrokeRounded.global,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPrivacyCard(
                      title: 'Private',
                      subtitle: 'Members require invitation or approval.',
                      privacy: GroupPrivacy.PRIVATE,
                      icon: HugeIconsStrokeRounded.securityCheck,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section 5: Live Preview Card
              Text(
                'Live Preview',
                style: AppTextStyles.subtitle1(color: AppColors.white).copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildLivePreviewCard(),
              const SizedBox(height: 28),

              // Create Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleCreateGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            HugeIcon(
                              icon: HugeIconsStrokeRounded.addCircle,
                              color: Colors.black,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Create Community',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyCard({
    required String title,
    required String subtitle,
    required GroupPrivacy privacy,
    required List<List<dynamic>> icon,
  }) {
    final isSelected = _selectedPrivacy == privacy;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPrivacy = privacy;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryOrange.withValues(alpha: 0.15)
              : AppColors.darkBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryOrange
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HugeIcon(
                  icon: icon,
                  color: isSelected ? AppColors.primaryOrange : AppColors.creamWhite,
                  size: 20,
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppColors.primaryOrange, size: 18),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.primaryOrange : AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.creamWhite.withValues(alpha: 0.7),
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePreviewCard() {
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'Your Community Title';
    final desc = _descriptionController.text.trim().isNotEmpty
        ? _descriptionController.text.trim()
        : 'A space for learning, discussions, and collaboration.';
    final categoryName = _selectedCategory?.name ?? 'General';
    final isPublic = _selectedPrivacy == GroupPrivacy.PUBLIC;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryOrange.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Community Avatar / Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryOrange,
                      AppColors.primaryOrange.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: HugeIcon(
                    icon: HugeIconsStrokeRounded.userGroup,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.subtitle1(color: AppColors.white).copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'larnity.com/group/$_generatedSlug',
                      style: TextStyle(
                        color: AppColors.creamWhite.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Privacy Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isPublic ? AppColors.green : AppColors.primaryOrange)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isPublic ? AppColors.green : AppColors.primaryOrange,
                  ),
                ),
                child: Text(
                  isPublic ? 'PUBLIC' : 'PRIVATE',
                  style: TextStyle(
                    color: isPublic ? AppColors.green : AppColors.primaryOrange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: AppTextStyles.caption(color: AppColors.creamWhite).copyWith(
              fontSize: 12,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderBrown, height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              // Category tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.darkBgContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  categoryName,
                  style: const TextStyle(
                    color: AppColors.primaryOrange,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              const HugeIcon(
                icon: HugeIconsStrokeRounded.user,
                color: AppColors.creamWhite,
                size: 13,
              ),
              const SizedBox(width: 4),
              const Text(
                '1 Member (You)',
                style: TextStyle(color: AppColors.creamWhite, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
