class MapUtils {
  static void _loopPrintMap(Map<dynamic, dynamic> data, {int itter = 1}) {
    int it = itter;
    final spaces = List.generate(it, (e) => "").join(" ");
    for (var key in data.keys) {
      if (data[key] is Map) {
        print("$spaces$key:{");
        _loopPrintMap(data[key], itter: it + 1);
        print("$spaces}");
      } else {
        print("$spaces$key:${data[key]}");
      }
    }
  }

  static void printMap(Map<dynamic, dynamic> data) {
    print("{");
    _loopPrintMap(data, itter: 2);
    print("}");
  }
}
