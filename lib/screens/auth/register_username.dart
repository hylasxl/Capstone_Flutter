import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/services/user_service.dart';
import 'package:syncio_capstone/widgets/register_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';


class RegisterUsername extends StatefulWidget {
  const RegisterUsername({super.key});

  @override
  State<RegisterUsername> createState() => RegisterUsernameState();
}

class RegisterUsernameState extends State<RegisterUsername> {
  final TextEditingController usnctrl = TextEditingController();
  bool _showSnackBar = false;
  String? _snackBarText;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleNext(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (usnctrl.text.isEmpty) {
      if (!context.mounted) return;
      _showFloatingSnackBar(AppLocalizations.of(context)!.peusn);
      return;
    }

    Future<bool> checkUsnIsNotInUsed(String e) async {
      final CheckDuplicateRequest request = CheckDuplicateRequest(
        data:e ,
        dataType: "username");
      try {
        final response = await UserService().checkDuplicateCredentials(request);
        return response.isDuplicate;
      } catch (e) {
        return true;
      }
    }

    bool usnIsInUsed = await checkUsnIsNotInUsed(usnctrl.text);
    if (usnIsInUsed) {
      if (!context.mounted) return;
      _showFloatingSnackBar(AppLocalizations.of(context)!.usnaiu);
      return;
    }

    await prefs.setString('username', usnctrl.text);
    if (!context.mounted) return;
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 500));
    if (!context.mounted) return;
    Navigator.of(context).pushNamed('registerName');
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
                  title: toBeginningOfSentenceCase(
                      AppLocalizations.of(context)!.username),
                  desc: AppLocalizations.of(context)!.urnd,
                  inputFields: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: usnctrl,
                          decoration: InputDecoration(
                            labelText: toBeginningOfSentenceCase(
                                AppLocalizations.of(context)!.username),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  onNextPress: () => _handleNext(context)),
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
        ));
  }
}
