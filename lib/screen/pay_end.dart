import 'dart:io';
import 'package:face_detection_app/models/payments.dart';
import 'package:face_detection_app/models/users.dart';
import 'package:flutter/material.dart';
import 'package:face_camera/face_camera.dart';
import 'package:flutter/services.dart';
import 'camera.dart';
import 'package:face_detection_app/services/api.dart';

class PayEndScreen extends StatefulWidget {
  final PaymentModel payment;
  //final User user;

  const PayEndScreen({
    Key? key,
    required this.payment,
  }) // required this.user
  : super(key: key);

  @override
  _PayEndScreenState createState() => _PayEndScreenState();
}

class _PayEndScreenState extends State<PayEndScreen> {
  late ApiService apiService;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();

    // 3초 후에 홈으로 이동
    Future.wait([
      updatePaymentDetails(widget.payment), // 결제 정보 업데이트
      Future.delayed(Duration(seconds: 3)) // 3초 대기
    ]).then((_) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    }).catchError((error) {
      // 오류가 발생한 경우 처리
      print('Error during initialization: $error');
      // 필요에 따라 오류 처리를 추가합니다.
    });
  }

  Future<void> updatePaymentDetails(PaymentModel payment) async {
    final updatedPayment = payment.copyWith(
      //userId: widget.user.id,
      isDone: true, // 예를 들어, 결제 완료 상태로 설정
      paymentsDate: DateTime.now(), // 현재 시점으로 설정
      //userName: widget.user.username
    );
    print(updatedPayment);
    try {
      // 결제 정보 업데이트
      await apiService.updatePayment(updatedPayment);
      // 유저 잔고 업데이트
      //await apiService.updateUserTotalPrice(payment, widget.user);
    } catch (e) {
      // 오류 처리
      print('Error updating payment details: $e');
      // 필요에 따라 오류 처리를 추가합니다.
    }
  }

  // String formatUsername(String username) {
  //   if (username.length < 2) {
  //     // 이름이 두 글자 미만일 경우 처리
  //     return username;
  //   }
  //   // 두 번째 글자를 'X'로 바꾸고 나머지 부분을 유지
  //   return username[0] + 'X' + username.substring(2);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(84.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 24.0, right: 12.0),
          child: AppBar(
            leading: Container(),
            elevation: 0,
            title: Image.asset('assets/images/header.png', fit: BoxFit.cover),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 32),
            Image.asset(
              'assets/images/confirm.png',
              fit: BoxFit.cover,
              width: 284,
              height: 284,
            ),
            SizedBox(height: 64),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64.0),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 40.0, // 폰트 크기 조정
                    fontWeight: FontWeight.w500,
                    height: 1.5, // 줄간격 조정
                  ),
                  children: [
                    // TextSpan(
                    //   text: '어서오세요😊\n',
                    // ),
                    // TextSpan(
                    //   text: '${formatUsername(widget.user!.username)}님\n',
                    // ),
                    TextSpan(
                      text: '결제가 완료되었습니다😊',
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 84),
          ],
        ),
      ),
    );
  }
}
