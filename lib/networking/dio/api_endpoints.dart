class ApiVersioning {
  static String version = "/api/v1";
}

class ApiEndpoints {
  static String login = "${ApiVersioning.version}/authentication/login";
  static String register = "${ApiVersioning.version}/authentication/register";

  static String checkDuplicateCredentials =
      "${ApiVersioning.version}/users/check-duplicate";
  static String getAccountInfo = "${ApiVersioning.version}/users/get-infos";
  static String getProfileInfo =
      "${ApiVersioning.version}/users/get-profile-info";
  static String changeAvatar = "${ApiVersioning.version}/users/change-avatar";
  static String changeUserInfo =
      "${ApiVersioning.version}/users/change-user-info";
  static String loginWithGoogle =
      "${ApiVersioning.version}/users/login-with-google";
  static String verifyEmailAndUsername =
      "${ApiVersioning.version}/users/verify-username-email";
  static String changePassword =
      "${ApiVersioning.version}/users/change-password";
  static String searchAccount = "${ApiVersioning.version}/users/search-account";

  static String getPendingList =
      "${ApiVersioning.version}/friends/get-pending-list";
  static String countFriendPending =
      "${ApiVersioning.version}/friends/count-pending-request";
  static String resolveFriendRequest =
      "${ApiVersioning.version}/friends/resolve-request";
  static String getListFriend =
      "${ApiVersioning.version}/friends/get-list-friend";
  static String sendFriendRequest =
      "${ApiVersioning.version}/friends/send-request";
  static String recallFriendRequest =
      "${ApiVersioning.version}/friends/recall-request";
  static String checkExistingFriendRequest =
      "${ApiVersioning.version}/friends/check-existing-request";
  static String unFriend = "${ApiVersioning.version}/friends/unfriend";
  static String resolveFriendFollow =
      "${ApiVersioning.version}/friends/resolve-follow";
  static String resolveFriendBlock =
      "${ApiVersioning.version}/friends/resolve-block";
  static String checkIsFollow =
      "${ApiVersioning.version}/friends/check-is-follow";
  static String checkIsBlock =
      "${ApiVersioning.version}/friends/check-is-block";
  static String getListBlockInfo =
      "${ApiVersioning.version}/friends/get-block-list-info";

  static String createPost = "${ApiVersioning.version}/posts/create-new-post";
  static String getWallList = "${ApiVersioning.version}/posts/get-wall-posts";
  static String getPostComment =
      "${ApiVersioning.version}/posts/get-post-comments";
  static String reactPost = "${ApiVersioning.version}/posts/react-post";
  static String removeReactPost =
      "${ApiVersioning.version}/posts/remove-react-post";
  static String replyComment =
      "${ApiVersioning.version}/posts/reply-comment-post";
  static String commentPost = "${ApiVersioning.version}/posts/comment-post";
  static String sharePost = "${ApiVersioning.version}/posts/share-post";
  static String getNewsFeed = "${ApiVersioning.version}/posts/get-new-feeds";
  static String deletePost = "${ApiVersioning.version}/posts/delete-post";

  static String registerDevice =
      "${ApiVersioning.version}/notifications/register-device";
  static String getNotifications =
      "${ApiVersioning.version}/notifications/get-notifications";
  static String markAsRead = "${ApiVersioning.version}/notifications/mark-read";
  static String countUnread =
      "${ApiVersioning.version}/notifications/count-unread";

  static String setPrivacy = "${ApiVersioning.version}/privacy/set-privacy";

  static String sendOTPForgetPassword =
      "${ApiVersioning.version}/otps/send-forget-password";
  static String checkValidOTP = "${ApiVersioning.version}/otps/check-valid-otp";

  static String getChatList = "${ApiVersioning.version}/messages/get-chat-list";
  static String createChat =
      "${ApiVersioning.version}/messages/create-new-chat";
  static String deleteChat = "${ApiVersioning.version}/messages/delete-chat";
  static String getChatMessages =
      "${ApiVersioning.version}/messages/get-messages";
  static String actionMessage =
      "${ApiVersioning.version}/messages/action-message";
  static String receiverMarkMessageAsRead =
      "${ApiVersioning.version}/messages/receiver-mark-message-as-read";

  static String reportPost = "${ApiVersioning.version}/moderation/report-post";
  static String reportAccount =
      "${ApiVersioning.version}/moderation/report-account";
}
