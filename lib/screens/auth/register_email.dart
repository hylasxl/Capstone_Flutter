import 'package:flutter/material.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/services/user_service.dart';
import 'package:syncio_capstone/widgets/register_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterEmail extends StatefulWidget {
  const RegisterEmail({super.key});

  @override
  RegisterEmailState createState() => RegisterEmailState();
}

class RegisterEmailState extends State<RegisterEmail> {
  final TextEditingController _emailController = TextEditingController();
  bool _showSnackBar = false;
  String? _snackBarText;
  
  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleNext(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String email = _emailController.text;

    final RegExp emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!context.mounted) return;

    if (email.isEmpty) {
      _showFloatingSnackBar(AppLocalizations.of(context)!.pee);
      return;
    } else if (!emailRegex.hasMatch(email)) {
      _showFloatingSnackBar(AppLocalizations.of(context)!.eicf);
      return;
    }

    Future<bool> checkEmailIsNotInUsed(String e) async {
      final CheckDuplicateRequest request = CheckDuplicateRequest(data: e, dataType: "email");
      try {
        final response = await UserService().checkDuplicateCredentials(request);
        return response.isDuplicate;
      } catch (e) {
        return true;
      }
    }

    bool emailIsInUsed = await checkEmailIsNotInUsed(email);
    if (emailIsInUsed) {
      if(!context.mounted) return;
      _showFloatingSnackBar(AppLocalizations.of(context)!.eaiu);
      return;
    }

    await prefs.setString('email', email);

    if (!context.mounted) return;
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 500));

    if (!context.mounted) return;
    Navigator.of(context).pushNamed('registerPassword');
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
              title: AppLocalizations.of(context)!.em,
              desc: AppLocalizations.of(context)!.emd,
              inputFields: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.em,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pee;
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
