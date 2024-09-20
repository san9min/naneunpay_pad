import 'dart:convert';

class User {
  final int id;
  final String username;
  final String totalPrice;
  final String discount;
  final String userFaceImage;
  final String phoneNumber;
  final bool settleDone;
  final String netPrice;

  User({
    required this.id,
    required this.username,
    required this.totalPrice,
    required this.discount,
    required this.userFaceImage,
    required this.phoneNumber,
    required this.settleDone,
    required this.netPrice,
  });

  // JSON 데이터를 User 객체로 변환하는 팩토리 메서드
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        username: json['username'],
        totalPrice: json['total_price'],
        discount: json['discount'],
        userFaceImage: json['user_face_image'],
        phoneNumber: json['phone_number'],
        settleDone: json['settle_done'],
        netPrice: json['net_price']);
  }

  // User 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'total_price': totalPrice,
      'discount': discount,
      'user_face_image': userFaceImage,
      'phone_number': phoneNumber,
      'settle_done': settleDone,
      'net_price': netPrice
    };
  }

  // JSON 문자열을 User 객체로 변환하는 헬퍼 메서드
  static User fromJsonString(String jsonString) {
    final jsonData = json.decode(jsonString);
    return User.fromJson(jsonData);
  }

  // User 객체를 JSON 문자열로 변환하는 헬퍼 메서드
  String toJsonString() {
    final jsonData = this.toJson();
    return json.encode(jsonData);
  }
}

// 여러 User 객체를 담는 클래스
class Users {
  final List<User> users;

  Users({required this.users});

  // JSON 데이터를 Users 객체로 변환하는 팩토리 메서드
  factory Users.fromJson(Map<String, dynamic> json) {
    var list = json['matched_users'] as List;
    List<User> usersList = list.map((i) => User.fromJson(i)).toList();

    return Users(users: usersList);
  }

  // Users 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'matched_users': users.map((user) => user.toJson()).toList(),
    };
  }

  // JSON 문자열을 Users 객체로 변환하는 헬퍼 메서드
  static Users fromJsonString(String jsonString) {
    final jsonData = json.decode(jsonString);
    return Users.fromJson(jsonData);
  }

  // Users 객체를 JSON 문자열로 변환하는 헬퍼 메서드
  String toJsonString() {
    final jsonData = this.toJson();
    return json.encode(jsonData);
  }
}
