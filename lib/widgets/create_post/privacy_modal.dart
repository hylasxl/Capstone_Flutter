import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PrivacyBottomSheetContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.whocanseepost,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          SizedBox(height: 10),
          Text(AppLocalizations.of(context)!.postAppearance,
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                  color: Colors.grey[500])),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.public),
            title: Text(
              AppLocalizations.of(context)!.public,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(AppLocalizations.of(context)!.anyoneOnOrOff),
            onTap: () {
              Navigator.pop(context, 'public');
            },
          ),
          Divider(
            color: Colors.grey[300],
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text(
              AppLocalizations.of(context)!.friendOnly,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(AppLocalizations.of(context)!.yourFriendsOnSyncIO),
            onTap: () {
              Navigator.pop(context, 'friend_only');
            },
          ),
          Divider(
            color: Colors.grey[300],
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text(
              AppLocalizations.of(context)!.private,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context, 'private');
            },
            subtitle: Text(AppLocalizations.of(context)!.onlyMe),
          ),
          Divider(
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}
