import 'package:flutter/material.dart';
import 'package:syncio_capstone/widgets/register_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterNameScreen extends StatefulWidget {
  const RegisterNameScreen({super.key});

  @override
  RegisterNameScreenState createState() => RegisterNameScreenState();
}

class RegisterNameScreenState extends State<RegisterNameScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  bool _showSnackBar = false;
  String? _snackBarText;

  Future<void> _handleNext() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    if (firstNameController.text.isEmpty) {
      _showSnackBarWithMessage(AppLocalizations.of(context)!.pefn);
      return;
    }
    if (lastNameController.text.isEmpty) {
      _showSnackBarWithMessage(AppLocalizations.of(context)!.peln);
      return;
    }
    await prefs.setString('firstName', firstNameController.text);
    await prefs.setString('lastName', lastNameController.text);
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    Navigator.of(context).pushNamed('registerBirthday');
  }

  void _showSnackBarWithMessage(String message) {
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
    firstNameController.dispose();
    lastNameController.dispose();
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
              title: AppLocalizations.of(context)!.wyn,
              desc: AppLocalizations.of(context)!.wynd,
              inputFields: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: firstNameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.fn,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: lastNameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.ln,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              onNextPress: _handleNext,
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
