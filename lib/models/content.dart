
enum ContentType { question, alert, listing, task, story, service }

class FeedItem {
  final String id;
  final ContentType type;
  final String title;
  final String body;
  final String space;
  final String neighborhood;
  final int trustScore; // 0-100
  final bool isVerified;
  final bool scamFlagged;
  final String? scamReason;

  const FeedItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.space,
    required this.neighborhood,
    this.trustScore = 62,
    this.isVerified = false,
    this.scamFlagged = false,
    this.scamReason,
  });
}
