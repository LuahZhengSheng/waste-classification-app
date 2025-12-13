/// Post type enumeration
enum PostType {
  tip('Tip', 'tip'),
  question('Question', 'question'),
  discussion('Discussion', 'discussion');

  final String displayName;
  final String value;

  const PostType(this.displayName, this.value);

  static PostType fromString(String value) {
    return PostType.values.firstWhere(
          (type) => type.value.toLowerCase() == value.toLowerCase(),
      orElse: () => PostType.tip,
    );
  }
}

/// Media type enumeration
enum MediaType {
  image,
  video
}

/// Comment sort type enumeration
enum CommentSortType {
  topComments('Top comments'),
  newestFirst('Newest first');

  final String displayName;

  const CommentSortType(this.displayName);
}

/// Time filter enumeration
enum TimeFilter {
  allTime('All Time'),
  today('Today'),
  thisWeek('This Week'),
  thisMonth('This Month'),
  thisYear('This Year');

  final String displayName;

  const TimeFilter(this.displayName);
}

/// Report options enumeration
enum ReportOption {
  spam('Spam', 'Irrelevant or repetitive content'),
  harassment('Harassment', 'Bullying or threatening behavior'),
  hateSpeech('Hate Speech', 'Discriminatory or offensive content'),
  falseInformation('False Information', 'Misleading or fake content'),
  inappropriateContent('Inappropriate Content', 'Offensive or explicit material'),
  violence('Violence', 'Violent or graphic content'),
  other('Other', 'Other concerns');

  final String displayName;
  final String description;

  const ReportOption(this.displayName, this.description);

  /// Get report option from string value
  static ReportOption? fromString(String value) {
    try {
      return ReportOption.values.firstWhere(
            (option) => option.name == value,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get all report option names as list
  static List<String> get allOptionNames {
    return ReportOption.values.map((option) => option.name).toList();
  }
}