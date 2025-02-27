import "package:syncio_capstone/networking/dio/dio_client.dart";
import "package:syncio_capstone/networking/dio/api_endpoints.dart";
import 'package:dio/dio.dart';
import "package:syncio_capstone/services/types.dart";

class MessageService {
  final Dio _dio = DioClient().dio;

  Future<List<ChatList>?> getChatList(GetChatListRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.getChatList,
        data: request.toJson(),
      );
      return ChatList.fromJsonList(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<GetMessageHistoryResponse> getMessageHistory(
      GetMessageHistoryRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.getChatMessages,
        data: request.toJson(),
      );
      return GetMessageHistoryResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<ActionMessageResponse> actionMessage(
      ActionMessageRequest request) async {
    try {
      final response = await _dio.patch(
        ApiEndpoints.actionMessage,
        data: request.toJson(),
      );
      return ActionMessageResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<ReceiverMarkMessageAsReadResponse> receiverMarkMessageAsRead(
      ReceiverMarkMessageAsRead request) async {
    try {
      final response = await _dio.patch(
        ApiEndpoints.receiverMarkMessageAsRead,
        data: request.toJson(),
      );
      return ReceiverMarkMessageAsReadResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<CreateNewChatResponse> createNewChat(
      CreateNewChatRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createChat,
        data: request.toJson(),
      );
      return CreateNewChatResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<DeleteChatResponse> deleteChat(DeleteChatRequest request) async {
    try {
      final response = await _dio.delete(
        ApiEndpoints.deleteChat,
        data: request.toJson(),
      );
      return DeleteChatResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }
}
