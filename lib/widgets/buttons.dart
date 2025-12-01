import 'package:flutter/material.dart';
import 'package:life_stream/constants/index.dart';

// Primary Button
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;

  const PrimaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 56,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    isDark ? Colors.white : Colors.white,
                  ),
                ),
              )
            : (icon != null ? Icon(icon) : const SizedBox.shrink()),
        label: Text(
          label,
          style: AppTextStyles.titleLarge.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// Secondary Button
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isFullWidth;
  final IconData? icon;

  const SecondaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isFullWidth = true,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(
          label,
          style: AppTextStyles.titleLarge,
        ),
      ),
    );
  }
}

// Text Button
class CustomTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? textColor;

  const CustomTextButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: AppTextStyles.titleMedium.copyWith(
          color: textColor ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
