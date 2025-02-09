import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncio_capstone/services/otp_service.dart';
import 'package:syncio_capstone/services/types.dart';

class ForgetPasswordOtpInputScreen extends StatefulWidget {
  final int userID;
  final String email;
  const ForgetPasswordOtpInputScreen(
      {super.key, required this.userID, required this.email});

  @override
  State<ForgetPasswordOtpInputScreen> createState() =>
      _ForgetPasswordOtpInputScreenState();
}

class _ForgetPasswordOtpInputScreenState
    extends State<ForgetPasswordOtpInputScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  bool isCheckingOTP = false;
  bool isResendOTP = false;
  int _timeLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    for (TextEditingController controller in _controllers) {
      controller.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  Future<void> onResendOTPTap() async {
    if (_timeLeft > 0 || isCheckingOTP) return;
    final SendOTPForgetPasswordMessageRequest request =
        SendOTPForgetPasswordMessageRequest(
            accountID: widget.userID, email: widget.email);
    setState(() {
      isResendOTP = true;
    });
    try {
      final SendOTPForgetPasswordMessageResponse response =
          await OtpService().sendOTPForgetPassword(request);
      if (!response.success!) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.sendEmailFailed),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ));
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.sendEmailSuccessfully),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ));
        setState(() {
          _timeLeft = 60;
          startTimer();
        });
      }
    } catch (e) {
      throw Exception(e);
    } finally {
      setState(() {
        isResendOTP = false;
      });
    }
  }

  Future<void> _submitOtp() async {
    if (isCheckingOTP || isResendOTP) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (_controllers.any((controller) => controller.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all the fields before submitting'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    int otp = int.parse(_controllers.map((c) => c.text).join());

    final CheckValidOTPRequest request =
        CheckValidOTPRequest(accountID: widget.userID, otp: otp);
    setState(() {
      isCheckingOTP = true;
    });

    try {
      final CheckValidOTPResponse response =
          await OtpService().checkValidOTP(request);
      if (!response.success!) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.otpAttempts(
                response.attempts ?? 0,
                5 - response.attempts!,
                5 - response.attempts!)),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        Navigator.of(context).pushNamed("resettingPasswordScreen",
            arguments: {"userID": widget.userID.toString()});
      }
    } catch (e) {
      throw Exception(e);
    } finally {
      setState(() {
        isCheckingOTP = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: false,
        title: Text(
            AppLocalizations.of(context)?.forgetPassword ?? 'Forgot Password'),
        titleTextStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: "SFProDisplay",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)?.otpSent ??
                'OTP has been sent to your registered number.'),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(6, (index) {
                return SizedBox(
                  height: 50,
                  width: 50,
                  child: TextFormField(
                    autofocus: index == 0,
                    controller: _controllers[index],
                    onChanged: (value) {
                      if (value.length == 1) {
                        if (index < 5) {
                          FocusScope.of(context).nextFocus();
                        } else {
                          FocusScope.of(context).unfocus();
                        }
                      } else if (value.isEmpty && index > 0) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: const InputDecoration(counterText: ""),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            SizedBox(
              child: GestureDetector(
                onTap: onResendOTPTap,
                child: isResendOTP
                    ? SizedBox(
                        height: 40,
                        width: 40,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : Text(
                        "${AppLocalizations.of(context)!.resendOtp} ${_timeLeft > 0 ? "(${_timeLeft.toString()})" : ""}",
                        style: TextStyle(
                            color: _timeLeft > 0
                                ? Colors.grey[300]
                                : Theme.of(context).primaryColor),
                      ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: 200,
              height: 70,
              child: ElevatedButton(
                onPressed: _submitOtp,
                child: isCheckingOTP
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(AppLocalizations.of(context)?.nxt ?? 'Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
