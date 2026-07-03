class LivestreamHistory {
  bool? status;
  List<HistoryItem>? history;

  LivestreamHistory({this.status, this.history});

  factory LivestreamHistory.fromJson(Map<String, dynamic> json) {
    return LivestreamHistory(
      status: json['status'],
      history:
          json['history'] != null ? List<HistoryItem>.from(json['history'].map((x) => HistoryItem.fromJson(x))) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'history': history?.map((x) => x.toJson()).toList(),
      };
}

class HistoryItem {
  int? id;
  int? userId;
  String? video;
  String? createdAt;
  String? updatedAt;

  HistoryItem({this.id, this.userId, this.video, this.createdAt, this.updatedAt});

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'],
      userId: json['user_id'],
      video: json['video'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'video': video,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
