import 'package:flutter/cupertino.dart';
import 'package:syncio_capstone/screens/auth/forget_password_screen.dart';
import 'package:syncio_capstone/screens/auth/register_avatar.dart';
import 'package:syncio_capstone/screens/auth/login_screen.dart';
import 'package:syncio_capstone/screens/auth/register_name_screen.dart';
import 'package:syncio_capstone/screens/auth/register_birthday.dart';
import 'package:syncio_capstone/screens/auth/register_gender.dart';
import 'package:syncio_capstone/screens/auth/register_email.dart';
import 'package:syncio_capstone/screens/auth/register_password.dart';
import 'package:syncio_capstone/screens/auth/register_username.dart';
import 'package:syncio_capstone/screens/auth/resetting_password_screen.dart';
import 'package:syncio_capstone/screens/friends/friend_list.dart';
import 'package:syncio_capstone/screens/friends/friend_request.dart';
import 'package:syncio_capstone/screens/general/language_screen.dart';
import 'package:syncio_capstone/screens/general/theme_screen.dart';
import 'package:syncio_capstone/screens/home/tab.dart';
import 'package:syncio_capstone/screens/message/message_detail_screen.dart';
import 'package:syncio_capstone/screens/otp/forgot_password_otp_input_screen.dart';
import 'package:syncio_capstone/screens/profile/edit_data_screen.dart';
import 'package:syncio_capstone/screens/profile/edit_detail_screen.dart';
import 'package:syncio_capstone/screens/profile/profile_screen.dart';

class AppRoute {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case 'login':
        return CupertinoPageRoute(builder: (context) => LoginScreen());
      case 'registerUsername':
        return CupertinoPageRoute(builder: (context) => RegisterUsername());
      case 'registerName':
        return CupertinoPageRoute(builder: (context) => RegisterNameScreen());
      case 'registerBirthday':
        return CupertinoPageRoute(builder: (context) => RegisterBirthday());
      case 'registerGender':
        return CupertinoPageRoute(builder: (context) => RegisterGender());
      case 'registerEmail':
        return CupertinoPageRoute(builder: (context) => RegisterEmail());
      case 'registerPassword':
        return CupertinoPageRoute(builder: (context) => RegisterPassword());
      case 'homeScreen':
        return CupertinoPageRoute(builder: (context) => HomeScreen());
      case 'registerAvatar':
        return CupertinoPageRoute(builder: (context) => RegisterAvatar());
      case 'languageScreen':
        return CupertinoPageRoute(builder: (context) => LanguageScreen());
      case 'themeScreen':
        return CupertinoPageRoute(builder: (context) => ThemeScreen());
      case 'profileScreen':
        final args = settings.arguments as Map<String, dynamic>;
        return CupertinoPageRoute(
          builder: (context) => ProfileScreen(
            userID: int.parse(args['userID']),
            isSelf: args['isSelf'] ?? true,
          ),
        );
      case 'friendListScreen':
        final args = settings.arguments as Map<String, dynamic>;
        return CupertinoPageRoute(
          builder: (context) => FriendListScreen(
            userID: int.parse(args['userID']),
          ),
        );
      case 'friendRequestScreen':
        final args = settings.arguments as Map<String, dynamic>;
        return CupertinoPageRoute(
          builder: (context) => FriendRequestScreen(
            userID: int.parse(args['userID']),
          ),
        );
      case 'editDataScreen':
        final args = settings.arguments as Map<String, dynamic>;
        return CupertinoPageRoute(
          builder: (context) => EditDataScreen(
            dislayName: args['dislayName'],
            accountInfo: args['accountInfo'],
            accountAvatar: args['accountAvatar'],
            privacy: args['privacy'],
          ),
        );
      case 'editDetailScreen':
        final args = settings.arguments as Map<String, dynamic>;
        return CupertinoPageRoute(
          builder: (context) => EditDetailScreen(
            screenName: args['screenName'],
            dataType: args['dataType'],
            initialValue: args['initialValue'] ?? "",
            privacyStatus: args['privacyStatus'] ?? "public",
          ),
        );
      case "forgetPasswordScreen":
        return CupertinoPageRoute(builder: (context) => ForgetPasswordScreen());
      case "forgetPasswordOTPInputScreen":
        final args = settings.arguments as Map<String, dynamic>;
        return CupertinoPageRoute(
            builder: (context) => ForgetPasswordOtpInputScreen(
                  userID: int.parse(args['userID']),
                  email: args['email'],
                ));
      case "resettingPasswordScreen":
        final args = settings.arguments as Map<String, dynamic>;
        return CupertinoPageRoute(
            builder: (context) =>
                ResettingPasswordScreen(userID: int.parse(args['userID'])));
      case "messageDetailScreen":
        final args = settings.arguments as Map<String, dynamic>;
        return CupertinoPageRoute(
            builder: (context) => MessageDetailScreen(
                  chatId: args['chatId'],
                  partnerId: args['partnerId'],
                ));
      default:
        return CupertinoPageRoute(builder: (context) => LoginScreen());
    }
  }
}
