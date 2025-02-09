import 'package:flutter/material.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/widgets/posts/comment_section.dart';
import 'package:syncio_capstone/widgets/posts/share_post_modal.dart';

class InteractionBar extends StatefulWidget {
  final String parentType;
  final int parentID;
  final String privacy;
  final String selfInteractionType;
  final void Function(String type) onReactPress;
  final bool isShared;

  const InteractionBar({
    required this.selfInteractionType,
    required this.onReactPress,
    required this.parentID,
    required this.parentType,
    required this.isShared,
    required this.privacy,
    super.key,
  });

  @override
  State<InteractionBar> createState() => _InteractionBarState();
}

class _InteractionBarState extends State<InteractionBar> {
  static OverlayEntry? _overlayEntry;
  final GlobalKey _reactIconKey = GlobalKey();

  String currentIconState = "";
  Icon displaySelfIcon = Icon(
    Icons.thumb_up_outlined,
    color: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    _updateDisplayIcon();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateDisplayIcon();
  }

  void _updateDisplayIcon() {
    if (currentIconState.isEmpty) {
      currentIconState = widget.selfInteractionType;
    }
    final type = currentIconState.isEmpty ? "default" : currentIconState;

    final displayIcon = Icon(
      getReactIcon(type),
      color: getReactColor(type),
    );

    setState(() {
      displaySelfIcon = displayIcon;
      currentIconState = type;
    });
  }

  IconData getReactIcon(String type) {
    switch (type) {
      case "like":
        return Icons.thumb_up_outlined;
      case "dislike":
        return Icons.thumb_down_alt_outlined;
      case "love":
        return Icons.favorite_outline;
      case "hate":
        return Icons.sentiment_very_dissatisfied;
      case "cry":
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.thumb_up_outlined;
    }
  }

  Color getReactColor(String type) {
    switch (type) {
      case "like":
        return Color.fromRGBO(25, 4, 169, 21);
      case "dislike":
        return Colors.red;
      case "love":
        return Colors.redAccent;
      case "hate":
        return Colors.deepOrange;
      case "cry":
        return Colors.blueAccent;
      default:
        return Colors.black;
    }
  }

  void handleReactIconLongPress() {
    _showIconList();
  }

  void handleReactIconTap() {
    _hideIconList();
    if (currentIconState.isEmpty || currentIconState == "default") {
      setState(() {
        currentIconState = "like";
      });
      widget.onReactPress("like");
    } else {
      setState(() {
        currentIconState = "default";
        widget.onReactPress("remove");
      });
    }
    _updateDisplayIcon();
  }

  void handleMessageIconTap() {
    _hideIconList();
    _showCommentBottomSheet(context);
  }

  void handleShareIconTap() {
    _hideIconList();
    _showSharePostModal(context, (post) {}, widget.parentID);
  }

  void selectReaction(String type) {
    _hideIconList();
    if (currentIconState != "default" || currentIconState.isEmpty) {
      widget.onReactPress("remove");
    }
    setState(() {
      currentIconState = type;
    });
    widget.onReactPress(type);
    _updateDisplayIcon();
  }

  void _showIconList() {
    _hideIconList();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideIconList() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showCommentBottomSheet(
    BuildContext context,
  ) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        enableDrag: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return CommentSection(
            postID: widget.parentID,
          );
        });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox =
        _reactIconKey.currentContext!.findRenderObject() as RenderBox;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => AnimatedPositioned(
        duration: Duration(milliseconds: 300),
        left: offset.dx,
        top: offset.dy - 70,
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 60,
            width: 230,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildReactionIcon(Icons.thumb_up, Colors.blue, "like"),
                _buildReactionIcon(Icons.favorite, Colors.red, "love"),
                _buildReactionIcon(
                    Icons.thumb_down_alt_outlined, Colors.yellow, "dislike"),
                _buildReactionIcon(
                    Icons.sentiment_dissatisfied, Colors.orange, "cry"),
                _buildReactionIcon(Icons.sentiment_very_dissatisfied,
                    Colors.lightBlue, "hate"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReactionIcon(IconData icon, Color color, String type) {
    return GestureDetector(
      onTap: () => selectReaction(type),
      child: MouseRegion(
        onEnter: (event) => setState(() {}),
        onExit: (event) => setState(() {}),
        child: AnimatedScale(
          scale: 1.0,
          duration: Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  void _showSharePostModal(BuildContext context,
      ValueChanged<DisplayPost> onCommitShare, int postID) async {
    final DisplayPost? shareModal = await showModalBottomSheet<DisplayPost>(
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return SharePostModal(
          postID: postID,
        );
      },
    );
    if (shareModal != null) {
      onCommitShare(shareModal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _hideIconList,
      child: Column(
        children: [
          SizedBox(
            height: 40,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Reaction Icon
                GestureDetector(
                  key: _reactIconKey,
                  onLongPress: handleReactIconLongPress,
                  onTap: handleReactIconTap,
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: displaySelfIcon,
                  ),
                ),
                // Message Icon
                GestureDetector(
                  onTap: handleMessageIconTap,
                  child: Container(
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    child: Icon(Icons.message_outlined, size: 24),
                  ),
                ),
                if (!widget.isShared &&
                    widget.parentType == "post" &&
                    widget.privacy == "public")
                  GestureDetector(
                    onTap: handleShareIconTap,
                    child: Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      child: Icon(Icons.share_outlined, size: 24),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReactionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ReactionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(
          icon,
          color: color,
          size: 30,
        ),
      ),
    );
  }
}
