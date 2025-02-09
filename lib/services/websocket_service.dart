import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:syncio_capstone/networking/networking_config.dart';
import 'package:syncio_capstone/services/types.dart';
import 'package:syncio_capstone/utils/helpers.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  WebSocketChannel? _channel;
  final String url =
      'ws://${NetworkingConfig.baseUrl}:${NetworkingConfig.port}/ws';

  final BehaviorSubject<ChatMessage> _messageSubject = BehaviorSubject();

  Stream<ChatMessage> get messageStream => _messageSubject.stream;

  factory WebSocketService() {
    return _instance;
  }

  WebSocketService._internal();

  void connect() async {
    if (_channel != null) {
      debugPrint("WebSocket already connected");
      return;
    }

    final int? userID = await Helpers().getUserId();
    if (userID == null) return;

    try {
      _channel = IOWebSocketChannel.connect('$url?user_id=$userID');
      debugPrint("WebSocket URL: $url?user_id=$userID");

      _channel!.stream.listen(
        (message) {
          debugPrint("Received: $message");
          try {
            final Map<String, dynamic> decodedMessage = jsonDecode(message);
            final chatMessage = ChatMessage.fromJson(decodedMessage);
            if (_messageSubject.isClosed) {
              debugPrint("WebSocket Stream is closed");
            } else {
              debugPrint("Adding message to stream: $decodedMessage");
              _messageSubject.add(chatMessage);
            }
          } catch (e) {
            debugPrint("Error decoding message: $e");
          }
        },
        onDone: () => handleReconnect(),
        onError: (err) => handleReconnect(),
      );
    } catch (e) {
      debugPrint("Error connecting to WebSocket: $e");
      Future.delayed(const Duration(seconds: 2), connect);
    }
  }

  void sendMessage(ChatMessage message) {
    if (_channel != null) {
      final encodedMessage = jsonEncode(message.toJson());
      debugPrint("Sending message: $encodedMessage");
      _channel!.sink.add(encodedMessage);
    } else {
      debugPrint("WebSocket is not connected. Message not sent.");
    }
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
  }

  void handleReconnect() {
    debugPrint("WebSocket disconnected, attempting reconnect...");
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
    Future.delayed(const Duration(seconds: 2), () {
      if (_channel == null) {
        connect();
      }
    });
  }
}
