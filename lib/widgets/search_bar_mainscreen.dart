import 'package:flutter/material.dart';
import 'package:syncio_capstone/constants/constants.dart';
import 'package:syncio_capstone/providers/theme_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:provider/provider.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/services/user_service.dart';
import 'package:syncio_capstone/utils/helpers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchBarMainscreen extends StatefulWidget {
  final VoidCallback onPostPress;
  const SearchBarMainscreen({super.key, required this.onPostPress});

  @override
  State<SearchBarMainscreen> createState() => _SearchBarMainscreenState();
}

class _SearchBarMainscreenState extends State<SearchBarMainscreen> {
  String? avatarUrl;
  bool isAvatarLoaded = false;
  String? userID;

  @override
  void initState() {
    super.initState();
    avatarUrl = null;
    fetchAvatarURL();
  }

  Future<void> fetchAvatarURL() async {
    LoginResponse? userData = await Helpers().getUserData();
    String avatarURL = Constants.defaultAvatarURL;
    if (userData != null) {
      int userID = int.parse(userData.userID);
      final GetAccountInfoRequest request =
          GetAccountInfoRequest(accountId: userID);
      try {
        final GetAccountInfoResponse response =
            await UserService().getAccountInfo(request);
        avatarURL = response.accountAvatar.avatarUrl;
      } catch (e) {
        debugPrint("Error fetching avatar: $e");
      }
    }
    setState(() {
      avatarUrl = avatarURL;
      userID = userData!.userID;
    });
  }

  void _onAvatarTap() {
    Navigator.of(context).pushNamed("profileScreen", arguments: {
      "userID": userID,
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Skeletonizer(
              enabled: !isAvatarLoaded,
              child: GestureDetector(
                onTap: _onAvatarTap,
                child: ClipOval(
                  child: avatarUrl != null
                      ? Image.network(
                          avatarUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setState(() {
                                  isAvatarLoaded = true;
                                });
                              });
                              return child;
                            }
                            return Container(
                              width: 40,
                              height: 40,
                              color: Colors.grey[300],
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 40,
                            height: 40,
                            color: Colors.grey[300],
                            child: Icon(Icons.error, color: Colors.red),
                          ),
                        )
                      : Container(
                          width: 40,
                          height: 40,
                          color: Colors.grey[300],
                        ),
                ),
              ),
            ),
            SizedBox(
              width: 25,
            ),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.currentTheme == ThemeMode.dark
                      ? Color(0xFF121212)
                      : Colors.white,
                  side: BorderSide(
                    color: themeProvider.currentTheme == ThemeMode.light
                        ? Color(0xFF121212).withOpacity(0.5)
                        : Colors.white,
                  ),
                ),
                onPressed: widget.onPostPress,
                child: Text(
                  AppLocalizations.of(context)!.snt,
                  style: TextStyle(
                    color: themeProvider.currentTheme == ThemeMode.light
                        ? Color(0xFF121212).withOpacity(0.5)
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
