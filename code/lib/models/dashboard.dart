class DashboardResponse {
  int? totalSchools;
  int? totalStudent;
  List<TopScoreStudents>? topScoreStudents;
  List<FutureCategories>? futureCategories;

  DashboardResponse(
      {this.totalSchools,
        this.totalStudent,
        this.topScoreStudents,
        this.futureCategories});

  DashboardResponse.fromJson(Map<String, dynamic> json) {
    totalSchools = json['total_schools'];
    totalStudent = json['total_student'];
    if (json['top_score_students'] != null) {
      topScoreStudents = <TopScoreStudents>[];
      json['top_score_students'].forEach((v) {
        topScoreStudents!.add(new TopScoreStudents.fromJson(v));
      });
    }
    if (json['future_categories'] != null) {
      futureCategories = <FutureCategories>[];
      json['future_categories'].forEach((v) {
        futureCategories!.add(new FutureCategories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_schools'] = this.totalSchools;
    data['total_student'] = this.totalStudent;
    if (this.topScoreStudents != null) {
      data['top_score_students'] =
          this.topScoreStudents!.map((v) => v.toJson()).toList();
    }
    if (this.futureCategories != null) {
      data['future_categories'] =
          this.futureCategories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TopScoreStudents {
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
  int? id;
  String? dob;
  int? score;
  User? user;

  TopScoreStudents(
      {this.userId,
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
        this.id,
        this.dob,
        this.score,
        this.user});

  TopScoreStudents.fromJson(Map<String, dynamic> json) {
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
    id = json['id'];
    dob = json['dob'];
    score = json['score'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
    data['id'] = this.id;
    data['dob'] = this.dob;
    data['score'] = this.score;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  String? name;
  String? email;
  String? image;
  int? roleId;
  int? id;
  String? imageUrl;

  User(
      {this.name, this.email, this.image, this.roleId, this.id, this.imageUrl});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    image = json['image'];
    roleId = json['role_id'];
    id = json['id'];
    imageUrl = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['image'] = this.image;
    data['role_id'] = this.roleId;
    data['id'] = this.id;
    data['image_url'] = this.imageUrl;
    return data;
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
        subcategories!.add(new Subcategories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['is_future'] = this.isFuture;
    data['name'] = this.name;
    data['icon'] = this.icon;
    data['type'] = this.type;
    data['icon_url'] = this.iconUrl;
    if (this.subcategories != null) {
      data['subcategories'] =
          this.subcategories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Subcategories {
  int? id;
  int? categoryId;
  String? icon;
  String? name;

  Subcategories({this.id, this.categoryId, this.icon, this.name});

  Subcategories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryId = json['category_id'];
    icon = json['icon'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['category_id'] = this.categoryId;
    data['icon'] = this.icon;
    data['name'] = this.name;
    return data;
  }
}
