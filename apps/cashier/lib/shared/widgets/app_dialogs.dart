import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../app/theme/app_theme.dart';

enum FeedbackType { success, error, warning, info }

/// Utilitas global untuk menampilkan dialog & notifikasi feedback (Sukses, Gagal, Peringatan, Konfirmasi)
class AppFeedback {
  AppFeedback._();

  /// Membersihkan pesan error teknis menjadi bahasa kasir yang ramah
  static String formatErrorMessage(Object error) {
    var msg = error.toString();
    if (msg.startsWith('FormatException: ')) {
      msg = msg.substring('FormatException: '.length);
    } else if (msg.startsWith('Exception: ')) {
      msg = msg.substring('Exception: '.length);
    }
    return msg.trim();
  }

  /// Menampilkan Pop-Up Dialog Sukses Modern
  static Future<void> showSuccessDialog(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Selesai',
    Widget? customContent,
    VoidCallback? onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ModernFeedbackDialog(
        type: FeedbackType.success,
        title: title,
        message: message,
        confirmText: buttonText,
        customContent: customContent,
        onConfirm: () {
          Navigator.pop(ctx);
          onConfirm?.call();
        },
      ),
    );
  }

  /// Menampilkan Pop-Up Dialog Error / Gagal
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Tutup',
    VoidCallback? onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => _ModernFeedbackDialog(
        type: FeedbackType.error,
        title: title,
        message: message,
        confirmText: buttonText,
        onConfirm: () {
          Navigator.pop(ctx);
          onConfirm?.call();
        },
      ),
    );
  }

  /// Menampilkan Pop-Up Dialog Peringatan / Warning
  static Future<void> showWarningDialog(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Dimengerti',
    VoidCallback? onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => _ModernFeedbackDialog(
        type: FeedbackType.warning,
        title: title,
        message: message,
        confirmText: buttonText,
        onConfirm: () {
          Navigator.pop(ctx);
          onConfirm?.call();
        },
      ),
    );
  }

  /// Menampilkan Dialog Konfirmasi Aksi (Ya / Batal)
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Konfirmasi',
    String cancelText = 'Batal',
    bool isDestructive = false,
    Widget? customContent,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ModernFeedbackDialog(
        type: isDestructive ? FeedbackType.error : FeedbackType.warning,
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        customContent: customContent,
        onConfirm: () => Navigator.pop(ctx, true),
        onCancel: () => Navigator.pop(ctx, false),
      ),
    );
    return result ?? false;
  }

  /// Menampilkan Floating Toast / SnackBar Modern
  static void showToast(
    BuildContext context, {
    required String message,
    FeedbackType type = FeedbackType.success,
    Duration duration = const Duration(seconds: 2),
  }) {
    final scaffold = ScaffoldMessenger.maybeOf(context);
    if (scaffold == null) return;

    final Color bgColor;
    final Color textColor;
    final Color iconColor;
    final IconData icon;

    switch (type) {
      case FeedbackType.success:
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF065F46);
        iconColor = const Color(0xFF059669);
        icon = Iconsax.tick_circle;
        break;
      case FeedbackType.error:
        bgColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFF991B1B);
        iconColor = const Color(0xFFDC2626);
        icon = Iconsax.close_circle;
        break;
      case FeedbackType.warning:
        bgColor = const Color(0xFFFFFBEB);
        textColor = const Color(0xFF92400E);
        iconColor = const Color(0xFFD97706);
        icon = Iconsax.info_circle;
        break;
      case FeedbackType.info:
        bgColor = const Color(0xFFF0FDF4);
        textColor = AppTheme.ink;
        iconColor = AppTheme.primary;
        icon = Iconsax.lamp_on;
        break;
    }

    scaffold.hideCurrentSnackBar();
    scaffold.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        duration: duration,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: iconColor.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showSuccessToast(BuildContext context, String message) {
    showToast(context, message: message, type: FeedbackType.success);
  }

  static void showErrorToast(BuildContext context, String message) {
    showToast(context, message: message, type: FeedbackType.error);
  }

  static void showWarningToast(BuildContext context, String message) {
    showToast(context, message: message, type: FeedbackType.warning);
  }

  static void showInfoToast(BuildContext context, String message) {
    showToast(context, message: message, type: FeedbackType.info);
  }
}

class _ModernFeedbackDialog extends StatelessWidget {
  const _ModernFeedbackDialog({
    required this.type,
    required this.title,
    required this.message,
    required this.confirmText,
    this.cancelText,
    this.isDestructive = false,
    this.customContent,
    this.onConfirm,
    this.onCancel,
  });

  final FeedbackType type;
  final String title;
  final String message;
  final String confirmText;
  final String? cancelText;
  final bool isDestructive;
  final Widget? customContent;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final Color badgeBg;
    final Color badgeBorder;
    final Color iconColor;
    final IconData icon;

    switch (type) {
      case FeedbackType.success:
        badgeBg = const Color(0xFFECFDF5);
        badgeBorder = const Color(0xFFA7F3D0);
        iconColor = const Color(0xFF059669);
        icon = Iconsax.tick_circle;
        break;
      case FeedbackType.error:
        badgeBg = const Color(0xFFFEF2F2);
        badgeBorder = const Color(0xFFFECACA);
        iconColor = const Color(0xFFDC2626);
        icon = Iconsax.close_circle;
        break;
      case FeedbackType.warning:
        badgeBg = const Color(0xFFFFFBEB);
        badgeBorder = const Color(0xFFFDE68A);
        iconColor = const Color(0xFFD97706);
        icon = Iconsax.info_circle;
        break;
      case FeedbackType.info:
        badgeBg = AppTheme.primaryLight;
        badgeBorder = const Color(0xFFA7F3D0);
        iconColor = AppTheme.primary;
        icon = Iconsax.information;
        break;
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Circular Badge
            Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: badgeBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: badgeBorder, width: 2.5),
                ),
                child: Icon(icon, color: iconColor, size: 34),
              ),
            ),
            const SizedBox(height: 18),

            // Title
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.ink,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Message
            Center(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.muted,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),

            if (customContent != null) ...[
              const SizedBox(height: 18),
              customContent!,
            ],

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                if (cancelText != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        foregroundColor: AppTheme.ink,
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        cancelText!,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: onConfirm,
                    style: FilledButton.styleFrom(
                      backgroundColor: isDestructive
                          ? Colors.red.shade700
                          : AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
