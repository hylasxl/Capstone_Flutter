import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class BaseCommentResponse {
  final String error;
  final int commentID;
  final bool success;

  BaseCommentResponse({
    required this.error,
    required this.success,
    required this.commentID,
  });

  factory BaseCommentResponse.fromJson(Map<String, dynamic> json) {
    return BaseCommentResponse(
      error: json['error'] ?? '',
      success: json['success'] ?? false,
      commentID: json['comment_id'] ?? 0,
    );
  }
}

class CommentPostResponse extends BaseCommentResponse {
  CommentPostResponse({
    required String error,
    required bool success,
    required int commentID,
  }) : super(error: error, success: success, commentID: commentID);

  factory CommentPostResponse.fromJson(Map<String, dynamic> json) {
    return CommentPostResponse(
      error: json['error'] ?? '',
      success: json['success'] ?? false,
      commentID: json['comment_id'] ?? 0,
    );
  }
}

class ReplyCommentResponse extends BaseCommentResponse {
  ReplyCommentResponse({
    required String error,
    required bool success,
    required int commentID,
  }) : super(error: error, success: success, commentID: commentID);

  factory ReplyCommentResponse.fromJson(Map<String, dynamic> json) {
    return ReplyCommentResponse(
      error: json['error'] ?? '',
      success: json['success'] ?? false,
      commentID: json['comment_id'] ?? 0,
    );
  }
}

class CreatePostRequest {
  String accountID;
  String content;
  bool isPublishedLater;
  int? publishedLaterTimestamp;
  String privacyStatus;
  List<String> tagAccountIDs;
  List<MultiMediaMessage> medias;

  CreatePostRequest({
    required this.accountID,
    required this.content,
    required this.isPublishedLater,
    required this.publishedLaterTimestamp,
    required this.privacyStatus,
    required this.tagAccountIDs,
    required this.medias,
  });

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountID,
      'content': content,
      'is_published_later': isPublishedLater,
      'published_later_timestamp': publishedLaterTimestamp,
      'privacy_status': privacyStatus,
      'tag_account_ids': tagAccountIDs.isEmpty ? null : tagAccountIDs,
      'medias': medias.isEmpty ? null : medias.map((e) => e.toJson()).toList(),
    };
  }

  Future<FormData> toFormData() async {
    FormData formData = FormData();
    formData.fields.add(MapEntry('account_id', accountID));
    formData.fields.add(MapEntry('content', content));
    formData.fields
        .add(MapEntry('is_published_later', isPublishedLater.toString()));
    formData.fields.add(MapEntry('privacy_status', privacyStatus));
    formData.fields.add(publishedLaterTimestamp == null
        ? MapEntry('published_later_timestamp', "0")
        : MapEntry(
            'published_later_timestamp', publishedLaterTimestamp.toString()));

    if (tagAccountIDs.isNotEmpty) {
      formData.fields.add(MapEntry('tag_account_ids', tagAccountIDs.join(',')));
    }

    for (var mediaMessage in medias) {
      var multipartFile = await mediaMessage.toMultipartFile();
      formData.files.add(MapEntry('medias', multipartFile));
    }

    return formData;
  }
}

class MultiMediaMessage {
  String type;
  String uploadStatus;
  String content;
  File? media;

  MultiMediaMessage({
    required this.type,
    required this.uploadStatus,
    required this.content,
    this.media,
  });

  Future<MultipartFile> toMultipartFile() async {
    if (media == null) {
      throw Exception('Media file is null');
    }

    String? mimeType = lookupMimeType(media!.path);
    mimeType ??= 'application/octet-stream';
    return MultipartFile.fromFile(
      media!.path,
      contentType: MediaType.parse(mimeType),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'upload_status': uploadStatus,
      'content': content,
      'media': media?.path,
    };
  }
}

class CreatePostResponse {
  String postID;
  List<String>? mediaURLs;

  CreatePostResponse({
    required this.postID,
    required this.mediaURLs,
  });

  factory CreatePostResponse.fromJson(Map<String, dynamic> json) {
    return CreatePostResponse(
      postID: json['post_id'],
      mediaURLs: json['media_urls'] == null
          ? null
          : List<String>.from(json['media_urls']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'post_id': postID,
      'media_urls': mediaURLs,
    };
  }
}

class SharePostRequest {
  String accountID;
  String content;
  bool isShared;
  String originalPostID;
  String privacyStatus;
  List<String> tagAccountIDs;

  SharePostRequest({
    required this.accountID,
    required this.content,
    required this.isShared,
    required this.originalPostID,
    required this.privacyStatus,
    required this.tagAccountIDs,
  });

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountID,
      'content': content,
      'is_shared': isShared,
      'original_post_id': originalPostID,
      'privacy_status': privacyStatus,
      'tag_account_ids': tagAccountIDs,
    };
  }
}

class SharePostResponse {
  String postID;

  SharePostResponse({
    required this.postID,
  });

  factory SharePostResponse.fromJson(Map<String, dynamic> json) {
    return SharePostResponse(postID: json['post_id']);
  }
}

class SendFriendRequest {
  String fromAccountID;
  String toAccountID;

  SendFriendRequest({
    required this.fromAccountID,
    required this.toAccountID,
  });

  Map<String, dynamic> toJson() {
    return {
      'from_account_id': fromAccountID,
      'to_account_id': toAccountID,
    };
  }
}

class SendFriendResponse {
  bool? success;
  String? error;
  int requestID;

  SendFriendResponse({
    required this.success,
    required this.error,
    required this.requestID,
  });

  factory SendFriendResponse.fromJson(Map<String, dynamic> json) {
    return SendFriendResponse(
      success: json['success'] ?? false,
      error: json['error'] ?? "",
      requestID: json['request_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'error': error,
      'request_id': requestID,
    };
  }
}

class ResolveFriendRequest {
  String receiverAccountID;
  String requestID;
  String action;

  ResolveFriendRequest({
    required this.receiverAccountID,
    required this.requestID,
    required this.action,
  });

  Map<String, dynamic> toJson() {
    return {
      'receiver_account_id': receiverAccountID,
      'request_id': requestID,
      'action': action,
    };
  }
}

class ResolveFriendResponse {
  bool success;
  String error;

  ResolveFriendResponse({
    required this.success,
    required this.error,
  });

  factory ResolveFriendResponse.fromJson(Map<String, dynamic> json) {
    return ResolveFriendResponse(
      success: json['success'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'error': error,
    };
  }
}

class RecallRequest {
  String senderAccountID;
  String requestID;

  RecallRequest({
    required this.senderAccountID,
    required this.requestID,
  });

  Map<String, dynamic> toJson() {
    return {
      'sender_account_id': senderAccountID,
      'request_id': requestID,
    };
  }
}

class RecallResponse {
  bool? success;
  String? error;

  RecallResponse({
    this.success,
    this.error,
  });

  factory RecallResponse.fromJson(Map<String, dynamic> json) {
    return RecallResponse(
      success: json['success'] ?? false,
      error: json['error'] ?? "",
    );
  }
}

class UnfriendRequest {
  String fromAccountID;
  String toAccountID;

  UnfriendRequest({
    required this.fromAccountID,
    required this.toAccountID,
  });

  Map<String, dynamic> toJson() {
    return {
      'from_account_id': fromAccountID,
      'to_account_id': toAccountID,
    };
  }
}

class UnfriendResponse {
  bool? success;
  String? error;

  UnfriendResponse({
    this.success,
    this.error,
  });

