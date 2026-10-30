class CategoryItem {
  final int id;
  final String name;
  final String? icon;
  final String? description;

  CategoryItem({
    required this.id,
    required this.name,
    this.icon,
    this.description,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      icon: json['icon'],
      description: json['description'],
    );
  }
}

class ServiceItem {
  final int id;
  final int categoryId;
  final String title;
  final String? description;
  final double basePrice;
  final int durationMins;
  final double workerCut;
  final double welfareCut;
  final double platformCut;
  final bool isActive;

  ServiceItem({
    required this.id,
    required this.categoryId,
    required this.title,
    this.description,
    required this.basePrice,
    this.durationMins = 60,
    this.workerCut = 85.0,
    this.welfareCut = 10.0,
    this.platformCut = 5.0,
    this.isActive = true,
  });

  // Accurate 2-decimal rounded splits matching server logic
  double get workerPayout => (basePrice * workerCut / 100).roundToDouble();
  double get welfarePayout => (basePrice * welfareCut / 100).roundToDouble();
  double get platformPayout => (basePrice - workerPayout - welfarePayout);

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      categoryId: json['category_id'] is int ? json['category_id'] : int.parse(json['category_id'].toString()),
      title: json['title'] ?? '',
      description: json['description'],
      basePrice: (json['base_price'] != null) ? double.parse(json['base_price'].toString()) : 0.0,
      durationMins: json['duration_mins'] ?? 60,
      workerCut: (json['worker_cut'] != null) ? double.parse(json['worker_cut'].toString()) : 85.0,
      welfareCut: (json['welfare_cut'] != null) ? double.parse(json['welfare_cut'].toString()) : 10.0,
      platformCut: (json['platform_cut'] != null) ? double.parse(json['platform_cut'].toString()) : 5.0,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }
}

