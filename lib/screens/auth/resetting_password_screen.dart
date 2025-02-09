import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/services/user_service.dart';

class ResettingPasswordScreen extends StatefulWidget {
  final int userID;
  const ResettingPasswordScreen({super.key, required this.userID});

  @override
  State<ResettingPasswordScreen> createState() =>
      _ResettingPasswordScreenState();
}

class _ResettingPasswordScreenState extends State<ResettingPasswordScreen> {
  late TextEditingController newPCtrl = TextEditingController();
  late TextEditingController confirmPCtrl = TextEditingController();

  bool isPObscure = true;
  bool isConfirmPObscure = true;

  @override
  void dispose() {
    newPCtrl.dispose();
    confirmPCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSaveTap() async {
    if (newPCtrl.text.trim().isEmpty || confirmPCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.pepw),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ));
    }

    final passwordRegex =
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

    if (!passwordRegex.hasMatch(newPCtrl.text.trim())) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.pwnv),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ));
      return;
    }

    if (newPCtrl.text.trim() != confirmPCtrl.text.trim()) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.pwnv),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ));
      return;
    }

    final ChangePasswordRequest request = ChangePasswordRequest(
        accountID: widget.userID, newPassword: newPCtrl.text.trim());
    try {
      final ChangePasswordResponse response =
          await UserService().changePassword(request);
      if (!response.success!) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.pwnv),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ));
        return;
      } else {
        Navigator.of(context).popUntil((page) => page.isFirst);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: false,
        title: Text(AppLocalizations.of(context)!.resetPassword),
        titleTextStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge!.color,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: "SFProDisplay",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(AppLocalizations.of(context)!.pwd),
            const SizedBox(
              height: 20,
            ),
            TextField(
              obscureText: isPObscure,
              controller: newPCtrl,
              decoration: InputDecoration(
                  labelText: toBeginningOfSentenceCase(
                      AppLocalizations.of(context)!.newPassword),
                  labelStyle: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.color
                          ?.withOpacity(0.5)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isPObscure = !isPObscure;
                        });
                      },
                      icon: Icon(isPObscure
                          ? Icons.visibility
                          : Icons.visibility_off))),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              obscureText: isConfirmPObscure,
              controller: confirmPCtrl,
              decoration: InputDecoration(
                  labelText: toBeginningOfSentenceCase(
                      AppLocalizations.of(context)!.confirmPassword),
                  labelStyle: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.color
                          ?.withOpacity(0.5)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isConfirmPObscure = !isConfirmPObscure;
                        });
                      },
                      icon: Icon(isConfirmPObscure
                          ? Icons.visibility
                          : Icons.visibility_off))),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                  onPressed: _onSaveTap,
                  child: Text(AppLocalizations.of(context)!.save)),
            )
          ],
        ),
      ),
    );
  }
}
