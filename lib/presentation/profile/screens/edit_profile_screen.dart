import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/media_url.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/upload_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../common/widgets/app_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _taglineCtrl = TextEditingController();
  File? _pickedImage;
  bool _saving = false;
  bool _init = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _taglineCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() => _pickedImage = File(picked.path));
      }
    } catch (_) {
      _snack('Gagal memilih foto', AppColors.destructive);
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _snack('Nama tidak boleh kosong', AppColors.destructive);
      return;
    }
    setState(() => _saving = true);
    try {
      String? avatarUrl;
      if (_pickedImage != null) {
        avatarUrl = await sl<UploadRepository>().uploadImage(_pickedImage!);
      }
      await sl<AuthRepository>().updateProfile(
        name: name,
        avatar: avatarUrl,
        bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        tagline: _taglineCtrl.text.trim().isEmpty ? null : _taglineCtrl.text.trim(),
      );
      if (!mounted) return;
      context.read<AuthBloc>().add(const AuthProfileRefreshRequested());
      _snack('Profil berhasil diperbarui', AppColors.success);
      context.pop();
    } catch (e) {
      _snack('Gagal memperbarui profil', AppColors.destructive);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc b) => b.state.user);
    if (!_init && user != null) {
      _nameCtrl.text = user.name;
      _init = true;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Edit Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: _pickedImage != null
                      ? CircleAvatar(radius: 56, backgroundImage: FileImage(_pickedImage!))
                      : AppAvatar(
                          imageUrl: resolveMediaUrl(user?.avatar),
                          name: user?.name,
                          size: 112,
                        ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: _pickPhoto,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.card, width: 3),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.image_outlined, size: 18),
              label: const Text('Ubah Foto Profil'),
            ),
          ),
          const SizedBox(height: 16),
          _field(label: 'Nama', controller: _nameCtrl, hint: 'Nama lengkap', icon: Icons.person_outline_rounded),
          const SizedBox(height: 16),
          _field(label: 'Tagline', controller: _taglineCtrl, hint: 'Motivasi singkat (opsional)', icon: Icons.short_text_rounded),
          const SizedBox(height: 16),
          _field(label: 'Bio', controller: _bioCtrl, hint: 'Ceritakan tentang dirimu (opsional)', icon: Icons.notes_rounded, maxLines: 4),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _saving
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.foreground)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: maxLines == 1 ? Icon(icon, color: AppColors.mutedForeground) : null,
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border.withOpacity(0.6))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
      ],
    );
  }
}
