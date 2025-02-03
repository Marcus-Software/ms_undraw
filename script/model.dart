part of 'update_illustrations.dart';

class Illustration {
  Illustration({
    this.illustrations,
    this.hasMore,
    this.nextPage,
  });

  List<IllustrationElement>? illustrations;
  bool? hasMore;
  int? nextPage;

  Illustration copyWith({
    List<IllustrationElement>? illustrations,
    bool? hasMore,
    int? nextPage,
  }) =>
      Illustration(
        illustrations: illustrations ?? this.illustrations,
        hasMore: hasMore ?? this.hasMore,
        nextPage: nextPage ?? this.nextPage,
      );

  factory Illustration.fromMap(Map<String, dynamic> json) {
    final totalPages = json["pageProps"]["totalPages"];
    final currentPage = json["pageProps"]["currentPage"] ?? 1;

    return Illustration(
      illustrations: json["pageProps"] == null
          ? null
          : List<IllustrationElement>.from(json["pageProps"]["illustrations"]
              .map((x) => IllustrationElement.fromMap(x))),
      hasMore: totalPages > currentPage,
      nextPage: currentPage + 1,
    );
  }
}

class IllustrationElement {
  IllustrationElement({
    required this.id,
    required this.title,
    required this.image,
    required this.slug,
  });

  String id;
  String title;
  String image;
  String slug;

  IllustrationElement copyWith({
    String? id,
    String? title,
    String? image,
    String? slug,
  }) =>
      IllustrationElement(
        id: id ?? this.id,
        title: title ?? this.title,
        image: image ?? this.image,
        slug: slug ?? this.slug,
      );

  factory IllustrationElement.fromJson(String str) =>
      IllustrationElement.fromMap(json.decode(str));

  factory IllustrationElement.fromMap(Map<String, dynamic> json) =>
      IllustrationElement(
        id: json["_id"],
        title: json["title"],
        image: json["image"] ?? json["media"],
        slug: json["slug"] ?? json["newSlug"],
      );
}
