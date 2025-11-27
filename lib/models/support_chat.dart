class SupportChatRequest {
  final String message;
  final String language;

  SupportChatRequest({required this.message, required this.language});

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'language': language,
    };
  }
}

class SupportChatResponse {
  final String reply;

  SupportChatResponse({required this.reply});

  factory SupportChatResponse.fromJson(Map<String, dynamic> json) {
    return SupportChatResponse(
      reply: json['reply'] as String,
    );
  }
}