/// Represents a single rewards transaction (earn or redeem).
class RewardsTransaction {
  final String id;
  final String description;
  final int points;
  final bool isEarned;
  final DateTime createdAt;

  const RewardsTransaction({
    required this.id,
    required this.description,
    required this.points,
    required this.isEarned,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'points': points,
        'type': isEarned ? 'earned' : 'redeemed',
        'createdAt': createdAt.toIso8601String(),
      };

  factory RewardsTransaction.fromJson(Map<String, dynamic> json) =>
      RewardsTransaction(
        id: json['id'] as String,
        description: json['description'] as String,
        points: (json['points'] as num).toInt(),
        isEarned: json['type'] == 'earned',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
