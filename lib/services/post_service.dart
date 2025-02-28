import "package:syncio_capstone/networking/dio/dio_client.dart";
import "package:syncio_capstone/networking/dio/api_endpoints.dart";
import 'package:dio/dio.dart';
import "package:syncio_capstone/services/types.dart";

class PostService {
  final Dio _dio = DioClient().dio;

  Future<CreatePostResponse> createPost(FormData formData) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createPost,
        data: formData,
      );
      return CreatePostResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<GetWallPostListResponse> getWallPostList(
      GetWallPostListRequest request) async {
    try {
      final response = await _dio.post(ApiEndpoints.getWallList, data: request);
      return GetWallPostListResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<GetPostCommentsResponse> getPostComment(
      GetPostCommentRequest request) async {
    try {
      final response =
          await _dio.post(ApiEndpoints.getPostComment, data: request);
      return GetPostCommentsResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<ReactPostResponse> reactPost(ReactPostRequest request) async {
    try {
      final response = await _dio.post(ApiEndpoints.reactPost, data: request);
      return ReactPostResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<RemoveReactPostResponse> removeReactPost(
      RemoveReactPostRequest request) async {
    try {
      final response =
          await _dio.delete(ApiEndpoints.removeReactPost, data: request);
      return RemoveReactPostResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<CommentPostResponse> commentPost(CommentPostRequest request) async {
    try {
      final response = await _dio.post(ApiEndpoints.commentPost, data: request);
      return CommentPostResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<ReplyCommentResponse> replyComment(ReplyCommentRequest request) async {
    try {
      final response =
          await _dio.post(ApiEndpoints.replyComment, data: request);
      return ReplyCommentResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<SharePostResponse> sharePost(SharePostRequest request) async {
    try {
      final response = await _dio.post(ApiEndpoints.sharePost, data: request);
      return SharePostResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<GetNewsFeedResponse> getNewsFeed(GetNewsFeedRequest request) async {
    try {
      final response =
          await _dio.post(ApiEndpoints.getNewsFeed, data: request.toJson());
      return GetNewsFeedResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<DeletePostResponse> deletePost(DeletePostRequest request) async {
    try {
      final response =
          await _dio.delete(ApiEndpoints.deletePost, data: request);
      return DeletePostResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }
}
