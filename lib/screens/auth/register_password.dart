import 'package:flutter/material.dart';
import 'package:syncio_capstone/widgets/register_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPassword extends StatefulWidget {
  const RegisterPassword({super.key});

  @override
  State<RegisterPassword> createState() => _RegisterPasswordState();
}

class _RegisterPasswordState extends State<RegisterPassword> {
  final TextEditingController _pctrl = TextEditingController();
  bool _showSnackBar = false;
  String? _snackBarText;

  void _handleNext(BuildContext context) async {
    String pw = _pctrl.text;
    final prefs = await SharedPreferences.getInstance();
    final passwordRegex =
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

    if (!context.mounted) return;
    if (pw.isEmpty) {
      _showFloatingSnackBar(AppLocalizations.of(context)!.pepw);
      return;
    } else {
      prefs.setString('password', pw);
    }

    if (!passwordRegex.hasMatch(pw)) {
      _showFloatingSnackBar(AppLocalizations.of(context)!.pwnv);
      return;
    }

    
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 500));
    if (!context.mounted) return;
    Navigator.of(context).pushNamed('registerAvatar');
  }

  void _showFloatingSnackBar(String message) {
    setState(() {
      _showSnackBar = true;
      _snackBarText = message;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSnackBar = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.1,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: RegisterForm(
              title: AppLocalizations.of(context)!.pw,
              desc: AppLocalizations.of(context)!.pwd,
              inputFields: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _pctrl,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.pw,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pw;
                      }
                      return null;
                    },
                  ),
                ],
              ),
              onNextPress: () => _handleNext(context),
            ),
          ),
          if (_showSnackBar)
            Positioned(
              bottom: MediaQuery.of(context).viewInsets.bottom + 10,
              left: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _snackBarText ?? '',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
