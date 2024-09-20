import 'dart:io';

import 'package:face_detection_app/constants/constants.dart';
import 'package:face_detection_app/models/payments.dart';
import 'package:face_detection_app/models/users.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

import 'package:path/path.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String serverUrl = SERVER_URL;

  ApiService();

  Future<PaymentModel> getLatestPayment() async {
    final url = Uri.parse('$serverUrl/payments/latest_payment');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return PaymentModel.fromJson(responseBody);
    } else if (response.statusCode == 404) {
      return PaymentModel(paymentsId: 0, price: "0", isDone: true);
    } else {
      throw Exception('Failed to fetch latest payment');
    }
  }

  Future<Users> sendUserFaceImage(int paymentId, File imageFile) async {
    final url = Uri.parse('$serverUrl/payments/$paymentId/face_recognition');
    final mimeType = lookupMimeType(imageFile.path);
    final request = http.MultipartRequest('POST', url)
      ..fields['user_face_img'] = basename(imageFile.path)
      ..files.add(await http.MultipartFile.fromPath(
        'user_face_img',
        imageFile.path,
        contentType: MediaType.parse(mimeType!),
      ));

    final response = await request.send();
    if (response.statusCode == 201) {
      final responseBody = await response.stream.bytesToString();
      final jsonData = json.decode(responseBody);
      return Users.fromJson(jsonData);
    } else if (response.statusCode == 404) {
      return Users(users: []);
    } else {
      return Users(users: []);
      //throw Exception('Failed to upload image and fetch users');
    }
  }

  Future<List<PaymentModel>> getPayments() async {
    final url = Uri.parse('$serverUrl/payments');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final paymentsJsonList = jsonData['payments'] as List<dynamic>;
      return paymentsJsonList
          .map((json) => PaymentModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to fetch payments');
    }
  }

  Future<PaymentModel> updatePayment(PaymentModel payment) async {
    final url = Uri.parse('$serverUrl/payments/${payment.paymentsId}');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(payment.toJson()),
    );

    if (response.statusCode == 200) {
      // 상태 코드 200으로 수정
      final responseBody = json.decode(response.body);
      return PaymentModel.fromJson(responseBody);
    } else {
      throw Exception('Failed to update payment');
    }
  }

  Future<PaymentModel> updateUserTotalPrice(
      PaymentModel payment, User user) async {
    final url =
        Uri.parse('$serverUrl/users/${user.id}/spend?price=${payment.price}');

    final response = await http.patch(
      url,
      headers: {
        'accept': 'application/json',
        // Remove 'Content-Type': 'application/json' because we're not sending a JSON body
      },
    );

    if (response.statusCode == 200) {
      // 상태 코드 200으로 수정
      final responseBody = json.decode(response.body);
      return PaymentModel.fromJson(responseBody);
    } else {
      throw Exception('Failed to update payment');
    }
  }

  Future<void> deletePayment(int paymentId) async {
    final url = Uri.parse('$serverUrl/payments/$paymentId');
    final response = await http.delete(url);

    if (response.statusCode == 204) {
      // 성공적으로 삭제되었는지 확인
      print('Payment deleted successfully');
    } else {
      throw Exception('Failed to delete payment');
    }
  }

  Future<String> checkIdentity(
      int paymentId, int userId, String password) async {
    final url = Uri.parse('$serverUrl/payments/$paymentId/check_identity');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'user_id': userId,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final responseBody = json.decode(response.body);
      return responseBody['result']; // "Identity confirmed" 메시지 반환
    } else if (response.statusCode == 401) {
      final responseBody = json.decode(response.body);
      return responseBody['detail']; // "Invalid password" 메시지 반환
    } else {
      throw Exception('Failed to check identity');
    }
  }

//임시
  Future<Users> getIdentity(int paymentId, String password) async {
    final url = Uri.parse('$serverUrl/payments/$paymentId/get_identity');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      return Users.fromJson(jsonData); // Users 모델로 파싱
    } else if (response.statusCode == 401) {
      return Users(users: []); // "Invalid password" 메시지 반환
    } else {
      throw Exception('Failed to check identity');
    }
  }

  Future<PaymentModel?> facePay(int paymentId, File imageFile) async {
    final url = Uri.parse('$serverUrl/payments/$paymentId/face_payment');
    final mimeType = lookupMimeType(imageFile.path);
    final request = http.MultipartRequest('POST', url)
      ..fields['user_face_img'] = basename(imageFile.path)
      ..files.add(await http.MultipartFile.fromPath(
        'user_face_img',
        imageFile.path,
        contentType: MediaType.parse(mimeType!),
      ));

    final response = await request.send();
    if (response.statusCode == 201) {
      final responseBody = await response.stream.bytesToString();
      final jsonData = json.decode(responseBody);
      return PaymentModel.fromJson(jsonData);
    } else {
      return null;
    }
  }

  // Future<PaymentModel> updateUserBalance(
  //     PaymentModel payment, User user) async {
  //   final url =
  //       Uri.parse('$serverUrl/users/${user.id}/spend?price=${payment.price}');

  //   final response = await http.patch(
  //     url,
  //     headers: {
  //       'accept': 'application/json',
  //       // Remove 'Content-Type': 'application/json' because we're not sending a JSON body
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     // 상태 코드 200으로 수정
  //     final responseBody = json.decode(response.body);
  //     return PaymentModel.fromJson(responseBody);
  //   } else {
  //     throw Exception('Failed to update payment');
  //   }
  // }
}
