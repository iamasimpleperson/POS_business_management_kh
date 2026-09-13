import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/register_controller.dart';

class RegisterTextFieldWidget extends ConsumerWidget {
  const RegisterTextFieldWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registerProvider);
    final controller = ref.read(registerProvider.notifier);

    return Column(
      children: [
        _buildTextField(
          label: 'ឈ្មោះហៅក្រៅ',
          hint: 'បញ្ចូលឈ្មោះហៅក្រៅរបស់អ្នក',
          icon: Icons.person_outline,
          onChanged: controller.updateName,
        ),
        _buildTextField(
          label: 'អ៊ីមែល',
          hint: 'បញ្ចូលអ៊ីមែលរបស់អ្នក',
          icon: Icons.email_outlined,
          onChanged: controller.updateEmail,
        ),
        _buildTextField(
          label: 'លេខទូរស័ព្ទ',
          hint: 'បញ្ចូលលេខទូរស័ព្ទរបស់អ្នក',
          icon: Icons.phone_outlined,
          onChanged: controller.updatePhone,
        ),
        _buildTextField(
          label: 'ពាក្យសម្ងាត់',
          hint: 'បញ្ចូលពាក្យសម្ងាត់ (យ៉ាងតិច ៨ តួអក្សរ)',
          icon: Icons.lock_outline,
          onChanged: controller.updatePassword,
          isPassword: true,
          isPasswordVisible: state.isPasswordVisible,
          onVisibilityToggle: controller.togglePasswordVisibility,
          helperOrErrorText: state.passwordWarning,
        ),
      ],
    );
  }
}

Widget _buildTextField({
  required String label,
  required String hint,
  required IconData icon,
  required Function(String) onChanged,
  bool isPassword = false,
  bool isPasswordVisible = false,
  VoidCallback? onVisibilityToggle,
  String? helperOrErrorText,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextFormField(
        onChanged: onChanged,
        obscureText: isPassword && !isPasswordVisible,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: helperOrErrorText != null
                  ? Colors.orange.shade400
                  : Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: helperOrErrorText != null
                  ? Colors.orange
                  : const Color(0xFF2E7D32),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
      ),
      if (helperOrErrorText != null) ...[
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.info_outline, size: 14, color: Colors.orange[800]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                helperOrErrorText,
                style: TextStyle(
                  color: Colors.orange[800],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
      const SizedBox(height: 16),
    ],
  );
}
