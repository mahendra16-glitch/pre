import 'dart:convert';

import 'package:mygenie_restaurant/data/model/response/conversation_model.dart';

class MessageModel {
  int? totalSize;
  int? limit;
  int? offset;
  bool? status;
  Conversation? conversation;
  List<Message>? messages;

  MessageModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.messages,
    this.status,
    this.conversation,
  });

  MessageModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'] as int?;
    limit = json['limit'] as int?;
    offset = json['offset'] as int?;
    status = json['status'] as bool?;
    conversation = json['conversation'] != null
        ? Conversation.fromJson(json['conversation'])
        : null;
    if (json['messages'] != null) {
      messages = <Message>[];
      for (var v in json['messages']) {
        messages!.add(Message.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    data['status'] = status;
    if (conversation != null) {
      data['conversation'] = conversation!.toJson();
    }
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Message {
  int? id;
  int? conversationId;
  int? senderId;
  String? message;
  List<String>? files;
  int? isSeen;
  String? createdAt;
  String? updatedAt;

  Message({
    this.id,
    this.conversationId,
    this.senderId,
    this.message,
    this.files,
    this.isSeen,
    this.createdAt,
    this.updatedAt,
  });

  Message.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    conversationId = json['conversation_id'] as int?;
    senderId = json['sender_id'] as int?;
    message = json['message'] as String?;
    if (json['file'] != null && json['file'] != 'null') {
      files = List<String>.from(jsonDecode(json['file']));
    }
    isSeen = json['is_seen'] as int?;
    createdAt = json['created_at'] as String?;
    updatedAt = json['updated_at'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['conversation_id'] = conversationId;
    data['sender_id'] = senderId;
    data['message'] = message;
    data['file'] = files;
    data['is_seen'] = isSeen;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
