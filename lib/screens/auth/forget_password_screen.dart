import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncio_capstone/services/otp_service.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/services/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  late TextEditingController urnCtrl = TextEditingController();
  late TextEditingController eCtrl = TextEditingController();

  bool isSendingEmail = false;

  @override
  void dispose() {
    urnCtrl.dispose();
    eCtrl.dispose();
    super.dispose();
  }

  Future<void> _onNextTap() async {
    if (isSendingEmail) {
      return;
    }

    if (urnCtrl.text.trim().isEmpty || eCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.verifyAccount),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ));
    }

    final String username = urnCtrl.text.trim();
    final String email = eCtrl.text.trim();
    setState(() {
      isSendingEmail = true;
    });
    final VerifyUsernameAndEmailRequest request =
        VerifyUsernameAndEmailRequest(username: username, email: email);
    try {
      final VerifyUsernameAndEmailResponse response =
          await UserService().verifyEmailAndUsername(request);
      if (!response.success!) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.sendEmailFailed),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ));
      } else {
        final SendOTPForgetPasswordMessageRequest sendEmailRequest =
            SendOTPForgetPasswordMessageRequest(
                accountID: response.userID, email: email);
        try {
          final SendOTPForgetPasswordMessageResponse sendEmailResponse =
              await OtpService().sendOTPForgetPassword(sendEmailRequest);
          if (!sendEmailResponse.success!) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(
                    AppLocalizations.of(context)!.incorrectEmailOrUsername),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ));
          } else {
            Navigator.of(context).pushNamed("forgetPasswordOTPInputScreen",
                arguments: {
                  "userID": response.userID.toString(),
                  "email": email
                });
          }
        } catch (e) {
          throw Exception(e);
        }
      }
    } catch (e) {
      throw Exception(e);
    } finally {
      setState(() {
        isSendingEmail = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: false,
        title: Text(AppLocalizations.of(context)!.forgetPassword),
        titleTextStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge!.color,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: "SFProDisplay",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 40),
        child: Column(
          children: [
            Text(AppLocalizations.of(context)!.verifyAccount),
            SizedBox(
              height: 15,
            ),
            TextField(
              controller: urnCtrl,
              decoration: InputDecoration(
                labelText: toBeginningOfSentenceCase(
                    AppLocalizations.of(context)!.username),
                labelStyle: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.color
                        ?.withOpacity(0.5)),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            TextField(
              controller: eCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText:
                    toBeginningOfSentenceCase(AppLocalizations.of(context)!.em),
                labelStyle: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.color
                        ?.withOpacity(0.5)),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            SizedBox(
              width: 200,
              height: 70,
              child: ElevatedButton(
                  onPressed: _onNextTap,
                  style: ElevatedButton.styleFrom(),
                  child: isSendingEmail
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(AppLocalizations.of(context)!.nxt)),
            ),
          ],
        ),
      ),
    );
  }
}
