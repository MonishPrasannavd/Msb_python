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
        data!.add(new PostFeedDataList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['page'] = this.page;
    data['limit'] = this.limit;
    data['total'] = this.total;
    data['total_pages'] = this.totalPages;
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
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    subcategory = json['subcategory'] != null
        ? new Subcategory.fromJson(json['subcategory'])
        : null;
    category = json['category'] != null
        ? new Category.fromJson(json['category'])
        : null;
    mediaUrl = json['media_url'];
    likesCount = json['likes_count'];
    isLiked = json['is_liked'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['created_by'] = this.createdBy;
    data['category_id'] = this.categoryId;
    data['grade_id'] = this.gradeId;
    data['title'] = this.title;
    data['media'] = this.media;
    data['sub_category_id'] = this.subCategoryId;
    data['school_id'] = this.schoolId;
    data['description'] = this.description;
    data['created_at'] = this.createdAt;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.subcategory != null) {
      data['subcategory'] = this.subcategory!.toJson();
    }
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    data['media_url'] = this.mediaUrl;
    data['likes_count'] = this.likesCount;
    data['is_liked'] = this.isLiked;
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
        students!.add(new Students.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['image'] = this.image;
    data['role_id'] = this.roleId;
    data['id'] = this.id;
    if (this.students != null) {
      data['students'] = this.students!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['score'] = this.score;
    data['user_id'] = this.userId;
    data['points'] = this.points;
    data['grade_id'] = this.gradeId;
    data['likes'] = this.likes;
    data['school_id'] = this.schoolId;
    data['created_by'] = this.createdBy;
    data['country_id'] = this.countryId;
    data['created_at'] = this.createdAt;
    data['state_id'] = this.stateId;
    data['updated_at'] = this.updatedAt;
    data['city'] = this.city;
    data['dob'] = this.dob;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_id'] = this.categoryId;
    data['name'] = this.name;
    data['id'] = this.id;
    data['icon'] = this.icon;
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
        ? new CategoryType.fromJson(json['category_type'])
        : null;
    iconUrl = json['icon_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['icon'] = this.icon;
    data['type'] = this.type;
    data['id'] = this.id;
    data['is_future'] = this.isFuture;
    if (this.categoryType != null) {
      data['category_type'] = this.categoryType!.toJson();
    }
    data['icon_url'] = this.iconUrl;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['id'] = this.id;
    return data;
  }
}
