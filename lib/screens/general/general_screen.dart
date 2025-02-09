import 'package:flutter/material.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/utils/helpers.dart';
import 'package:syncio_capstone/services/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncio_capstone/providers/theme_provider.dart';
import 'package:syncio_capstone/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralScreen extends StatefulWidget {
  const GeneralScreen({super.key});

  @override
  State<GeneralScreen> createState() => _GeneralScreenState();
}

class _GeneralScreenState extends State<GeneralScreen> {
  String? userID;
  GetAccountInfoResponse? userData;

  @override
  void initState() {
    _initUserID();
    super.initState();
  }

  Future<void> _initUserID() async {
    final LoginResponse? data = await Helpers().getUserData();
    if (data != null) {
      setState(() {
        userID = data.userID;
      });
      _initUserData();
    } else {
      return;
    }
  }

  Future<void> _initUserData() async {
    final GetAccountInfoRequest request =
        GetAccountInfoRequest(accountId: int.parse(userID!));
    try {
      final GetAccountInfoResponse response =
          await UserService().getAccountInfo(request);
      setState(() {
        userData = response;
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  void _handleSignOut(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("userData");
    await prefs.remove("access_token");
    await prefs.remove("refresh_token");
    await authProvider.signOut();
    Navigator.pushReplacementNamed(context, "loginScreen");
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.currentTheme == ThemeMode.dark
          ? Colors.black
          : Colors.grey[200],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 150,
            child: Padding(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("profileScreen", arguments: {
                    "userID": userID,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: userData != null
                          ? Image.network(
                              userData!.accountAvatar.avatarUrl,
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                    ),
                                  );
                                }
                              },
                            )
                          : const SizedBox(
                              height: 60,
                              width: 60,
                              child: CircularProgressIndicator(),
                            ),
                    ),
                    const SizedBox(width: 12),
                    userData != null
                        ? Text(
                            userData!.accountInfo.nameDisplayType ==
                                    "first_name_first"
                                ? "${userData!.accountInfo.firstName} ${userData!.accountInfo.lastName}"
                                : "${userData!.accountInfo.lastName} ${userData!.accountInfo.firstName}",
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: Text(AppLocalizations.of(context)!.theme),
                    onTap: () {
                      Navigator.of(context).pushNamed("themeScreen");
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(AppLocalizations.of(context)!.language),
                    onTap: () {
                      Navigator.pushNamed(context, "languageScreen");
                    },
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _handleSignOut(context);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.signOut,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge!.color),
                    ))),
          )
        ],
      ),
    );
  }
}