  factory UnfriendResponse.fromJson(Map<String, dynamic> json) {
    return UnfriendResponse(
      success: json['success'] ?? false,
      error: json['error'],
    );
  }
}

class FollowRequest {
  String fromAccountID;
  String toAccountID;
  String action;

  FollowRequest({
    required this.fromAccountID,
    required this.toAccountID,
    required this.action,
  });

  Map<String, dynamic> toJson() {
    return {
      'from_account_id': fromAccountID,
      'to_account_id': toAccountID,
      'action': action,
    };
  }
}

class FollowResponse {
  bool success;
  String error;

  FollowResponse({
    required this.success,
    required this.error,
  });

  factory FollowResponse.fromJson(Map<String, dynamic> json) {
    return FollowResponse(
      success: json['success'],
      error: json['error'],
    );
  }
}

class BlockRequest {
  String fromAccountID;
  String toAccountID;
  String action;

  BlockRequest({
    required this.fromAccountID,
    required this.toAccountID,
    required this.action,
  });

  Map<String, dynamic> toJson() {
    return {
      'from_account_id': fromAccountID,
      'to_account_id': toAccountID,
      'action': action,
    };
  }
}

class BlockResponse {
  bool? success;
  String? error;

  BlockResponse({
    required this.success,
    required this.error,
  });

  factory BlockResponse.fromJson(Map<String, dynamic> json) {
    return BlockResponse(
      success: json['success'] ?? false,
      error: json['error'] ?? "",
    );
  }
}

class GetPendingListRequest {
  String accountID;
  int page;

  GetPendingListRequest({required this.accountID, required this.page});

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountID,
      'page': page,
    };
  }
}

class GetPendingListResponse {
  List<GetPendingListReturnSingleLine> data;
  int page;
  String error;

  GetPendingListResponse({
    required this.data,
    required this.page,
    this.error = '',
  });

  factory GetPendingListResponse.fromJson(Map<String, dynamic> json) {
    return GetPendingListResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => GetPendingListReturnSingleLine.fromJson(e))
          .toList(),
      error: json['error'] ?? '',
      page: int.parse(json['page'].toString()),
    );
  }
}

class GetPendingListReturnSingleLine {
  SingleAccountInfo accountInfo;
  String requestID;
  int createdAt;
  int mutualFriends;

  GetPendingListReturnSingleLine(
      {required this.accountInfo,
      required this.requestID,
      required this.createdAt,
      required this.mutualFriends});

  factory GetPendingListReturnSingleLine.fromJson(Map<String, dynamic> json) {
    return GetPendingListReturnSingleLine(
        accountInfo: SingleAccountInfo.fromJson(json['account_info']),
        requestID: json['request_id'],
        createdAt: json['created_at'],
        mutualFriends: json['mutual_friends']);
  }
}

class SingleAccountInfo {
  int accountID;
  String avatarURL;
  String displayName;

  SingleAccountInfo({
    required this.accountID,
    required this.avatarURL,
    required this.displayName,
  });

  factory SingleAccountInfo.fromJson(Map<String, dynamic> json) {
    return SingleAccountInfo(
      accountID: json['account_id'],
      avatarURL: json['avatar_url'],
      displayName: json['display_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountID,
      "avatar_url": avatarURL,
      "display_name": displayName,
    };
  }
}

class LoginRequest {
  String username;
  String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class LoginResponse {
  String accessToken;
  String refreshToken;
  String userID;
  JWTClaims jwtClaims;
  bool success;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userID,
    required this.jwtClaims,
    required this.success,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      userID: json['user_id'],
      jwtClaims: JWTClaims.fromJson(json['jwt_claims']),
      success: json['success'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user_id': userID,
      'jwt_claims': jwtClaims.toJson(),
      'success': success,
    };
  }
}

class JWTClaims {
  String accountId;
  List<String> permissions;
  String roleId;
  String issuer;
  String subject;
  String audience;

  JWTClaims({
    required this.accountId,
    required this.permissions,
    required this.roleId,
    required this.issuer,
    required this.subject,
    required this.audience,
  });

  factory JWTClaims.fromJson(Map<String, dynamic> json) {
    return JWTClaims(
      accountId: json['accountId'],
      permissions: List<String>.from(json['permissions']),
      roleId: json['roleId'],
      issuer: json['issuer'],
      subject: json['subject'],
      audience: json['audience'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'permissions': permissions,
      'roleId': roleId,
      'issuer': issuer,
      'subject': subject,
      'audience': audience,
    };
  }
}

class SignUpRequest {
  String username;
  String password;
  String firstName;
  String lastName;
  String birthDate;
  String gender;
  String email;
  String phone;
  String image;

  SignUpRequest({
    required this.username,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.gender,
    required this.email,
    required this.phone,
    required this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'birth_date': birthDate,
      'gender': gender,
      'email': email,
      'phone': phone,
      'image': image,
    };
  }
}

class SignUpResponse {
  String userID;
  bool success;

  SignUpResponse({
    required this.userID,
    required this.success,
  });

  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    return SignUpResponse(
      userID: json['user_id'],
      success: json['success'],
    );
  }
}

class CheckDuplicateRequest {
  String data;
  String dataType;

  CheckDuplicateRequest({
    required this.data,
    required this.dataType,
  });

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'data_type': dataType,
    };
  }
}

class CheckDuplicateResponse {
  bool isDuplicate;

  CheckDuplicateResponse({required this.isDuplicate});

  factory CheckDuplicateResponse.fromJson(Map<String, dynamic> json) {
    return CheckDuplicateResponse(isDuplicate: json['is_duplicate']);
  }
}

class CheckValidUserRequest {
  String accountID;

  CheckValidUserRequest({required this.accountID});

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountID,
    };
  }
}

class CheckValidUserResponse {
  bool isValid;

  CheckValidUserResponse({required this.isValid});

  factory CheckValidUserResponse.fromJson(Map<String, dynamic> json) {
    return CheckValidUserResponse(isValid: json['is_valid']);
  }
}

class CommentPostRequest {
  int accountID;
  int postID;
  String content;

  CommentPostRequest({
    required this.accountID,
    required this.postID,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountID,
      'post_id': postID,
      'content': content,
    };
  }
}

class ReplyCommentRequest {
  int accountID;
  String content;
  int originalCommentID;
  int postID;

  ReplyCommentRequest({
    required this.accountID,
    required this.content,
    required this.originalCommentID,
    required this.postID,
  });

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountID,
      'content': content,
      'original_comment_id': originalCommentID,
      'post_id': postID,
    };
  }
}

class GetSinglePostRequest {
  int postID;

  GetSinglePostRequest({required this.postID});

  Map<String, dynamic> toJson() {
    return {
      'post_id': postID,
    };
  }
}

class GetSinglePostResponse {
  int postID;
  String content;
  String privacyStatus;
  List<MediaDisplay> medias;
  int totalCommentNumber;
  int totalReactionNumber;
  int totalShareNumber;
  String error;
  bool success;

  GetSinglePostResponse({
    required this.postID,
    required this.content,
    required this.privacyStatus,
    required this.medias,
    required this.totalCommentNumber,
    required this.totalReactionNumber,
    required this.totalShareNumber,
    required this.error,
    required this.success,
  });

  factory GetSinglePostResponse.fromJson(Map<String, dynamic> json) {
    return GetSinglePostResponse(
      postID: json['post_id'],
      content: json['content'],
      privacyStatus: json['privacy_status'],
      medias: List<MediaDisplay>.from(
          json['medias'].map((x) => MediaDisplay.fromJson(x))),
      totalCommentNumber: json['total_comment_number'],
      totalReactionNumber: json['total_reaction_number'],
      totalShareNumber: json['total_share_number'],
      error: json['error'],
      success: json['success'],
    );
  }
}

