import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart';
//part 'competitions.g.dart';

@JsonSerializable(explicitToJson: true)
class CompetitionsCategories {
  final CompetitionsCategory data;

  CompetitionsCategories({required this.data});

  factory CompetitionsCategories.fromJson(Map<String, dynamic> json) {
    var data = CompetitionsCategory.fromJson(json);
    // List<Competition> competitionList =
    //     dataList.map((i) => Competition.fromJson(i)).toList();

    return CompetitionsCategories(data: data);
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'data': data.map((competition) => competition.toJson()).toList(),
  //   };
  // }
}

class CompetitionsCategory {
  final String name;
  final String icon;
  final int isFuture;
  final int id;
  final int type;
  final List<Subcategory> subcategories;
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
    var subcategoriesFromJson = json['subcategories'] as List;
    List<Subcategory> subcategoryList =
        subcategoriesFromJson.map((i) => Subcategory.fromJson(i)).toList();

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
          subcategories.map((subcategory) => subcategory.toJson()).toList(),
      'category_type': categoryType.toJson(),
      'icon_url': iconUrl,
    };
  }
}

class Subcategory {
  final String name;
  final int categoryId;
  final int id;
  final String? icon;

  Subcategory({
    required this.name,
    required this.categoryId,
    required this.id,
    this.icon,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      name: json['name'],
      categoryId: json['category_id'],
      id: json['id'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category_id': categoryId,
      'id': id,
      'icon': icon,
    };
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
