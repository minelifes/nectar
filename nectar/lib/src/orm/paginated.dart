class Paginated {
  final int allPages;
  final int page;
  final int perPage;
  final int count;
  final List<dynamic> items;

  Paginated({
    required this.allPages,
    required this.page,
    required this.count,
    required this.items,
    required this.perPage,
  });

  Map<String, dynamic> toJson() => {
        "allPages": allPages,
        "page": page,
        "count": count,
        "perPage": perPage,
        "items": items.map((e) => e.toJson()).toList(),
      };
}
