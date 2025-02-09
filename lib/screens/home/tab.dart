import 'package:flutter/material.dart';
import 'package:syncio_capstone/screens/friends/friend_screen.dart';
import 'package:syncio_capstone/screens/message/message_screen.dart';
import 'package:syncio_capstone/screens/newfeed/newsfeed_screen.dart';
import 'package:syncio_capstone/screens/notification/notification_screen.dart';
import 'package:syncio_capstone/screens/general/general_screen.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currenIndex = 0;
  final List<Widget?> _screens = List.filled(5, null);
  final ScrollController _scrollController = ScrollController();
  bool _isBottomNavBarVisible = true;
  late int userID;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      setState(() {
        _isBottomNavBarVisible = false;
      });
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      setState(() {
        _isBottomNavBarVisible = true;
      });
    }
  }

  Widget _getScreen(int index) {
    if (_screens[index] == null) {
      switch (index) {
        case 0:
          _screens[index] = NewsFeedScreen(
            scrollController: _scrollController,
            key: UniqueKey(),
          );
          break;
        case 1:
          _screens[index] = FriendScreen(
            scrollController: _scrollController,
            key: UniqueKey(),
          );
          break;
        case 2:
          _screens[index] = MessageScreen(
            scrollController: _scrollController,
            key: UniqueKey(),
          );
          break;
        case 3:
          _screens[index] = NotificationScreen(
            scrollController: _scrollController,
            key: UniqueKey(),
          );
          break;
        case 4:
          _screens[index] = GeneralScreen();
          break;
      }
    }
    return _screens[index]!;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _getScreen(_currenIndex),
      bottomNavigationBar: _isBottomNavBarVisible
          ? Container(
              height: 75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)),
                border: Border(
                    top: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1.5,
                    ),
                    left: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1.5,
                    ),
                    right: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1.5,
                    )),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black38, spreadRadius: 0, blurRadius: 20),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                child: BottomNavigationBar(
                  currentIndex: _currenIndex,
                  onTap: _onTabTapped,
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.newspaper_outlined),
                      activeIcon: Icon(Icons.newspaper),
                      label: AppLocalizations.of(context)!.newFeeds,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.people_outline),
                      activeIcon: Icon(Icons.people),
                      label: AppLocalizations.of(context)!.friend,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.message_outlined),
                      activeIcon: Icon(Icons.message),
                      label: AppLocalizations.of(context)!.messages,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.notifications_outlined),
                      activeIcon: Icon(Icons.notifications),
                      label: AppLocalizations.of(context)!.notifications,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.menu_outlined),
                      activeIcon: Icon(Icons.menu_open_rounded),
                      label: AppLocalizations.of(context)!.general,
                    ),
                  ],
                ),
              ))
          : SizedBox.shrink(),
    );
  }
}
