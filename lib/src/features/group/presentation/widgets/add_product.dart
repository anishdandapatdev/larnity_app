import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:image_picker/image_picker.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_storage_service.dart';
import 'package:larnity/src/features/group/data/models/product_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/product_provider.dart';

class AddProduct extends ConsumerStatefulWidget {
  const AddProduct({super.key});

  @override
  ConsumerState<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends ConsumerState<AddProduct> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _whatsappController = TextEditingController();
  File? _imageFile;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to pick image: $e")));
    }
  }

  Future<void> _submit() async {
    final groupId = ref.read(groupProvider).group?.id;
    if (groupId == null) return;

    final name = _nameController.text.trim();
    final desc = _descController.text.trim();
    final priceStr = _priceController.text.trim();
    final whatsapp = _whatsappController.text.trim();
    
    if (name.isEmpty || desc.isEmpty || priceStr.isEmpty || whatsapp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      String imageUrl = '';
      try {
        final storageService = ref.read(storageServiceProvider);
        final storagePath = SupabaseStorageService.generatePath(
          fileName: _imageFile!.path.split('/').last,
          subfolder: 'products',
        );

        imageUrl = await storageService.uploadFile(
          bucket: StorageBucket.productMedia,
          path: storagePath,
          file: _imageFile!,
        );
      } catch (e) {
        imageUrl = 'https://via.placeholder.com/300x200.png?text=Product+Image';
      }

      num price = num.tryParse(priceStr) ?? 0;
      num? discountPrice = num.tryParse(_discountPriceController.text.trim());

      final product = ProductModel(
        groupId: groupId,
        name: name,
        description: desc,
        price: price,
        discountPrice: discountPrice,
        whatsappNumber: "+91$whatsapp",
        imageUrl: imageUrl,
        type: 'PRODUCT',
        rating: 0,
      );

      ref.read(productProvider(groupId).notifier).addProduct(
        product: product,
        successCallBack: () {
          if (!mounted) return;
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product added successfully!')));
        },
        failureCallBack: (error) {
          if (!mounted) return;
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    if (!_isSaving) context.pop();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppStrings.createNewProduct, style: AppTextStyles.headline4()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    AppStrings.createNewProductDesc,
                    style: AppTextStyles.overLine(color: AppColors.skyBlue),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            AppSizes.lg.ph,

            Text(AppStrings.productName, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.white),
              decoration: _inputDecoration(AppStrings.productNameHint),
            ),
            AppSizes.xs.ph,
            Text(AppStrings.productDescription, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: _descController,
              style: const TextStyle(color: AppColors.white),
              decoration: _inputDecoration(AppStrings.productDescriptionHint),
              maxLines: 5,
              minLines: 2,
            ),
            AppSizes.xs.ph,
            Text(AppStrings.productPrice, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: _priceController,
              style: const TextStyle(color: AppColors.white),
              keyboardType: TextInputType.number,
              decoration: _inputDecoration("0"),
            ),
            AppSizes.xs.ph,
            Text(AppStrings.productDiscountPrice, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: _discountPriceController,
              style: const TextStyle(color: AppColors.white),
              keyboardType: TextInputType.number,
              decoration: _inputDecoration("0"),
            ),
            AppSizes.xs.ph,
            Text(AppStrings.whatsappNumber, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: _whatsappController,
              style: const TextStyle(color: AppColors.white),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: "Enter number",
                hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                prefixText: '+91 ',
                prefixStyle: const TextStyle(color: AppColors.white),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                  borderSide: BorderSide(color: AppColors.skyBlue.withValues(alpha: 0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                  borderSide: const BorderSide(color: AppColors.skyBlue),
                ),
              ),
            ),
            AppSizes.xs.ph,
            
            GestureDetector(
              onTap: _isSaving ? null : _pickImage,
              child: Container(
                height: 0.2.sh,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(AppSizes.xs),
                  image: _imageFile != null
                      ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                      : null,
                ),
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const HugeIcon(icon: HugeIconsStrokeRounded.image02, color: AppColors.creamWhite, size: 40),
                          AppSizes.xs.ph,
                          Text(AppStrings.uploadImage, style: AppTextStyles.overLine(color: AppColors.creamWhite)),
                        ],
                      )
                    : Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: const Center(child: Icon(Icons.change_circle, color: Colors.white, size: 40)),
                      ),
              ),
            ),
            AppSizes.xs.ph,
            AppButton(
              onPressed: _isSaving ? () {} : _submit,
              label: _isSaving ? "Creating..." : AppStrings.create,
              labelStyle: AppTextStyles.bodyText2(color: _isSaving ? AppColors.white : AppColors.black),
              bgColor: _isSaving ? AppColors.skyBlue : AppColors.primaryOrange,
              radius: AppSizes.xxxs,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.darkBgContainer,
      hintText: hint,
      hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.xxxs),
        borderSide: BorderSide(color: AppColors.skyBlue.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.xxxs),
        borderSide: const BorderSide(color: AppColors.skyBlue),
      ),
    );
  }
}
