import 'dart:convert';

class PaymentModel {
  final int paymentsId;
  final int? userId; // Nullable
  final String price;
  final DateTime? paymentsDate; // Nullable
  final bool isDone;
  final String? userName; // Nullable
  final int? store_id;
  final String? face_pay_img;

  PaymentModel(
      {required this.paymentsId,
      this.userId,
      required this.price,
      this.paymentsDate,
      required this.isDone,
      this.userName,
      this.store_id,
      this.face_pay_img});

  // JSON 데이터를 PaymentModel 객체로 변환하는 팩토리 메서드
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
        paymentsId: json['payments_id'],
        userId: json['user_id'],
        price: json['price'],
        paymentsDate: json['payments_date'] != null
            ? DateTime.tryParse(json['payments_date']) // 날짜 파싱 시 null 처리
            : null,
        isDone: json['is_done'],
        userName: json['user_name'],
        store_id: json['store_id'],
        face_pay_img: json['face_pay_img']);
  }

  // PaymentModel 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'payments_id': paymentsId,
      'user_id': userId,
      'price': price,
      'payments_date': paymentsDate?.toIso8601String(),
      'is_done': isDone,
      'user_name': userName,
      'store_id': store_id,
      'face_pay_img': face_pay_img,
    };
  }

  // JSON 문자열을 PaymentModel 객체로 변환하는 헬퍼 메서드
  static PaymentModel fromJsonString(String jsonString) {
    final jsonData = json.decode(jsonString);
    return PaymentModel.fromJson(jsonData);
  }

  // PaymentModel 객체를 JSON 문자열로 변환하는 헬퍼 메서드
  String toJsonString() {
    final jsonData = this.toJson();
    return json.encode(jsonData);
  }

  PaymentModel copyWith(
      {int? paymentsId,
      int? userId,
      String? price,
      DateTime? paymentsDate,
      bool? isDone,
      String? userName,
      int? store_id,
      String? face_pay_img}) {
    return PaymentModel(
        paymentsId: paymentsId ?? this.paymentsId,
        userId: userId ?? this.userId,
        price: price ?? this.price,
        paymentsDate: paymentsDate ?? this.paymentsDate,
        isDone: isDone ?? this.isDone,
        userName: userName ?? this.userName,
        store_id: store_id ?? this.store_id,
        face_pay_img: face_pay_img ?? this.face_pay_img);
  }
}
