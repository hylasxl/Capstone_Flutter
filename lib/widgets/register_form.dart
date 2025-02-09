import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterForm extends StatelessWidget {
  final String title;
  final String desc;
  final Widget inputFields;
  final VoidCallback onNextPress;
  final bool isLoading;

  const RegisterForm({
    super.key,
    required this.title,
    required this.desc,
    required this.inputFields,
    required this.onNextPress,
    this.isLoading = false
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MediaQuery.removeViewInsets(
          context: context,
          removeBottom: true,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 100,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(desc),
                          const SizedBox(height: 24),
                          inputFields,
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: onNextPress,
                              child: isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              (
                                  AppLocalizations.of(context)!.nxt),
                            ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('firstName');
                    await prefs.remove('lastName');
                    await prefs.remove('selectedBirthday');
                    await prefs.remove('email');
                    await prefs.remove('gender');
                    await prefs.remove('password');
                    await prefs.remove('username');
                    if (!context.mounted) return;
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.iaha,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
