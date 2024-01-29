class Paginated {
  final int allPages;
  final int itemsCount;
  final int page;
  final int count;
  final List<dynamic> items;

  Paginated({
    required this.allPages,
    required this.itemsCount,
    required this.page,
    required this.count,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        "allPages": allPages,
        "itemsCount": itemsCount,
        "page": page,
        "count": count,
        "items": items.map((e) => e.toJson()).toList(),
      };
}
