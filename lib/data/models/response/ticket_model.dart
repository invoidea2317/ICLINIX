import 'dart:convert';

import 'package:flutter/cupertino.dart';

class Ticket {
  final int? id;
  final String? ticketNo;
  final int? userId;
  final String? subject;
  final String? status;
  final String? priority;
  final int? typeId;
  final DateTime? closeDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<TicketReply>? ticketToReplies;
  final TicketType? ticketType;

  Ticket({
    this.id,
    this.ticketNo,
    this.userId,
    this.subject,
    this.status,
    this.priority,
    this.typeId,
    this.closeDate,
    this.createdAt,
    this.updatedAt,
    this.ticketToReplies,
    this.ticketType,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      ticketNo: json['ticket_no'],
      userId: json['user_id'],
      subject: json['subject'],
      status: json['status'],
      priority: json['priority'],
      typeId: json['type_id'],
      closeDate: json['close_date'] != null ? DateTime.tryParse(json['close_date']) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      ticketToReplies: (json['ticket_to_replies'] as List<dynamic>?)
          ?.map((e) => TicketReply.fromJson(e))
          .toList(),
      ticketType: json['ticket_type'] != null
          ? TicketType.fromJson(json['ticket_type'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_no': ticketNo,
      'user_id': userId,
      'subject': subject,
      'status': status,
      'priority': priority,
      'type_id': typeId,
      'close_date': closeDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'ticket_type': ticketType?.toJson(),
    };
  }
}

class TicketReply {
  final int? id;
  final int? ticketId;
  final String? replyBy;
  final int? replyByUserId;
  final String? message;
  final List<String>? fileUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  TicketReply({
    this.id,
    this.ticketId,
    this.fileUrl,
    this.replyBy,
    this.replyByUserId,
    this.message,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory TicketReply.fromJson(Map<String, dynamic> json) {
    debugPrint("TicketReply: ${json['created_at']}");
    return TicketReply(
      id: json['id'],
      ticketId: json['ticket_id'],
      replyBy: json['reply_by'],
      replyByUserId: json['reply_by_user_id'],
      message: json['message'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.tryParse(json['deleted_at']) : null,
      fileUrl: (json['file_urls'] as List?)?.map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'reply_by': replyBy,
      'reply_by_user_id': replyByUserId,
      'message': message,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'file_url': fileUrl,
    };
  }
}

class TicketType {
  final int? id;
  final String? type;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TicketType({
    this.id,
    this.type,
    this.createdAt,
    this.updatedAt,
  });

  factory TicketType.fromJson(Map<String, dynamic> json) {
    return TicketType(
      id: json['id'],
      type: json['type'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
class TicketToReply {
  final int id;
  final int ticketId;
  final String replyBy;
  final int replyByUserId;
  final String message;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String fileUrl;

  TicketToReply({
    required this.id,
    required this.ticketId,
    required this.replyBy,
    required this.replyByUserId,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.fileUrl,
  });

  factory TicketToReply.fromJson(Map<String, dynamic> json) {
    return TicketToReply(
      id: json['id'],
      ticketId: json['ticket_id'],
      replyBy: json['reply_by'],
      replyByUserId: json['reply_by_user_id'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      fileUrl: json['file_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'reply_by': replyBy,
      'reply_by_user_id': replyByUserId,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'file_url': fileUrl,
    };
  }
}

