class InterestSelectionModel {
  final String id;
  final String userId;
  final String interestId;

  InterestSelectionModel({
    required this.id,
    required this.userId,
    required this.interestId,
  });

  factory InterestSelectionModel.fromJson(Map<String, dynamic> map) {
    return InterestSelectionModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      interestId: map['interest_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'interest_id': interestId,
    };
  }
}
