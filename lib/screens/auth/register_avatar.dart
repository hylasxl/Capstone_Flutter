import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/services/user_service.dart';
import 'package:syncio_capstone/widgets/register_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterAvatar extends StatefulWidget {
  const RegisterAvatar({super.key});

  @override
  State<RegisterAvatar> createState() => RegisterAvatarState();
}

class RegisterAvatarState extends State<RegisterAvatar> {
  bool _showSnackBar = false;
  String? _snackBarText;
  XFile? _avatarImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _avatarImage = pickedFile;
      });
    } else {
      if (!mounted) return;
      _showFloatingSnackBar(AppLocalizations.of(context)!.nimgs);
      _avatarImage = null;
    }
  }

  Future<void> _handleNext(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? firstName = prefs.getString('firstName');
    String? lastName = prefs.getString('lastName');
    String? birthdayTimestamp = prefs.getString('selectedBirthday');
    String? email = prefs.getString('email');
    String? gender = prefs.getString('gender');
    String? password = prefs.getString('password');
    String? username = prefs.getString('username');

    String? avatarBase64 = await _getAvatarBase64();

    try {
      final SignUpRequest request = SignUpRequest(
          username: username!,
          password: password!,
          firstName: firstName!,
          lastName: lastName!,
          birthDate: birthdayTimestamp!,
          gender: gender!,
          email: email!,
          image: avatarBase64!,
          phone: "");

      final SignUpResponse response = await UserService().register(request);
      if (!response.success) {
        String messageError = AppLocalizations.of(context)!.re;
        _showFloatingSnackBar(toBeginningOfSentenceCase(messageError));
        return;
      } else {
        if (!context.mounted) return;
        _showFloatingSnackBar(AppLocalizations.of(context)!.rs);
        await Future.delayed(Duration(seconds: 2));
        if (!context.mounted) return;
        Navigator.of(context).popUntil((page) => page.isFirst);
      }
    } catch (e) {
      if (!context.mounted) return;
      _showFloatingSnackBar(
          toBeginningOfSentenceCase(AppLocalizations.of(context)!.re));
      debugPrint("Error: $e");
      return;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> _getAvatarBase64() async {
    if (_avatarImage != null) {
      File imageFile = File(_avatarImage!.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      return base64Encode(imageBytes);
    }
    return null;
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
              isLoading: _isLoading,
              title: AppLocalizations.of(context)!.avt,
              desc: AppLocalizations.of(context)!.avtd,
              inputFields: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: ElevatedButton(
                      onPressed: _pickImage,
                      child: Text(AppLocalizations.of(context)!.simg),
                    ),
                  ),
                  SizedBox(height: 20),
                  _avatarImage != null
                      ? ClipOval(
                          key: ValueKey<int>(1),
                          child: Image.file(
                            File(_avatarImage!.path),
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        )
                      : SizedBox.shrink(),
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
