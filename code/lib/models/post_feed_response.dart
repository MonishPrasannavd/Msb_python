class PostFeeds {
  int? page;
  int? limit;
  int? total;
  int? totalPages;
  List<PostFeedDataList>? data;

  PostFeeds({this.page, this.limit, this.total, this.totalPages, this.data});

  PostFeeds.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
    totalPages = json['total_pages'];
    if (json['data'] != null) {
      data = <PostFeedDataList>[];
      json['data'].forEach((v) {
        data!.add(PostFeedDataList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['limit'] = limit;
    data['total'] = total;
    data['total_pages'] = totalPages;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PostFeedDataList {
  int? id;
  int? createdBy;
  int? categoryId;
  int? gradeId;
  String? title;
  String? media;
  int? subCategoryId;
  int? schoolId;
  String? description;
  String? createdAt;
  User? user;
  Subcategory? subcategory;
  Category? category;
  String? mediaUrl;
  int? likesCount;
  bool? isLiked;

  PostFeedDataList(
      {this.id,
      this.createdBy,
      this.categoryId,
      this.gradeId,
      this.title,
      this.media,
      this.subCategoryId,
      this.schoolId,
      this.description,
      this.createdAt,
      this.user,
      this.subcategory,
      this.category,
      this.mediaUrl,
      this.likesCount,
      this.isLiked});

  PostFeedDataList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdBy = json['created_by'];
    categoryId = json['category_id'];
    gradeId = json['grade_id'];
    title = json['title'];
    media = json['media'];
    subCategoryId = json['sub_category_id'];
    schoolId = json['school_id'];
    description = json['description'];
    createdAt = json['created_at'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    subcategory = json['subcategory'] != null
        ? Subcategory.fromJson(json['subcategory'])
        : null;
    category =
        json['category'] != null ? Category.fromJson(json['category']) : null;
    mediaUrl = json['media_url'];
    likesCount = json['likes_count'];
    isLiked = json['is_liked'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['created_by'] = createdBy;
    data['category_id'] = categoryId;
    data['grade_id'] = gradeId;
    data['title'] = title;
    data['media'] = media;
    data['sub_category_id'] = subCategoryId;
    data['school_id'] = schoolId;
    data['description'] = description;
    data['created_at'] = createdAt;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (subcategory != null) {
      data['subcategory'] = subcategory!.toJson();
    }
    if (category != null) {
      data['category'] = category!.toJson();
    }
    data['media_url'] = mediaUrl;
    data['likes_count'] = likesCount;
    data['is_liked'] = isLiked;
    return data;
  }
}

class User {
  String? name;
  String? email;
  String? image;
  int? roleId;
  int? id;
  List<Students>? students;

  User(
      {this.name, this.email, this.image, this.roleId, this.id, this.students});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    image = json['image'];
    roleId = json['role_id'];
    id = json['id'];
    if (json['students'] != null) {
      students = <Students>[];
      json['students'].forEach((v) {
        students!.add(Students.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['image'] = image;
    data['role_id'] = roleId;
    data['id'] = id;
    if (students != null) {
      data['students'] = students!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Students {
  int? id;
  int? score;
  int? userId;
  int? points;
  int? gradeId;
  int? likes;
  int? schoolId;
  String? createdBy;
  int? countryId;
  String? createdAt;
  int? stateId;
  String? updatedAt;
  String? city;
  String? dob;

  Students(
      {this.id,
      this.score,
      this.userId,
      this.points,
      this.gradeId,
      this.likes,
      this.schoolId,
      this.createdBy,
      this.countryId,
      this.createdAt,
      this.stateId,
      this.updatedAt,
      this.city,
      this.dob});

  Students.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    score = json['score'];
    userId = json['user_id'];
    points = json['points'];
    gradeId = json['grade_id'];
    likes = json['likes'];
    schoolId = json['school_id'];
    createdBy = json['created_by'];
    countryId = json['country_id'];
    createdAt = json['created_at'];
    stateId = json['state_id'];
    updatedAt = json['updated_at'];
    city = json['city'];
    dob = json['dob'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['score'] = score;
    data['user_id'] = userId;
    data['points'] = points;
    data['grade_id'] = gradeId;
    data['likes'] = likes;
    data['school_id'] = schoolId;
    data['created_by'] = createdBy;
    data['country_id'] = countryId;
    data['created_at'] = createdAt;
    data['state_id'] = stateId;
    data['updated_at'] = updatedAt;
    data['city'] = city;
    data['dob'] = dob;
    return data;
  }
}

class Subcategory {
  int? categoryId;
  String? name;
  int? id;
  String? icon;

  Subcategory({this.categoryId, this.name, this.id, this.icon});

  Subcategory.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
    name = json['name'];
    id = json['id'];
    icon = json['icon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category_id'] = categoryId;
    data['name'] = name;
    data['id'] = id;
    data['icon'] = icon;
    return data;
  }
}

class Category {
  String? name;
  String? icon;
  int? type;
  int? id;
  int? isFuture;
  CategoryType? categoryType;
  String? iconUrl;

  Category(
      {this.name,
      this.icon,
      this.type,
      this.id,
      this.isFuture,
      this.categoryType,
      this.iconUrl});

  Category.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    icon = json['icon'];
    type = json['type'];
    id = json['id'];
    isFuture = json['is_future'];
    categoryType = json['category_type'] != null
        ? CategoryType.fromJson(json['category_type'])
        : null;
    iconUrl = json['icon_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['icon'] = icon;
    data['type'] = type;
    data['id'] = id;
    data['is_future'] = isFuture;
    if (categoryType != null) {
      data['category_type'] = categoryType!.toJson();
    }
    data['icon_url'] = iconUrl;
    return data;
  }
}

class CategoryType {
  String? name;
  int? id;

  CategoryType({this.name, this.id});

  CategoryType.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['id'] = id;
    return data;
  }
}
