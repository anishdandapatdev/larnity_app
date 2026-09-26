import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/core/service/cache/user_cache_service.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/auth/data/models/user_model.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/profile/presentation/provider/profile_provider.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  // Profile fields
  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController phoneCtrl;

  // Image picker
  File? _pickedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    final currentUser = ref.read(authProvider).user;

    firstNameCtrl = TextEditingController(text: currentUser?.firstName ?? "");
    lastNameCtrl = TextEditingController(text: currentUser?.lastName ?? "");
    phoneCtrl = TextEditingController(text: currentUser?.phoneNumber ?? "");

    // Load cached profile data on startup if fields are empty
    _loadCachedProfile();
  }

  Future<void> _loadCachedProfile() async {
    final cache = ref.read(userCacheServiceProvider);
    final cached = await cache.getCachedProfile();

    if (!mounted) return;

    if (firstNameCtrl.text.isEmpty &&
        (cached['firstName']?.isNotEmpty ?? false)) {
      setState(() => firstNameCtrl.text = cached['firstName']!);
    }
    if (lastNameCtrl.text.isEmpty &&
        (cached['lastName']?.isNotEmpty ?? false)) {
      setState(() => lastNameCtrl.text = cached['lastName']!);
    }
    if (phoneCtrl.text.isEmpty && (cached['phoneNumber']?.isNotEmpty ?? false)) {
      setState(() => phoneCtrl.text = cached['phoneNumber']!);
    }
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
      );
      if (picked != null) {
        final file = File(picked.path);
        setState(() => _pickedImage = file);

        final currentUser = ref.read(authProvider).user;
        if (currentUser?.id != null) {
          // Immediately upload and update profile smoothly
          _uploadImage(file, currentUser!.id!);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.red,
            content: Text("Could not select image: $e"),
          ),
        );
      }
    }
  }

  void _uploadImage(File file, String userId) {
    ref.read(profileProvider.notifier).uploadProfileImage(
      imageFile: file,
      userId: userId,
      successCallBack: (imageUrl) {
        if (!mounted) return;
        setState(() => _pickedImage = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.green,
            content: Text("Profile photo updated successfully"),
          ),
        );
      },
      failureCallBack: (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.red,
            content: Text("Failed to upload photo: $error"),
          ),
        );
      },
    );
  }

  void _removePhoto(String userId) {
    ref.read(profileProvider.notifier).removeProfileImage(
      userId: userId,
      successCallBack: () {
        if (!mounted) return;
        setState(() => _pickedImage = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.green,
            content: Text("Profile photo removed"),
          ),
        );
      },
      failureCallBack: (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.red,
            content: Text("Failed to remove photo: $error"),
          ),
        );
      },
    );
  }

  void _showImageSourceDialog(UserModel? user) {
    final hasExistingPhoto =
        (user?.image != null && user!.image!.isNotEmpty) || _pickedImage != null;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkBgContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Profile Photo',
                style: AppTextStyles.headline2(color: AppColors.white),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.blue, size: 22),
                ),
                title: Text(
                  'Take Photo with Camera',
                  style: AppTextStyles.bodyText2(color: AppColors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library,
                      color: AppColors.primaryOrange, size: 22),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: AppTextStyles.bodyText2(color: AppColors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (hasExistingPhoto && user?.id != null) ...[
                const Divider(color: Colors.white12),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline,
                        color: AppColors.red, size: 22),
                  ),
                  title: Text(
                    'Remove Current Photo',
                    style: AppTextStyles.bodyText2(color: AppColors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removePhoto(user!.id!);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkBgContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.skyBlue.withValues(alpha: 0.2)),
        ),
        title: Row(
          children: [
            const Icon(Icons.logout, color: AppColors.red, size: 24),
            const SizedBox(width: 10),
            Text(
              'Sign Out',
              style: AppTextStyles.headline2(color: AppColors.white),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out of your account?',
          style: AppTextStyles.bodyText2(color: AppColors.white.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.white.withValues(alpha: 0.6)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).signOut(
                successCallBack: () {
                  if (context.mounted) {
                    context.goNamed(Routes.explore);
                  }
                },
              );
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider).user;
    final profileState = ref.watch(profileProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      final user = next.user;
      if (user == null) return;
      if (firstNameCtrl.text.isEmpty && (user.firstName?.isNotEmpty ?? false)) {
        firstNameCtrl.text = user.firstName!;
      }
      if (lastNameCtrl.text.isEmpty && (user.lastName?.isNotEmpty ?? false)) {
        lastNameCtrl.text = user.lastName!;
      }
      if (phoneCtrl.text.isEmpty && (user.phoneNumber?.isNotEmpty ?? false)) {
        phoneCtrl.text = user.phoneNumber!;
      }
    });

    final canPop = context.canPop();

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.white),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(
          'Profile Settings',
          style: AppTextStyles.headline2(color: AppColors.white),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero Profile Card ───────────────────────────────────────
              _buildHeroHeader(currentUser, profileState),

              AppSizes.md.ph,

              // ── Personal Information ─────────────────────────────────────
              _buildPersonalInfoSection(currentUser, profileState),

              AppSizes.md.ph,

              // ── Security & Password ──────────────────────────────────────
              _buildSecuritySection(),

              AppSizes.md.ph,

              // ── Account & Session ────────────────────────────────────────
              _buildSessionSection(),

              AppSizes.xxlg.ph,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(UserModel? user, ProfileState profileState) {
    final displayName = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
    final nameToShow = displayName.isNotEmpty ? displayName : "Larnity Member";
    final emailToShow = user?.email ?? "No email associated";
    final roleToShow = (user?.role.isNotEmpty ?? false) ? user!.role.toUpperCase() : "MEMBER";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.darkBgContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Avatar with gradient ring & camera badge
          GestureDetector(
            onTap: profileState.imageState == AsyncState.loading
                ? null
                : () => _showImageSourceDialog(user),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryOrange, AppColors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.darkBg,
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!) as ImageProvider
                        : (user?.image != null && user!.image!.isNotEmpty)
                            ? NetworkImage(user.image!)
                            : null,
                    child: (_pickedImage == null &&
                            (user?.image == null || user!.image!.isEmpty))
                        ? Text(
                            _getInitials(user?.firstName, user?.lastName),
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                // Camera action badge
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.darkBgContainer, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Loading spinner overlay during upload
                if (profileState.imageState == AsyncState.loading)
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // User metadata
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nameToShow,
                  style: AppTextStyles.headline2(color: AppColors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.verified,
                      size: 14,
                      color: AppColors.blue,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        emailToShow,
                        style: AppTextStyles.bodyText2(
                          color: AppColors.white.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryOrange.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    roleToShow,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryOrange,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(UserModel? user, ProfileState profileState) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.darkBgContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, color: AppColors.primaryOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Personal Information',
                style: AppTextStyles.headline2(color: AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Update your personal details and contact info',
            style: AppTextStyles.bodyText2(color: AppColors.white.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 16),

          // First & Last Name
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "First Name",
                      style: AppTextStyles.bodyText2(color: AppColors.white),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: firstNameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("First name"),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Last Name",
                      style: AppTextStyles.bodyText2(color: AppColors.white),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: lastNameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Last name"),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Phone Number
          Text(
            "Phone Number",
            style: AppTextStyles.bodyText2(color: AppColors.white),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: phoneCtrl,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-\(\)\+]')),
            ],
            decoration: _inputDecoration("+91 98765 43210"),
          ),

          const SizedBox(height: 18),

          // Save Changes Button
          AppButton(
            isExpanded: true,
            isLoading: profileState.state == AsyncState.loading,
            onPressed: () {
              if (user == null) return;
              final fName = firstNameCtrl.text.trim();
              final lName = lastNameCtrl.text.trim();
              final phone = phoneCtrl.text.trim();

              if (fName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppColors.red,
                    content: Text("First name cannot be empty"),
                  ),
                );
                return;
              }

              final effectiveId = user.id ??
                  ref.read(authProvider).user?.id ??
                  ref.read(supabaseClientProvider).auth.currentUser?.id;
              final updatedUser = user.copyWith(
                id: effectiveId,
                firstName: fName,
                lastName: lName,
                phoneNumber: phone,
              );

              ref.read(profileProvider.notifier).createProfile(
                user: updatedUser,
                successCallBack: () {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.green,
                      content: Text("Profile details saved successfully"),
                    ),
                  );
                },
                failureCallBack: (error) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.red,
                      content: Text("Failed to update profile: $error"),
                    ),
                  );
                },
              );
            },
            bgColor: AppColors.primaryOrange,
            label: "Save Changes",
            labelStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            radius: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBgContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.pushNamed(Routes.changePassword);
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.sm),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: AppColors.blue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Change Password',
                        style: AppTextStyles.headline2(color: AppColors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Update your account password securely',
                        style: AppTextStyles.bodyText2(
                          color: AppColors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.white.withValues(alpha: 0.6),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.darkBgContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.manage_accounts_outlined,
                  color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Account & Session',
                style: AppTextStyles.headline2(color: AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Manage your login session or sign out',
            style: AppTextStyles.bodyText2(color: AppColors.white.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 16),

          // Sign Out Button
          AppButton(
            isExpanded: true,
            onPressed: _showSignOutDialog,
            bgColor: AppColors.red.withValues(alpha: 0.1),
            borderColor: AppColors.red.withValues(alpha: 0.5),
            label: "Sign Out",
            labelStyle: const TextStyle(
              color: AppColors.red,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            icon: const Icon(Icons.logout, color: AppColors.red, size: 18),
            radius: 8,
          ),

          const SizedBox(height: 14),

          // App version info
          Center(
            child: Text(
              'Larnity v1.0.0 • Secure Session',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.3),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String? firstName, String? lastName) {
    final first = (firstName != null && firstName.isNotEmpty)
        ? firstName[0].toUpperCase()
        : '';
    final last = (lastName != null && lastName.isNotEmpty)
        ? lastName[0].toUpperCase()
        : '';
    final result = '$first$last';
    return result.isNotEmpty ? result : 'U';
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.black,
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.white.withValues(alpha: 0.3), fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.skyBlue.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.skyBlue.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryOrange, width: 1.2),
      ),
    );
  }
}
