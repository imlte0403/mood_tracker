import 'package:flutter/material.dart';
import 'package:mood_tracker/constants/sizes.dart';

class AuthBtn extends StatelessWidget {
  const AuthBtn({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: Sizes.size20,
            width: Sizes.size20,
            child: CircularProgressIndicator(strokeWidth: Sizes.size2),
          )
        : Text(label);

    final button = leading != null && !isLoading
        ? ElevatedButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: leading!,
            label: Text(label),
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          );

    return SizedBox(
      height: Sizes.size48,
      child: Theme(
        data: Theme.of(context).copyWith(
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Sizes.size8),
              ),
            ),
          ),
        ),
        child: button,
      ),
    );
  }
}
