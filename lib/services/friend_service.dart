import "package:syncio_capstone/networking/dio/dio_client.dart";
import "package:syncio_capstone/networking/dio/api_endpoints.dart";
import 'package:dio/dio.dart';
import "package:syncio_capstone/services/types.dart";

class FriendService {
  final Dio _dio = DioClient().dio;

  Future<GetPendingListResponse> getPendingList(
      GetPendingListRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.getPendingList,
        data: request.toJson(),
      );
      return GetPendingListResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<CountFriendPendingResponse> countFriendPending(
      CountFriendPendingRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.countFriendPending,
        data: request.toJson(),
      );
      return CountFriendPendingResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<ResolveFriendResponse> resolveFriendRequest(
      ResolveFriendRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.resolveFriendRequest,
        data: request.toJson(),
      );
      return ResolveFriendResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<DisplayListFriendResponse> getListFriend(
      GetDislayListFriend request) async {
    try {
      final response =
          await _dio.post(ApiEndpoints.getListFriend, data: request.toJson());
      return DisplayListFriendResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<SendFriendResponse> sendFriendRequest(
      SendFriendRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.sendFriendRequest,
        data: request.toJson(),
      );
      return SendFriendResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<RecallResponse> recallFriendRequest(RecallRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.recallFriendRequest,
        data: request.toJson(),
      );
      return RecallResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<CheckExistingFriendRequestResponse> checkExistingFriendRequest(
      CheckExistingFriendRequestRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.checkExistingFriendRequest,
        data: request.toJson(),
      );
      return CheckExistingFriendRequestResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<UnfriendResponse> unFriend(UnfriendRequest request) async {
    try {
      final response =
          await _dio.post(ApiEndpoints.unFriend, data: request.toJson());
      return UnfriendResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<ResolveFriendFollowResponse> resolveFriendFollow(
      ResolveFriendFollowRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.resolveFriendFollow,
        data: request.toJson(),
      );
      return ResolveFriendFollowResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<BlockResponse> resolveFriendBlock(BlockRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.resolveFriendBlock,
        data: request.toJson(),
      );
      return BlockResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<CheckIsFollowResponse> checkIsFollow(
      CheckIsFollowRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.checkIsFollow,
        data: request.toJson(),
      );
      return CheckIsFollowResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<CheckIsBlockResponse> checkIsBlock(CheckIsBlockRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.checkIsBlock,
        data: request.toJson(),
      );
      return CheckIsBlockResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<GetBlockListInfoResponse> getBlockListInfo(
      GetBlockListInfoRequest request) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getListBlockInfo,
        data: request.toJson(),
      );
      return GetBlockListInfoResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }
}
