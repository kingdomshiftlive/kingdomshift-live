class GiftAnim {
  final int id;
  final int? coinPrice;
  final String? animationPath; // New field for animation asset or URL

  GiftAnim({required this.id, this.coinPrice, this.animationPath});

  factory GiftAnim.fromJson(Map<String, dynamic> json) {
    return GiftAnim(
      id: json['id'] ?? 0,
      coinPrice: json['coinPrice'],
      animationPath: json['animationPath'], // e.g., "assets/animations/gift_animation.json"
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'coinPrice': coinPrice,
        'animationPath': animationPath,
      };
}
