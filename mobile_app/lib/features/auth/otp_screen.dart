import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';
import 'widgets/auth_scaffold.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (_otpCtrl.text.length < 6) return;
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.verifyOtp(widget.phone, _otpCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok && auth.authError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.authError!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AuthScaffold(
      title: 'Verify OTP',
      subtitle: 'Enter the 6-digit code sent to ${widget.phone}',
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back_rounded),
        style: IconButton.styleFrom(
          backgroundColor: colors.card,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PinCodeTextField(
            appContext: context,
            length: 6,
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
            animationType: AnimationType.scale,
            textStyle: TextStyle(color: colors.textPrimary),
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(14),
              fieldHeight: 48,
              fieldWidth: 48,
              activeColor: AppColors.primary,
              selectedColor: AppColors.primary,
              inactiveColor: colors.border,
              activeFillColor: colors.card,
              selectedFillColor: colors.card,
              inactiveFillColor: colors.card,
            ),
            enableActiveFill: true,
            onChanged: (_) {},
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Verify & Continue',
            loading: _loading,
            onPressed: _submit,
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text("Didn't receive code? Resend"),
            ),
          ),
        ],
      ),
    );
  }
}
