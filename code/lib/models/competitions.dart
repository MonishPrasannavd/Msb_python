import 'package:json_annotation/json_annotation.dart';
import 'package:msb_app/models/dashboard.dart';


part 'competitions.g.dart';

@JsonSerializable(explicitToJson: true)
class CompetitionsCategories {
  final CompetitionsCategory data;

  CompetitionsCategories({required this.data});

  factory CompetitionsCategories.fromJson(Map<String, dynamic> json) {
    var data = CompetitionsCategory.fromJson(json);
    return CompetitionsCategories(data: data);
  }
}

class CompetitionsCategory {
  final String name;
  final String icon;
  final int isFuture;
  final int id;
  final int type;
  List<FutureCategories>? subcategories;
  final CategoryType categoryType;
  final String iconUrl;

  CompetitionsCategory({
    required this.name,
    required this.icon,
    required this.isFuture,
    required this.id,
    required this.type,
    required this.subcategories,
    required this.categoryType,
    required this.iconUrl,
  });

  factory CompetitionsCategory.fromJson(Map<String, dynamic> json) {
    List<FutureCategories>? subcategoryList;
    if (json['subcategories'] != null) {
      subcategoryList = <FutureCategories>[];
      json['subcategories'].forEach((v) {
        subcategoryList!.add(FutureCategories.fromJson(v));
      });
    }

    return CompetitionsCategory(
      name: json['name'],
      icon: json['icon'],
      isFuture: json['is_future'],
      id: json['id'],
      type: json['type'],
      subcategories: subcategoryList,
      categoryType: CategoryType.fromJson(json['category_type']),
      iconUrl: json['icon_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
      'is_future': isFuture,
      'id': id,
      'type': type,
      'subcategories':
          subcategories?.map((subcategory) => subcategory.toJson()).toList(),
      'category_type': categoryType.toJson(),
      'icon_url': iconUrl,
    };
  }
}

class FutureCategories {
  int? id;
  int? isFuture;
  String? name;
  String? icon;
  int? type;
  String? iconUrl;
  List<Subcategories>? subcategories;

  FutureCategories(
      {this.id,
      this.isFuture,
      this.name,
      this.icon,
      this.type,
      this.iconUrl,
      this.subcategories});

  FutureCategories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isFuture = json['is_future'];
    name = json['name'];
    icon = json['icon'];
    type = json['type'];
    iconUrl = json['icon_url'];
    if (json['subcategories'] != null) {
      subcategories = <Subcategories>[];
      json['subcategories'].forEach((v) {
        subcategories!.add(Subcategories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['is_future'] = isFuture;
    data['name'] = name;
    data['icon'] = icon;
    data['type'] = type;
    data['icon_url'] = iconUrl;
    if (subcategories != null) {
      data['subcategories'] = subcategories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CategoryType {
  final int id;
  final String name;

  CategoryType({
    required this.id,
    required this.name,
  });

  factory CategoryType.fromJson(Map<String, dynamic> json) {
    return CategoryType(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
