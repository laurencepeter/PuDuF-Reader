class PdfDocument {
  final String path;
  final String name;
  final int lastPage;
  final int totalPages;
  final DateTime lastOpened;
  final List<int> bookmarks;

  const PdfDocument({
    required this.path,
    required this.name,
    this.lastPage = 1,
    this.totalPages = 0,
    required this.lastOpened,
    this.bookmarks = const [],
  });

  PdfDocument copyWith({
    String? path,
    String? name,
    int? lastPage,
    int? totalPages,
    DateTime? lastOpened,
    List<int>? bookmarks,
  }) {
    return PdfDocument(
      path: path ?? this.path,
      name: name ?? this.name,
      lastPage: lastPage ?? this.lastPage,
      totalPages: totalPages ?? this.totalPages,
      lastOpened: lastOpened ?? this.lastOpened,
      bookmarks: bookmarks ?? this.bookmarks,
    );
  }

  Map<String, dynamic> toJson() => {
        'path': path,
        'name': name,
        'lastPage': lastPage,
        'totalPages': totalPages,
        'lastOpened': lastOpened.millisecondsSinceEpoch,
        'bookmarks': bookmarks,
      };

  factory PdfDocument.fromJson(Map<String, dynamic> json) {
    return PdfDocument(
      path: json['path'] as String,
      name: json['name'] as String,
      lastPage: json['lastPage'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 0,
      lastOpened: DateTime.fromMillisecondsSinceEpoch(
          json['lastOpened'] as int),
      bookmarks:
          (json['bookmarks'] as List<dynamic>?)?.cast<int>() ?? [],
    );
  }

  double get readingProgress =>
      totalPages > 0 ? lastPage / totalPages : 0.0;

  String get displayName {
    final withoutExt = name.endsWith('.pdf')
        ? name.substring(0, name.length - 4)
        : name;
    return withoutExt.replaceAll('_', ' ').replaceAll('-', ' ');
  }
}