class MediaDisplay {
  MediaDisplay();

  factory MediaDisplay.fromJson(Map<String, dynamic> json) {
    return MediaDisplay();
  }
}

class DeletePostRequest {
  int postID;

  DeletePostRequest({required this.postID});

  Map<String, dynamic> toJson() {
    return {
      'post_id': postID,
    };
  }
}

class DeletePostResponse {
  int? postID;
  String? error;
  bool? success;

  DeletePostResponse({
    required this.postID,
    required this.error,
    required this.success,
  });

  factory DeletePostResponse.fromJson(Map<String, dynamic> json) {
    return DeletePostResponse(
      postID: json['post_id'] ?? 0,
      error: json['error'] ?? '',
      success: json['success'] ?? false,
    );
  }
}

class EditPostCommentRequest {
  int commentID;
  String content;

  EditPostCommentRequest({
    required this.commentID,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'comment_id': commentID,
      'content': content,
    };
  }
}

class EditPostCommentResponse {
  int commentID;
  String error;
  bool success;

  EditPostCommentResponse({
    required this.commentID,
    required this.error,
    required this.success,
  });

  factory EditPostCommentResponse.fromJson(Map<String, dynamic> json) {
    return EditPostCommentResponse(
      commentID: json['comment_id'],
      error: json['error'],
      success: json['success'],
    );
  }
}

class DeletePostCommentRequest {
  int commentID;

  DeletePostCommentRequest({required this.commentID});

  Map<String, dynamic> toJson() {
    return {
      'comment_id': commentID,
    };
  }
}

class DeletePostCommentResponse {
  String error;
  bool success;

  DeletePostCommentResponse({
    required this.error,
    required this.success,
  });

  factory DeletePostCommentResponse.fromJson(Map<String, dynamic> json) {
    return DeletePostCommentResponse(
      error: json['error'],
      success: json['success'],
    );
  }
}

class DeletePostImageRequest {
  int postID;
  int mediaID;

  DeletePostImageRequest({
    required this.postID,
    required this.mediaID,
  });

  Map<String, dynamic> toJson() {
    return {
      'post_id': postID,
      'media_id': mediaID,
    };
  }
}

class DeletePostImageResponse {
  String error;
  bool success;

  DeletePostImageResponse({
    required this.error,
    required this.success,
  });

  factory DeletePostImageResponse.fromJson(Map<String, dynamic> json) {
    return DeletePostImageResponse(
      error: json['error'],
      success: json['success'],
    );
  }
}

class ReactPostRequest {
  int postID;
  int accountID;
  String reactType;

  ReactPostRequest({
    required this.postID,
    required this.accountID,
    required this.reactType,
  });

  Map<String, dynamic> toJson() {
    return {
      'post_id': postID,
      'account_id': accountID,
      'react_type': reactType,
    };
  }
}

class ReactPostResponse {
  String error;
  bool success;

  ReactPostResponse({
    required this.error,
    required this.success,
  });

  factory ReactPostResponse.fromJson(Map<String, dynamic> json) {
    return ReactPostResponse(
      error: json['error'],
      success: json['success'],
    );
  }
}

class RemoveReactPostRequest {
  int postID;
  int accountID;

  RemoveReactPostRequest({
    required this.postID,
    required this.accountID,
  });

  Map<String, dynamic> toJson() {
    return {
      'post_id': postID,
      'account_id': accountID,
    };
  }
}

class RemoveReactPostResponse {
  String error;
  bool success;

  RemoveReactPostResponse({
    required this.error,
    required this.success,
  });

  factory RemoveReactPostResponse.fromJson(Map<String, dynamic> json) {
    return RemoveReactPostResponse(
      error: json['error'],
      success: json['success'],
    );
  }
}

class ReactImageRequest {
  int mediaID;
  int accountID;
  String reactType;

  ReactImageRequest({
    required this.mediaID,
    required this.accountID,
    required this.reactType,
  });

  Map<String, dynamic> toJson() {
    return {
      'media_id': mediaID,
      'account_id': accountID,
      'react_type': reactType,
    };
  }
}

class ReactImageResponse {
  String error;
  bool success;

  ReactImageResponse({
    required this.error,
    required this.success,
  });

  factory ReactImageResponse.fromJson(Map<String, dynamic> json) {
    return ReactImageResponse(
      error: json['error'],
      success: json['success'],
    );
  }
}

class RemoveReactImageRequest {
  int mediaID;
  int accountID;

  RemoveReactImageRequest({
    required this.mediaID,
    required this.accountID,
  });

  Map<String, dynamic> toJson() {
    return {
      'media_id': mediaID,
      'account_id': accountID,
    };
  }
}

class RemoveReactImageResponse {
  String error;
  bool success;

  RemoveReactImageResponse({
    required this.error,
    required this.success,
  });

  factory RemoveReactImageResponse.fromJson(Map<String, dynamic> json) {
    return RemoveReactImageResponse(
      error: json['error'],
      success: json['success'],
    );
  }
}

class RefreshTokenRequest {
  String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {
      'refresh_token': refreshToken,
    };
  }
}

class RefreshTokenResponse {
  String accessToken;
  String refreshToken;

  RefreshTokenResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }
}

class GetAccountInfoRequest {
  final int accountId;

  GetAccountInfoRequest({required this.accountId});

  factory GetAccountInfoRequest.fromJson(Map<String, dynamic> json) {
    return GetAccountInfoRequest(accountId: json['account_id'] as int);
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
    };
  }
}

class GetAccountInfoResponse {
  final int accountId;
  final Account account;
  final AccountInfo accountInfo;
  final AccountAvatar accountAvatar;

  GetAccountInfoResponse({
    required this.accountId,
    required this.account,
    required this.accountInfo,
    required this.accountAvatar,
  });

