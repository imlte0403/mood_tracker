import 'package:flutter/material.dart';
import 'package:mood_tracker/constants/sizes.dart';

typedef AuthFieldValidator = String? Function(String? value);

//인증 텍스트 필드 위젯
class AuthTextField extends StatefulWidget {
  const AuthTextField._({
    required this.controller,
    required this.label,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.autofillHints,
    this.enableObscureToggle = false,
    this.initialObscureText = false,
  });

//이름 입력 필드
  factory AuthTextField.name({
    required TextEditingController controller,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    AuthFieldValidator? validator,
  }) {
    return AuthTextField._(
      controller: controller,
      label: 'Name',
      focusNode: focusNode,
      keyboardType: TextInputType.name,
      textInputAction: textInputAction ?? TextInputAction.next,
      onSubmitted: onSubmitted,
      autovalidateMode: autovalidateMode,
      validator: validator ?? _defaultNameValidator,
      autofillHints: const [AutofillHints.name],
    );
  }

//이메일 입력 필드
  factory AuthTextField.email({
    required TextEditingController controller,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    AuthFieldValidator? validator,
  }) {
    return AuthTextField._(
      controller: controller,
      label: 'Email',
      focusNode: focusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction ?? TextInputAction.next,
      onSubmitted: onSubmitted,
      autovalidateMode: autovalidateMode,
      validator: validator ?? _defaultEmailValidator,
      autofillHints: const [AutofillHints.email],
    );
  }

//비밀번호 입력 필드
  factory AuthTextField.password({
    required TextEditingController controller,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    AuthFieldValidator? validator,
    bool enableVisibilityToggle = true,
  }) {
    return AuthTextField._(
      controller: controller,
      label: 'Password',
      focusNode: focusNode,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: textInputAction ?? TextInputAction.done,
      onSubmitted: onSubmitted,
      autovalidateMode: autovalidateMode,
      validator: validator ?? _defaultPasswordValidator,
      autofillHints: const [AutofillHints.password],
      enableObscureToggle: enableVisibilityToggle,
      initialObscureText: true,
    );
  }

//멤버 변수
  final TextEditingController controller;
  final String label;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final AutovalidateMode autovalidateMode;
  final AuthFieldValidator? validator;
  final Iterable<String>? autofillHints;
  final bool enableObscureToggle;
  final bool initialObscureText;


// 검증 로직
  static String? _defaultNameValidator(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) {
      return '이름을 입력해주세요.';
    }
    return null;
  }

  static String? _defaultEmailValidator(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return '이메일을 입력해주세요.';
    }
    final emailRegex =
        RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$', caseSensitive: false);
    if (!emailRegex.hasMatch(email)) {
      return '올바른 이메일 주소를 입력해주세요.';
    }
    return null;
  }

  static String? _defaultPasswordValidator(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }
    if (password.length < 6) {
      return '비밀번호는 6자 이상이어야 합니다.';
    }
    return null;
  }

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.initialObscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.enableObscureToggle ? _obscureText : widget.initialObscureText,
      autovalidateMode: widget.autovalidateMode,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      autofillHints: widget.autofillHints,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: widget.enableObscureToggle
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sizes.size8),
        ),
      ),
    );
  }
}
