class TestRequest {
  final int? id;
  final String title;

  const TestRequest({this.id, required this.title});

  factory TestRequest.fromJson(Map<String, dynamic> json) =>
      TestRequest(id: json['id'], title: json['title']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
      };
}
