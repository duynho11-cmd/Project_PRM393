import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();

  bool isLoading = false;
  bool isFetching = true;

  File? selectedImage;
  String photoUrl = '';

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => isFetching = false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!mounted) return;

    final data = doc.data();

    fullNameController.text = data?['fullName'] ?? user.displayName ?? '';
    emailController.text = user.email ?? '';
    photoUrl = data?['photoUrl'] ?? '';

    setState(() => isFetching = false);
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    setState(() {
      selectedImage = File(pickedFile.path);
    });
  }

  Future<String?> uploadImage(String uid) async {
    if (selectedImage == null) return photoUrl;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('avatars')
          .child('$uid.jpg');

      await ref.putFile(selectedImage!);

      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final fullName = fullNameController.text.trim();

    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập họ tên"),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final imageUrl = await uploadImage(user.uid);

      await user.updateDisplayName(fullName);

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fullName': fullName,
        'photoUrl': imageUrl ?? '',
        'updatedAt': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cập nhật thông tin thành công"),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi cập nhật: $e"),
          backgroundColor: AppColors.accentRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Widget buildAvatar() {
    return Stack(
      children: [
        GestureDetector(
          onTap: pickImage,
          child: Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: Colors.white.withOpacity(0.45),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: selectedImage != null
                  ? Image.file(
                selectedImage!,
                fit: BoxFit.cover,
              )
                  : photoUrl.isNotEmpty
                  ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.person_rounded,
                    size: 54,
                    color: AppColors.secondary,
                  );
                },
              )
                  : const Icon(
                Icons.person_rounded,
                size: 54,
                color: AppColors.secondary,
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: pickImage,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: AppColors.premiumShadow(
                  color: AppColors.secondary.withOpacity(0.3),
                  blur: 6,
                ),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: AppColors.textDark,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textGrey, fontSize: 15),
        prefixIcon: Icon(
          icon,
          color: AppColors.textGrey,
          size: 22,
        ),
        suffixIcon: readOnly
            ? const Icon(
          Icons.lock_outline_rounded,
          color: AppColors.textLight,
          size: 20,
        )
            : null,
        filled: true,
        fillColor: readOnly ? const Color(0xFFF8FAFC) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: AppColors.primaryGradient,
        boxShadow: AppColors.premiumShadow(
          color: AppColors.primary.withOpacity(0.2),
          blur: 24,
          offset: const Offset(0, 10),
        ),
      ),
      child: Column(
        children: [
          buildAvatar(),
          const SizedBox(height: 16),
          const Text(
            "Cập nhật hồ sơ",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Nhấn vào ảnh để thay đổi ảnh đại diện",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.premiumShadow(),
      ),
      child: Column(
        children: [
          buildInput(
            controller: fullNameController,
            label: "Họ và tên",
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 16),
          buildInput(
            controller: emailController,
            label: "Email",
            icon: Icons.email_outlined,
            readOnly: true,
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.textGrey,
                size: 18,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Email không thể thay đổi trong màn này.",
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppColors.primaryGradient,
        boxShadow: AppColors.premiumShadow(
          color: AppColors.primary.withOpacity(0.25),
          blur: 16,
          offset: const Offset(0, 6),
        ),
      ),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : updateProfile,
        icon: isLoading ? const SizedBox() : const Icon(Icons.save_outlined, color: Colors.white),
        label: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : const Text(
          "Lưu thay đổi",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Chỉnh sửa hồ sơ",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: false,
      ),
      body: isFetching
          ? buildLoading()
          : ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          buildHeader(),
          const SizedBox(height: 24),
          buildFormCard(),
          const SizedBox(height: 24),
          buildSaveButton(),
        ],
      ),
    );
  }
}