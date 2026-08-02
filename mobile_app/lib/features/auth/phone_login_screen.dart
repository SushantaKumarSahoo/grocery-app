import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';
import 'widgets/auth_scaffold.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (_phoneCtrl.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit phone number')),
      );
      return;
    }
    setState(() => _loading = true);
    final phone = '+91${_phoneCtrl.text.trim()}';
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginWithPhone(phone);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      context.push('/otp', extra: phone);
    } else if (auth.authError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.authError!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AuthScaffold(
      title: 'Login with Phone',
      subtitle: "We'll send you a One-Time Password (OTP)",
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
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            style: TextStyle(color: colors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Mobile number',
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Text('+91',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary)),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              counterText: '',
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Send OTP',
            loading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
