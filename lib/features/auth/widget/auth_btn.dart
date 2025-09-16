import 'package:flutter/material.dart';
import 'package:mood_tracker/constants/sizes.dart';

enum _AuthBtnVariant { primary, social }

//인증 버튼 위젯
class AuthBtn extends StatelessWidget {
  const AuthBtn._({
    required this.label,
    required this.onPressed,
    required _AuthBtnVariant variant,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  })  : _variant = variant,
        assert(variant != _AuthBtnVariant.social || icon != null);

  //기본 로그인 버튼
  factory AuthBtn.primary({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return AuthBtn._(
      label: label,
      onPressed: onPressed,
      variant: _AuthBtnVariant.primary,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }

  //소셜 로그인 버튼
  factory AuthBtn.social({
    required String label,
    required Widget icon,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return AuthBtn._(
      label: label,
      onPressed: onPressed,
      variant: _AuthBtnVariant.social,
      icon: icon,
      isLoading: isLoading,
    );
  }

  //멤버 변수
  final String label;
  final VoidCallback? onPressed;
  final _AuthBtnVariant _variant;
  final bool isLoading;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final style = ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(Sizes.size48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.size8),
      ),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );

    return SizedBox(
      height: Sizes.size48,
      child: _buildButton(style, effectiveOnPressed),
    );
  }

  Widget _buildButton(ButtonStyle style, VoidCallback? onPressed) {
    if (_variant == _AuthBtnVariant.social && !isLoading) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        style: style,
        icon: icon!,
        label: Text(label),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: isLoading ? _buildLoader() : Text(label),
    );
  }

  Widget _buildLoader() {
    return const SizedBox(
      height: Sizes.size20,
      width: Sizes.size20,
      child: CircularProgressIndicator(strokeWidth: Sizes.size2),
    );
  }
}
