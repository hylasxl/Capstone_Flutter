import 'package:flutter/material.dart';
import 'package:syncio_capstone/widgets/register_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterGender extends StatefulWidget {
  const RegisterGender({super.key});

  @override
  RegisterGenderState createState() => RegisterGenderState();
}

class RegisterGenderState extends State<RegisterGender> {
  String? _selectedGender;
  bool _showSnackBar = false;
  String? _snackBarText;

  Future<void> _handleNext(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    if (!context.mounted) return;
    if (_selectedGender == null) {
      _showFloatingSnackBar(AppLocalizations.of(context)!.pcgd);
      return;
    }
    
    await prefs.setString('gender', _selectedGender!);

    if (!context.mounted) return;
    Navigator.of(context).pushNamed('registerEmail');
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
              title: AppLocalizations.of(context)!.gd,
              desc: AppLocalizations.of(context)!.gdd,
              inputFields: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Male',
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                      ),
                      Text(AppLocalizations.of(context)!.male),
                      Radio<String>(
                        value: 'Female',
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                      ),
                      Text(AppLocalizations.of(context)!.female),
                      Radio<String>(
                        value: 'Other',
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                      ),
                      Text(AppLocalizations.of(context)!.other),
                    ],
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