  factory GetAccountInfoResponse.fromJson(Map<String, dynamic> json) {
    return GetAccountInfoResponse(
      accountId: json['account_id'] as int,
      account: Account.fromJson(json['account'] as Map<String, dynamic>),
      accountInfo:
          AccountInfo.fromJson(json['account_info'] as Map<String, dynamic>),
      accountAvatar: AccountAvatar.fromJson(
          json['account_avatar'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
      'account': account.toJson(),
      'account_info': accountInfo.toJson(),
      'account_avatar': accountAvatar.toJson(),
    };
  }
}

class Account {
  final String username;
  final int roleId;
  final String createMethod;
  final bool isBanned;
  final bool isRestricted;
  final bool isSelfDeleted;

  Account({
    required this.username,
    required this.roleId,
    required this.createMethod,
    required this.isBanned,
    required this.isRestricted,
    required this.isSelfDeleted,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      username: json['username'] as String,
      roleId: json['role_id'] as int,
      createMethod: json['create_method'] as String,
      isBanned: json['is_banned'] as bool,
      isRestricted: json['is_restricted'] as bool,
      isSelfDeleted: json['is_self_deleted'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'role_id': roleId,
      'create_method': createMethod,
      'is_banned': isBanned,
      'is_restricted': isRestricted,
      'is_self_deleted': isSelfDeleted,
    };
  }
}

class AccountInfo {
  final String firstName;
  final String lastName;
  final int dateOfBirth;
  final String gender;
  final String materialStatus;
  final String phoneNumber;
  final String email;
  final String nameDisplayType;
  final String bio;

  AccountInfo({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.materialStatus,
    required this.phoneNumber,
    required this.email,
    required this.nameDisplayType,
    required this.bio,
  });

  factory AccountInfo.fromJson(Map<String, dynamic> json) {
    return AccountInfo(
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      dateOfBirth: json['date_of_birth'] as int,
      gender: json['gender'] as String,
      materialStatus: json['material_status'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String,
      nameDisplayType: json['name_display_type'] as String,
      bio: json['bio'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'material_status': materialStatus,
      'phone_number': phoneNumber,
      'email': email,
      'name_display_type': nameDisplayType,
      'bio': bio,
    };
  }
}

class AccountAvatar {
  final int avatarId;
  final String avatarUrl;
  final bool isInUse;
  final bool isDeleted;

  AccountAvatar({
    required this.avatarId,
    required this.avatarUrl,
    required this.isInUse,
    required this.isDeleted,
  });

  factory AccountAvatar.fromJson(Map<String, dynamic> json) {
    return AccountAvatar(
      avatarId: json['avatar_id'] as int,
      avatarUrl: json['avatar_url'] as String,
      isInUse: json['is_in_use'] as bool,
      isDeleted: json['is_deleted'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar_id': avatarId,
      'avatar_url': avatarUrl,
      'is_in_use': isInUse,
      'is_deleted': isDeleted,
    };
  }
}

class CountFriendPendingRequest {
  final int accountID;

  CountFriendPendingRequest({required this.accountID});
  factory CountFriendPendingRequest.fromJson(Map<String, dynamic> json) {
    return CountFriendPendingRequest(accountID: json['account_id'] as int);
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountID,
    };
  }
}

class CountFriendPendingResponse {
  final int quantity;
  final String error;

  CountFriendPendingResponse({
    required this.quantity,
    required this.error,
  });

  factory CountFriendPendingResponse.fromJson(Map<String, dynamic> json) {
    return CountFriendPendingResponse(
      quantity: json['quantity'] as int,
      error: json['error'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'error': error,
    };
  }
}

class GetDislayListFriend {
  final String accountID;

  GetDislayListFriend({required this.accountID});

  Map<String, dynamic> toJson() {
    return {'account_id': accountID};
  }
}

class DisplayListFriendResponse {
  final List<FriendInfo>? infos;
  final String? error;
  final bool success;

  DisplayListFriendResponse({
    this.infos,
    this.error,
    required this.success,
  });

  factory DisplayListFriendResponse.fromJson(Map<String, dynamic> json) {
    return DisplayListFriendResponse(
      infos: json['Infos'] != null
          ? (json['Infos'] as List)
              .map((item) => FriendInfo.fromJson(item))
              .toList()
          : null,
      error: json['error'],
      success: json['success'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (infos != null) 'Infos': infos!.map((info) => info.toJson()).toList(),
      if (error != null) 'error': error,
      'success': success,
    };
  }
}

class FriendInfo {
  final int accountID;
  final String displayName;
  final String avatarURL;

  FriendInfo({
    required this.accountID,
    required this.displayName,
    required this.avatarURL,
  });

  factory FriendInfo.fromJson(Map<String, dynamic> json) {
    return FriendInfo(
      accountID: json['AccountID'],
      displayName: json['DisplayName'],
      avatarURL: json['AvatarURL'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AccountID': accountID,
      'DisplayName': displayName,
      'AvatarURL': avatarURL,
    };
  }
}

class GetWallPostListRequest {
  int targetAccountId;
  int requestAccountId;
  int page = 1;
  int pageSize = 10;

  GetWallPostListRequest({
    required this.targetAccountId,
    required this.requestAccountId,
    required this.page,
    required this.pageSize,
  });

  factory GetWallPostListRequest.fromJson(Map<String, dynamic> json) {
    return GetWallPostListRequest(
      targetAccountId: json['target_account_id'],
      requestAccountId: json['request_account_id'],
      page: json['page'],
      pageSize: json['page_size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'target_account_id': targetAccountId,
      'request_account_id': requestAccountId,
      'page': page,
      'page_size': pageSize,
    };
  }
}

class GetWallPostListResponse {
  int targetAccountId;
  int page;
  int pageSize;
  List<DisplayPost>? posts;
  String? error;

  GetWallPostListResponse({
    required this.targetAccountId,
    required this.page,
    required this.pageSize,
    required this.posts,
    this.error,
  });

  factory GetWallPostListResponse.fromJson(Map<String, dynamic> json) {
    return GetWallPostListResponse(
      targetAccountId: json['target_account_id'],
      page: json['page'],
      pageSize: json['page_size'],
      posts: (json['posts'] as List?)
              ?.map((post) => DisplayPost.fromJson(post))
              .toList() ??
          [],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'target_account_id': targetAccountId,
      'page': page,
      'page_size': pageSize,
      'posts': posts?.map((post) => post.toJson()).toList() ?? [],
      'error': error,
    };
  }
}

class DisplayPost {
  int postId;
  String content;
  bool isShared;
  int sharePostId;
  SharePostDataDisplay sharePostData;
  bool isHidden;
  bool isContentEdited;
  String privacyStatus;
  String interactionType;
  List<PostShareMediaDisplay> medias;
  int createdAt;
  bool isPublishedLater;
  int publishedLaterTimestamp;
  bool isPublished;
  PostReactionDisplay reactions;
  PostCommentDisplay commentQuantity;
  PostShareDisplay shares;
  String? error;
  SingleAccountInfo account;

  DisplayPost({
    required this.postId,
    required this.content,
    required this.isShared,
    required this.sharePostId,
    required this.sharePostData,
    required this.isHidden,
    required this.isContentEdited,
    required this.privacyStatus,
    required this.interactionType,
    required this.medias,
    required this.createdAt,
    required this.isPublishedLater,
    required this.publishedLaterTimestamp,
    required this.isPublished,
    required this.reactions,
    required this.commentQuantity,
    required this.shares,
    this.error,
    required this.account,
  });

  factory DisplayPost.fromJson(Map<String, dynamic> json) {
    return DisplayPost(
      postId: json['post_id'],
      content: json['content'],
      isShared: json['is_shared'],
      sharePostId: json['share_post_id'],
      sharePostData: SharePostDataDisplay.fromJson(json['share_post_data']),
      isHidden: json['is_hidden'],
      isContentEdited: json['is_content_edited'],
      privacyStatus: json['privacy_status'],
      interactionType: json['interaction_type'],
      medias: (json['medias'] as List)
          .map((media) => PostShareMediaDisplay.fromJson(media))
          .toList(),
      createdAt: json['created_at'],
      isPublishedLater: json['is_published_later'],
      publishedLaterTimestamp: json['published_later_timestamp'],
      isPublished: json['is_published'],
      reactions: PostReactionDisplay.fromJson(json['reactions']),
      commentQuantity: PostCommentDisplay.fromJson(json['comment_quantity']),
      shares: PostShareDisplay.fromJson(json['shares']),
      error: json['error'],
      account: SingleAccountInfo.fromJson(json['account']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'post_id': postId,
      'content': content,
      'is_shared': isShared,
      'share_post_id': sharePostId,
      'share_post_data': sharePostData.toJson(),
      'is_hidden': isHidden,
      'is_content_edited': isContentEdited,
      'privacy_status': privacyStatus,
      'interaction_type': interactionType,
      'medias': medias.map((media) => media.toJson()).toList(),
      'created_at': createdAt,
      'is_published_later': isPublishedLater,
      'published_later_timestamp': publishedLaterTimestamp,
      'is_published': isPublished,
      'reactions': reactions.toJson(),
      'comment_quantity': commentQuantity.toJson(),
      'shares': shares.toJson(),
      'error': error,
      'account': account.toJson(),
    };
  }
}

class SharePostDataDisplay {
  int postId;
  String content;
  bool isContentEdited;
  String privacyStatus;
  int createdAt;
  bool isPublished;
  List<PostShareMediaDisplay>? medias;
  SingleAccountInfo? account;

  SharePostDataDisplay({
    required this.postId,
    required this.content,
    required this.isContentEdited,
    required this.privacyStatus,
    required this.createdAt,
    required this.isPublished,
    required this.medias,
    required this.account,
  });

  factory SharePostDataDisplay.fromJson(Map<String, dynamic> json) {
    return SharePostDataDisplay(
        postId: json['post_id'],
        content: json['content'],
        isContentEdited: json['is_content_edited'],
        privacyStatus: json['privacy_status'],
        createdAt: json['created_at'],
        isPublished: json['is_published'],
        medias: (json['medias'] as List?)
                ?.map((media) => PostShareMediaDisplay.fromJson(media))
                .toList() ??
            [],
        account: SingleAccountInfo.fromJson(json['account']));
  }

  Map<String, dynamic> toJson() {
    return {
      'post_id': postId,
      'content': content,
      'is_content_edited': isContentEdited,
      'privacy_status': privacyStatus,
      'created_at': createdAt,
      'is_published': isPublished,
      'medias': medias!.map((media) => media.toJson()).toList(),
      'account': account!.toJson(),
    };
  }
}

class PostShareMediaDisplay {
  String url;
  String content;
  int mediaId;

  PostShareMediaDisplay({
    required this.url,
    required this.content,
    required this.mediaId,
  });

  factory PostShareMediaDisplay.fromJson(Map<String, dynamic> json) {
    return PostShareMediaDisplay(
      url: json['url'],
      content: json['content'],
      mediaId: json['media_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'content': content,
      'media_id': mediaId,
    };
  }
}

class PostReactionDisplay {
  int totalQuantity;
  List<PostReactionData>? reactions;

  PostReactionDisplay({
    required this.totalQuantity,
    required this.reactions,
  });

  factory PostReactionDisplay.fromJson(Map<String, dynamic> json) {
    return PostReactionDisplay(
      totalQuantity: json['total_quantity'],
      reactions: (json['reactions'] as List?)
              ?.map((reaction) => PostReactionData.fromJson(reaction))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_quantity': totalQuantity,
      'reactions':
          reactions?.map((reaction) => reaction.toJson()).toList() ?? [],
    };
  }
}

class PostReactionData {
  String reactionType;
  SingleAccountInfo account;

  PostReactionData({
    required this.reactionType,
    required this.account,
  });

  factory PostReactionData.fromJson(Map<String, dynamic> json) {
    return PostReactionData(
      reactionType: json['reaction_type'],
      account: SingleAccountInfo.fromJson(json['account']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reaction_type': reactionType,
      'account': account.toJson(),
    };
  }
}

class PostCommentDisplay {
  int totalQuantity;

  PostCommentDisplay({required this.totalQuantity});

  factory PostCommentDisplay.fromJson(Map<String, dynamic> json) {
    return PostCommentDisplay(totalQuantity: json['total_quantity']);
  }

  Map<String, dynamic> toJson() {
    return {'total_quantity': totalQuantity};
  }
}

class PostShareDisplay {
  int totalQuantity;
  List<PostShareData>? shares;

  PostShareDisplay({
    required this.totalQuantity,
    required this.shares,
  });

  factory PostShareDisplay.fromJson(Map<String, dynamic> json) {
    return PostShareDisplay(
      totalQuantity: json['total_quantity'],
      shares: (json['shares'] as List?)
              ?.map((share) => PostShareData.fromJson(share))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_quantity': totalQuantity,
      'shares': shares?.map((share) => share.toJson()).toList() ?? [],
    };
  }
}

class PostShareData {
  SingleAccountInfo account;
  int createdAt;

  PostShareData({
    required this.account,
    required this.createdAt,
  });

  factory PostShareData.fromJson(Map<String, dynamic> json) {
    return PostShareData(
      account: SingleAccountInfo.fromJson(json['account']),
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account.toJson(),
      'created_at': createdAt,
    };
  }
}

class GetPostCommentRequest {
  final int postID;
  int page = 1;
  int pageSize = 10;

  GetPostCommentRequest(
      {required this.postID, required this.page, required this.pageSize});

  factory GetPostCommentRequest.fromJson(Map<String, dynamic> json) {
    return GetPostCommentRequest(
        postID: json["post_id"],
        page: json['page'],
        pageSize: json['page_size']);
  }

  Map<String, dynamic> toJson() {
    return {
      'post_id': postID,
      'page': page,
      'page_size': pageSize,
    };
  }
}

class GetPostCommentsResponse {
  String? error;
  bool success;
  int postId;
  int totalCommentNumber;
  List<Comment>? comments;

  GetPostCommentsResponse({
    this.error,
    required this.success,
    required this.postId,
    required this.totalCommentNumber,
    this.comments,
  });

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'success': success,
      'post_id': postId,
      'total_comment_number': totalCommentNumber,
      'comments': comments?.map((comment) => comment.toJson()).toList(),
    };
  }

  factory GetPostCommentsResponse.fromJson(Map<String, dynamic> json) {
    return GetPostCommentsResponse(
      error: json['error'],
      success: json['success'],
      postId: json['post_id'],
      totalCommentNumber: json['total_comment_number'],
      comments: json['comments'] != null
          ? (json['comments'] as List)
              .map((commentJson) => Comment.fromJson(commentJson))
              .toList()
          : null,
    );
  }
}

class Comment {
  int commentId;
  int accountId;
  String content;
  bool isEdited;
  int? replyFromId;
  int level;
  List<Comment>? replies;

  Comment({
    required this.commentId,
    required this.accountId,
    required this.content,
    required this.isEdited,
    this.replyFromId,
    required this.level,
    this.replies,
  });

  Map<String, dynamic> toJson() {
    return {
      'CommentID': commentId,
      'AccountID': accountId,
      'Content': content,
      'IsEdited': isEdited,
      'ReplyFromID': replyFromId,
      'Level': level,
      'Replies': replies?.map((reply) => reply.toJson()).toList(),
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['CommentID'],
      accountId: json['AccountID'],
      content: json['Content'],
      isEdited: json['IsEdited'] ?? false,
      replyFromId: json['ReplyFromID'],
      level: json['Level'],
      replies: json['Replies'] != null
          ? (json['Replies'] as List)
              .map((replyJson) => Comment.fromJson(replyJson))
              .toList()
          : null,
    );
  }
}

class PrivacyIndices {
  String dateOfBirth;
  String gender;
  String materialStatus;
  String phoneNumber;
  String email;
  String bio;

  PrivacyIndices({
    required this.dateOfBirth,
    required this.gender,
    required this.materialStatus,
    required this.phoneNumber,
    required this.email,
    required this.bio,
  });

  factory PrivacyIndices.fromJson(Map<String, dynamic> json) {
    return PrivacyIndices(
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      materialStatus: json['material_status'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'material_status': materialStatus,
      'phone_number': phoneNumber,
      'email': email,
      'bio': bio,
    };
  }
}

class GetProfileInfoRequest {
  final int requestAccountID;
  final int targetAccountID;

  GetProfileInfoRequest({
    required this.requestAccountID,
    required this.targetAccountID,
  });

  factory GetProfileInfoRequest.fromJson(Map<String, dynamic> json) {
    return GetProfileInfoRequest(
      requestAccountID: json['request_account_id'],
      targetAccountID: json['target_account_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_account_id': requestAccountID,
      'target_account_id': targetAccountID,
    };
  }
}

class GetProfileInfoResponse {
  final int accountId;
  final Account account;
  final AccountInfo accountInfo;
  final AccountAvatar accountAvatar;
  final PrivacyIndices privacyIndices;
  final bool isFriend;
  final bool isBlocked;
  bool isFollowed;
  final int timestamp;
  final String? error;

  GetProfileInfoResponse(
      {required this.accountId,
      required this.account,
      required this.accountInfo,
      required this.accountAvatar,
      required this.privacyIndices,
      required this.isFriend,
      required this.isBlocked,
      required this.isFollowed,
      required this.timestamp,
      this.error});

  factory GetProfileInfoResponse.fromJson(Map<String, dynamic> json) {
    return GetProfileInfoResponse(
      accountId: json['account_id'],
      account: Account.fromJson(json['account']),
      accountInfo: AccountInfo.fromJson(json['account_info']),
      accountAvatar: AccountAvatar.fromJson(json['account_avatar']),
      privacyIndices: PrivacyIndices.fromJson(json['privacy_indices']),
      isFriend: json['is_friend'],
      isBlocked: json['is_blocked'],
      isFollowed: json['is_followed'],
      timestamp: json['timestamp'],
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
      'account': account.toJson(),
      'account_info': accountInfo.toJson(),
      'account_avatar': accountAvatar.toJson(),
      'privacy_indices': privacyIndices.toJson(),
      'is_friend': isFriend,
      'is_blocked': isBlocked,
      'is_followed': isFollowed,
      'timestamp': timestamp,
      'error': error,
    };
  }

  set isFriend(bool value) {
    isFriend = value;
  }
}

class GetNewsFeedRequest {
  final int accountID;
  final int page;
  final int pageSize;
  final List<int> seenPostIds;

  GetNewsFeedRequest({
    required this.accountID,
    required this.page,
    required this.pageSize,
    required this.seenPostIds,
  });

  factory GetNewsFeedRequest.fromJson(Map<String, dynamic> json) {
    return GetNewsFeedRequest(
      accountID: json['account_id'],
      page: json['page'],
      pageSize: json['page_size'],
      seenPostIds: List<int>.from(json['seen_post_ids']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountID,
      'page': page,
      'page_size': pageSize,
      'seen_post_id': seenPostIds,
    };
  }
}

class GetNewsFeedResponse {
  final int accountID;
  final int page;
  final int pageSize;
  final List<DisplayPost>? posts;

  GetNewsFeedResponse({
    required this.accountID,
    required this.page,
    required this.pageSize,
    required this.posts,
  });

  factory GetNewsFeedResponse.fromJson(Map<String, dynamic> json) {
    return GetNewsFeedResponse(
      accountID: json['account_id'],
      page: json['page'],
      pageSize: json['page_size'],
      posts: (json['posts'] as List)
          .map((post) => DisplayPost.fromJson(post))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountID,
      'page': page,
      'page_size': pageSize,
      'posts': posts?.map((post) => post.toJson()).toList(),
    };
  }
}

class CheckExistingFriendRequestRequest {
  final int fromAccountID;
  final int toAccountID;

  CheckExistingFriendRequestRequest({
    required this.fromAccountID,
    required this.toAccountID,
  });

  factory CheckExistingFriendRequestRequest.fromJson(
      Map<String, dynamic> json) {
    return CheckExistingFriendRequestRequest(
      fromAccountID: json['from_account_id'],
      toAccountID: json['to_account_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from_account_id': fromAccountID,
      'to_account_id': toAccountID,
    };
  }
}

class CheckExistingFriendRequestResponse {
  bool? isExisting;
  int? requestID;

  CheckExistingFriendRequestResponse({
    this.isExisting,
    required this.requestID,
  });

  factory CheckExistingFriendRequestResponse.fromJson(
      Map<String, dynamic> json) {
    return CheckExistingFriendRequestResponse(
      isExisting: json['is_existing'] ?? false,
      requestID: json['request_id'] == 0 ? null : json['request_id'],
    );
  }
}

class RegisterDevice {
  final int userID;
  final String token;

  RegisterDevice({
    required this.userID,
    required this.token,
  });

  factory RegisterDevice.fromJson(Map<String, dynamic> json) {
    return RegisterDevice(
      userID: json['user_id'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userID,
      'token': token,
    };
  }
}

class RegisterDeviceResponse {
  final bool? success;

  RegisterDeviceResponse({
    required this.success,
  });

  factory RegisterDeviceResponse.fromJson(Map<String, dynamic> json) {
    return RegisterDeviceResponse(
      success: json['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
    };
  }
}

class ChangeAvatarRequest {
  final int accountID;
  final String avatar;

  ChangeAvatarRequest({
    required this.accountID,
    required this.avatar,
  });

  factory ChangeAvatarRequest.fromJson(Map<String, dynamic> json) {
    return ChangeAvatarRequest(
      accountID: json['account_id'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountID,
      'avatar': avatar,
    };
  }
}

class ChangeAvatarResponse {
  final bool? success;

  ChangeAvatarResponse({
    required this.success,
  });

  factory ChangeAvatarResponse.fromJson(Map<String, dynamic> json) {
    return ChangeAvatarResponse(
      success: json['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
    };
  }
}

class ChangeAccountInfoRequest {
  final int accountID;
  final String data;
  final String dataFieldName;

  ChangeAccountInfoRequest({
    required this.accountID,
    required this.data,
    required this.dataFieldName,
  });

  factory ChangeAccountInfoRequest.fromJson(Map<String, dynamic> json) {
    return ChangeAccountInfoRequest(
      accountID: json['account_id'],
      data: json['data'],
      dataFieldName: json['data_field_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountID,
      'data': data,
      'data_field_name': dataFieldName,
    };
  }
}

class ChangeAccountInfoResponse {
  final bool? success;

  ChangeAccountInfoResponse({
    required this.success,
  });

  factory ChangeAccountInfoResponse.fromJson(Map<String, dynamic> json) {
    return ChangeAccountInfoResponse(
      success: json['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
    };
  }
}

class SetPrivacyRequest {
  final int accountID;
  final int privacyIndex;
  final String privacyStatus;

  SetPrivacyRequest({
    required this.accountID,
    required this.privacyIndex,
    required this.privacyStatus,
  });

  factory SetPrivacyRequest.fromJson(Map<String, dynamic> json) {
    return SetPrivacyRequest(
      accountID: json['account_id'],
      privacyIndex: json['privacy_index'],
      privacyStatus: json['privacy_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountID,
      'privacy_index': privacyIndex,
      'privacy_status': privacyStatus,
    };
  }
}

class SetPrivacyResponse {
  final bool? success;

  SetPrivacyResponse({
    required this.success,
  });

  factory SetPrivacyResponse.fromJson(Map<String, dynamic> json) {
    return SetPrivacyResponse(
      success: json['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
    };
  }
}

class GetNotificationRequest {
  final int accountID;
  final int page;
  final int pageSize;

  GetNotificationRequest(
      {required this.accountID, required this.page, required this.pageSize});

  factory GetNotificationRequest.fromJson(Map<String, dynamic> json) {
    return GetNotificationRequest(
        accountID: json['account_id'],
        page: json['page'],
        pageSize: json['page_size']);
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountID,
      'page': page,
      'page_size': pageSize,
    };
  }
}

class GetNotificationResponse {
  final int accountID;
  final int page;
  final int pageSize;
  final List<NotificationContent>? notifications;

  GetNotificationResponse({
    required this.accountID,
    required this.page,
    required this.pageSize,
    this.notifications,
  });

  factory GetNotificationResponse.fromJson(Map<String, dynamic> json) {
    return GetNotificationResponse(
      accountID: json['account_id'],
      page: json['page'],
      pageSize: json['page_size'],
      notifications: (json['notifications'] as List<dynamic>?)
          ?.map((notification) => NotificationContent.fromJson(
              notification as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountID,
      'page': page,
      'page_size': pageSize,
      'notifications':
          notifications!.map((notification) => notification.toJson()).toList(),
    };
  }
}

class NotificationContent {
  final int id;
  final String content;
  final int dateTime;
  final bool? isRead;

  NotificationContent({
    required this.id,
    required this.content,
    required this.dateTime,
    this.isRead,
  });

  factory NotificationContent.fromJson(Map<String, dynamic> json) {
    return NotificationContent(
      id: json['id'],
      content: json['content'],
      dateTime: json['date_time'],
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'date_time': dateTime,
    };
  }
}

class LoginWithGoogleRequest {
  final String displayName;
  final String authToken;
  final String email;
  final String photoURL;

  LoginWithGoogleRequest(
      {required this.displayName,
      required this.email,
      required this.authToken,
      required this.photoURL});

  Map<String, dynamic> toJson() {
    return {
      "display_name": displayName,
      "auth_token": authToken,
      "photo_url": photoURL,
      "email": email
    };
  }
}

class VerifyUsernameAndEmailRequest {
  final String username;
  final String email;

  VerifyUsernameAndEmailRequest({required this.username, required this.email});

  Map<String, dynamic> toJson() {
    return {"username": username, "email": email};
  }
}

class VerifyUsernameAndEmailResponse {
  bool? success = false;
  final int userID;

  VerifyUsernameAndEmailResponse({this.success, required this.userID});

  factory VerifyUsernameAndEmailResponse.fromJson(Map<String, dynamic> json) {
    return VerifyUsernameAndEmailResponse(
        success: json['success'] ?? false, userID: json['user_id']);
  }
}

class SendOTPForgetPasswordMessageRequest {
  final int accountID;
  final String email;

  SendOTPForgetPasswordMessageRequest(
      {required this.accountID, required this.email});

  Map<String, dynamic> toJson() {
    return {"account_id": accountID, "email": email};
  }
}

class SendOTPForgetPasswordMessageResponse {
  bool? success;

  SendOTPForgetPasswordMessageResponse({this.success});

  factory SendOTPForgetPasswordMessageResponse.fromJson(
      Map<String, dynamic> json) {
    return SendOTPForgetPasswordMessageResponse(
        success: json['success'] ?? false);
  }
}

class CheckValidOTPRequest {
  final int accountID;
  final int otp;

  CheckValidOTPRequest({required this.accountID, required this.otp});

  Map<String, dynamic> toJson() {
    return {"account_id": accountID, "otp": otp};
  }
}

class CheckValidOTPResponse {
  bool? success;
  int? attempts;

  CheckValidOTPResponse({this.success, this.attempts});

  factory CheckValidOTPResponse.fromJson(Map<String, dynamic> json) {
    return CheckValidOTPResponse(
        success: json['success'] ?? false, attempts: json['attempts'] ?? 0);
  }
}

class ChangePasswordRequest {
  final int accountID;
  final String newPassword;

  ChangePasswordRequest({required this.accountID, required this.newPassword});

  Map<String, dynamic> toJson() {
    return {"account_id": accountID, "new_password": newPassword};
  }
}

class ChangePasswordResponse {
  bool? success;

  ChangePasswordResponse({this.success});

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponse(success: json['success'] ?? false);
  }
}

class ResolveFriendFollowRequest {
  final String fromAccountID;
  final String toAccountID;
  final String action;

  ResolveFriendFollowRequest(
      {required this.fromAccountID,
      required this.toAccountID,
      required this.action});

  Map<String, dynamic> toJson() {
    return {
      "from_account_id": fromAccountID,
      "to_account_id": toAccountID,
      "action": action
    };
  }
}

class ResolveFriendFollowResponse {
  bool? success;

  ResolveFriendFollowResponse({this.success});

  factory ResolveFriendFollowResponse.fromJson(Map<String, dynamic> json) {
    return ResolveFriendFollowResponse(success: json['success'] ?? false);
  }
}

class ResolveFriendBlockRequest {
  final int fromAccountID;
  final int toAccountID;
  final String action;

  ResolveFriendBlockRequest(
      {required this.fromAccountID,
      required this.toAccountID,
      required this.action});

  Map<String, dynamic> toJson() {
    return {
      "from_account_id": fromAccountID,
      "to_account_id": toAccountID,
      "action": action
    };
  }
}

class ResolveFriendBlockResponse {
  bool? success;

  ResolveFriendBlockResponse({this.success});

  factory ResolveFriendBlockResponse.fromJson(Map<String, dynamic> json) {
    return ResolveFriendBlockResponse(success: json['success'] ?? false);
  }
}

class CheckIsFollowRequest {
  final int fromAccountID;
  final int toAccountID;

  CheckIsFollowRequest(
      {required this.fromAccountID, required this.toAccountID});

  Map<String, dynamic> toJson() {
    return {
      "from_account_id": fromAccountID,
      "to_account_id": toAccountID,
    };
  }
}

class CheckIsFollowResponse {
  bool? isFollow;

  CheckIsFollowResponse({this.isFollow});

  factory CheckIsFollowResponse.fromJson(Map<String, dynamic> json) {
    return CheckIsFollowResponse(isFollow: json['is_follow'] ?? false);
  }
}

class CheckIsBlockRequest {
  final int fromAccountID;
  final int toAccountID;

  CheckIsBlockRequest({required this.fromAccountID, required this.toAccountID});

  Map<String, dynamic> toJson() {
    return {
      "from_account_id": fromAccountID,
      "to_account_id": toAccountID,
    };
  }
}

class CheckIsBlockResponse {
  bool? isBlock;

  CheckIsBlockResponse({this.isBlock});

  factory CheckIsBlockResponse.fromJson(Map<String, dynamic> json) {
    return CheckIsBlockResponse(isBlock: json['is_block'] ?? false);
  }
}

class MarkAsReadNotificationRequest {
  final int accountID;

  MarkAsReadNotificationRequest({required this.accountID});

  Map<String, dynamic> toJson() {
    return {
      "account_id": accountID,
    };
  }
}

class MarkAsReadNotificationResponse {
  final bool? success;
  final int? quantity;

  MarkAsReadNotificationResponse({this.success, this.quantity});

  factory MarkAsReadNotificationResponse.fromJson(Map<String, dynamic> json) {
    return MarkAsReadNotificationResponse(
        success: json['success'] ?? false, quantity: json['quantity'] ?? 0);
  }
}

class CountUnreadNotiRequest {
  final int accountID;

  CountUnreadNotiRequest({required this.accountID});

  Map<String, dynamic> toJson() {
    return {
      "account_id": accountID,
    };
  }
}

class CountUnreadNotiResponse {
  final int? quantity;

  CountUnreadNotiResponse({this.quantity});

  factory CountUnreadNotiResponse.fromJson(Map<String, dynamic> json) {
    return CountUnreadNotiResponse(quantity: json['quantity'] ?? 0);
  }
}

class ChatMessage {
  final int senderID;
  final int receiverID;
  final String content;
  final int timestamp;

  ChatMessage(
      {required this.senderID,
      required this.receiverID,
      required this.content,
      required this.timestamp});

  Map<String, dynamic> toJson() {
    return {
      "sender_id": senderID,
      "receiver_id": receiverID,
      "content": content,
      "timestamp": timestamp
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
        senderID: json['sender_id'],
        receiverID: json['receiver_id'],
        content: json['content'],
        timestamp: json['timestamp']);
  }
}

class GetChatListRequest {
  final int accountID;
  final int page;
  int pageSize = 10;

  GetChatListRequest(
      {required this.accountID, required this.page, required this.pageSize});

  Map<String, dynamic> toJson() {
    return {"account_id": accountID, "page": page, "page_size": pageSize};
  }
}

class ChatList {
  final int accountID;
  final int targetAccountID;
  final String displayName;
  final String avatarURL;
  final int lastMessageTimestamp;
  final String lastMessageContent;
  final int unreadMessageQuantity;
  final int page;
  final int pageSize;
  final String chatId;

  ChatList({
    required this.accountID,
    required this.targetAccountID,
    required this.displayName,
    required this.avatarURL,
    required this.lastMessageTimestamp,
    required this.lastMessageContent,
    required this.unreadMessageQuantity,
    required this.page,
    required this.pageSize,
    required this.chatId,
  });

  factory ChatList.fromJson(Map<String, dynamic> json) {
    return ChatList(
      accountID: json['account_id'],
      targetAccountID: json['target_account_id'],
      displayName: json['display_name'],
      avatarURL: json['avatar_url'],
      lastMessageTimestamp: json['last_message_timestamp'],
      lastMessageContent: json['last_message_content'],
      unreadMessageQuantity: json['unread_message_quantity'],
      page: json['page'],
      pageSize: json['page_size'],
      chatId: json['chat_id'],
    );
  }

  static List<ChatList> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ChatList.fromJson(json)).toList();
  }
}

class GetMessageHistoryRequest {
  final String chatId;
  final int page;
  final int pageSize;
  final int requestAccountID;

  GetMessageHistoryRequest(
      {required this.chatId,
      required this.page,
      required this.pageSize,
      required this.requestAccountID});

  Map<String, dynamic> toJson() {
    return {
      "chat_id": chatId,
      "page": page,
      "page_size": pageSize,
      "request_account_id": requestAccountID
    };
  }
}

class GetMessageHistoryResponse {
  final String chatId;
  final List<MessageData>? messages;
  final SingleAccountInfo partnerDisplayInfo;
  final int page;
  final int pageSize;

  GetMessageHistoryResponse(
      {required this.chatId,
      this.messages,
      required this.partnerDisplayInfo,
      required this.page,
      required this.pageSize});

  factory GetMessageHistoryResponse.fromJson(Map<String, dynamic> json) {
    return GetMessageHistoryResponse(
      chatId: json['chat_id'],
      messages: (json['messages'] as List)
          .map((message) => MessageData.fromJson(message))
          .toList(),
      partnerDisplayInfo:
          SingleAccountInfo.fromJson(json['partner_display_info']),
      page: json['page'],
      pageSize: json['page_size'],
    );
  }
}

class MessageData {
  String? id;
  String? chatId;
  int senderID;
  int receiverID;
  String content;
  String? type;
  int timestamp;
  int? createdAt;
  int? updatedAt;
  bool? isDeleted;
  bool? isRecalled;
  bool? isRead;

  MessageData({
    this.id,
    this.chatId,
    required this.senderID,
    required this.receiverID,
    required this.content,
    this.type,
    required this.timestamp,
    this.createdAt,
    this.updatedAt,
    this.isDeleted,
    this.isRecalled,
    this.isRead,
  });

  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      id: json['id'],
      chatId: json['chat_id'],
      senderID: json['sender_id'],
      receiverID: json['receiver_id'],
      content: json['content'],
      type: json['type'] ?? "text",
      timestamp: json['timestamp'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isDeleted: json['is_deleted'] ?? false,
      isRecalled: json['is_recalled'] ?? false,
      isRead: json['is_read'] ?? false,
    );
  }
}

class ActionMessageRequest {
  final int senderID;
  final int receiverID;
  final int timestamp;
  final String action;

  ActionMessageRequest(
      {required this.senderID,
      required this.receiverID,
      required this.timestamp,
      required this.action});

  Map<String, dynamic> toJson() {
    return {
      "sender_id": senderID,
      "receiver_id": receiverID,
      "timestamp": timestamp,
      "action": action
    };
  }
}

class ActionMessageResponse {
  bool? success;

  ActionMessageResponse({this.success});

  factory ActionMessageResponse.fromJson(Map<String, dynamic> json) {
    return ActionMessageResponse(success: json['success'] ?? false);
  }
}

class ReceiverMarkMessageAsRead {
  final int accountID;
  final String chatID;

  ReceiverMarkMessageAsRead({required this.accountID, required this.chatID});

  Map<String, dynamic> toJson() {
    return {"account_id": accountID, "chat_id": chatID};
  }
}

class ReceiverMarkMessageAsReadResponse {
  bool? success;

  ReceiverMarkMessageAsReadResponse({this.success});

  factory ReceiverMarkMessageAsReadResponse.fromJson(
      Map<String, dynamic> json) {
    return ReceiverMarkMessageAsReadResponse(success: json['success'] ?? false);
  }
}

class ReportPost {
  final int postId;
  final int reportedBy;
  final String reason;

  ReportPost(
      {required this.postId, required this.reportedBy, required this.reason});

  Map<String, dynamic> toJson() {
    return {"post_id": postId, "reported_by": reportedBy, "reason": reason};
  }
}

class ReportAccount {
  final int accountId;
  final int reportedBy;
  final String reason;

  ReportAccount(
      {required this.accountId,
      required this.reportedBy,
      required this.reason});

  Map<String, dynamic> toJson() {
    return {
      "account_id": accountId,
      "reported_by": reportedBy,
      "reason": reason
    };
  }
}

class ReportResponse {
  final bool? success;

  ReportResponse({this.success});

  factory ReportResponse.fromJson(Map<String, dynamic> json) {
    return ReportResponse(success: json['success'] ?? false);
  }
}

class SearchAccountRequest {
  final int requestAccountId;
  final String queryString;
  final int page;
  final int pageSize;

  SearchAccountRequest(
      {required this.requestAccountId,
      required this.queryString,
      required this.page,
      required this.pageSize});

  Map<String, dynamic> toJson() {
    return {
      "request_account_id": requestAccountId,
      "query_string": queryString,
      "page": page,
      "page_size": pageSize
    };
  }
}

class SearchAccountResponse {
  final List<SingleAccountInfo>? accounts;
  final int page;
  final int pageSize;

  SearchAccountResponse(
      {required this.accounts, required this.page, required this.pageSize});

  factory SearchAccountResponse.fromJson(Map<String, dynamic> json) {
    return SearchAccountResponse(
      page: json['page'],
      pageSize: json['page_size'],
      accounts: json['accounts'] != null
          ? (json['accounts'] as List)
              .map((account) => SingleAccountInfo.fromJson(account))
              .toList()
          : [],
    );
  }
}
