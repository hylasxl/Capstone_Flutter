import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncio_capstone/services/notification_service.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/utils/helpers.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  final ScrollController scrollController;
  const NotificationScreen({super.key, required this.scrollController});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int currentPage = 1;
  int pageSize = 20;
  List<NotificationContent> notifications = [];
  bool isFetching = false;
  bool hasMoreNoti = true;

  int? unreadNoti = 0;

  @override
  void initState() {
    _getNotifications();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _countUnreadNotification();
    });
    _markAsReadNotification();
    super.initState();
  }

  String _getDateText(String value) {
    try {
      int timestamp = int.parse(value);
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      return _formatDate(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _formatDate(DateTime date) {
    String locale = Localizations.localeOf(context).toString();

    if (locale.startsWith("en")) {
      String day = _getEnglishOrdinal(date.day);
      String month = DateFormat.MMMM('en-US').format(date);
      return AppLocalizations.of(context)!
          .formatDate(day, month, date.year.toString())
          .toString();
    } else {
      return AppLocalizations.of(context)!
          .formatDate(
            date.day.toString(),
            date.month.toString(),
            date.year.toString(),
          )
          .toString();
    }
  }

  String _getEnglishOrdinal(int day) {
    if (day >= 11 && day <= 13) {
      return "${day}th";
    }
    switch (day % 10) {
      case 1:
        return "${day}st";
      case 2:
        return "${day}nd";
      case 3:
        return "${day}rd";
      default:
        return "${day}th";
    }
  }

  Future<void> _getNotifications() async {
    if (isFetching || !hasMoreNoti) return;

    final LoginResponse? userData = await Helpers().getUserData();
    if (userData == null) return;

    final request = GetNotificationRequest(
      accountID: int.parse(userData.userID),
      page: currentPage,
      pageSize: pageSize,
    );

    setState(() {
      isFetching = true;
    });

    try {
      final response = await NotificationService().getNotifications(request);
      if (response.notifications == null || response.notifications!.isEmpty) {
        setState(() {
          hasMoreNoti = false;
        });
      } else {
        setState(() {
          notifications.addAll(response.notifications!);
          currentPage++;
        });
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      setState(() {
        isFetching = false;
      });
    }
  }

  Future<void> _onPageRefresh() async {
    setState(() {
      currentPage = 1;
      notifications.clear();
      hasMoreNoti = true;
    });
    await _getNotifications();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _countUnreadNotification();
    });
    _markAsReadNotification();
    super.initState();
  }

  Future<void> _markAsReadNotification() async {
    final LoginResponse? userData = await Helpers().getUserData();
    if (userData == null) return;
    final MarkAsReadNotificationRequest request =
        MarkAsReadNotificationRequest(accountID: int.parse(userData.userID));
    try {
      await NotificationService().markAsRead(request);
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
      throw Exception(e);
    }
  }

  Future<void> _countUnreadNotification() async {
    final LoginResponse? userData = await Helpers().getUserData();
    if (userData == null) return;
    final CountUnreadNotiRequest request =
        CountUnreadNotiRequest(accountID: int.parse(userData.userID));
    try {
      final CountUnreadNotiResponse response =
          await NotificationService().countUnread(request);
      setState(() {
        unreadNoti = response.quantity;
      });
    } catch (e) {
      debugPrint("Error counting unread notification: $e");
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: false,
        title: Row(
          children: [
            Text(
              AppLocalizations.of(context)!.notifications,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge!.color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: "SFProDisplay",
              ),
            ),
            const SizedBox(width: 8),
            if (unreadNoti != null && unreadNoti! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unreadNoti.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        titleTextStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge!.color,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: "SFProDisplay",
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollEndNotification &&
              scrollNotification.metrics.pixels ==
                  scrollNotification.metrics.maxScrollExtent) {
            _getNotifications();
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: _onPageRefresh,
          child: notifications.isEmpty
              ? Center(
                  child: Text(AppLocalizations.of(context)!.nothingToShow),
                )
              : ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  controller: widget.scrollController,
                  itemCount: notifications.length,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  itemBuilder: (context, index) => Container(
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: notifications[index].isRead!
                          ? Colors.white
                          : Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Icon(notifications[index].isRead!
                          ? Icons.notifications_off
                          : Icons.notifications_active),
                      title: Text(
                        notifications[index].content,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: "SFProDisplay",
                        ),
                      ),
                      subtitle: Text(
                        _getDateText(notifications[index].dateTime!.toString()),
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .color!
                              .withOpacity(0.5),
                          fontSize: 12,
                          fontFamily: "SFProDisplay",
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
