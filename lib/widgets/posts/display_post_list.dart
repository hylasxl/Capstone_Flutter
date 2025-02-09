import 'package:flutter/material.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/widgets/posts/post.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DisplayPostList extends StatefulWidget {
  final List<DisplayPost> postToDisplay;
  const DisplayPostList({required this.postToDisplay, super.key});

  @override
  State<DisplayPostList> createState() => _DisplayPostState();
}

class _DisplayPostState extends State<DisplayPostList> {
  @override
  Widget build(BuildContext context) {
    return widget.postToDisplay.isNotEmpty
        ? SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Post(
                  index: index,
                  postToDisplay: widget.postToDisplay[index],
                );
              },
              childCount: widget.postToDisplay.length,
            ),
          )
        : SliverToBoxAdapter(
            child: Center(
              child: Text(AppLocalizations.of(context)!.nothingToShow),
            ),
          );
  }
}
