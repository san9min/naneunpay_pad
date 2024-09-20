import 'dart:io';
import 'package:face_detection_app/models/payments.dart';
import 'package:face_detection_app/models/users.dart';
import 'package:flutter/material.dart';
import 'package:face_camera/face_camera.dart';
import 'package:flutter/services.dart';
import 'camera.dart';
import 'package:face_detection_app/services/api.dart';

class VerifyScreen extends StatefulWidget {
  final PaymentModel payment;
  final User user;

  const VerifyScreen({Key? key, required this.payment, required this.user})
      : super(key: key);

  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  late ApiService apiService;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int paymentPrice = int.parse(widget.payment.price);
      int totalPrice = int.parse(widget.user.totalPrice);

      if (paymentPrice + totalPrice > 100000) {
        Navigator.pushReplacementNamed(
          context,
          '/error',
          arguments: {
            'errorCase': 'limit',
            'payment': widget.payment,
          },
        );
      }
    });
  }

  Future<void> _deletePayment() async {
    try {
      await apiService.deletePayment(widget.payment.paymentsId);
    } catch (e) {
      print('Error deleting payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting payment')),
      );
    }
  }

  String formatUsername(String username) {
    if (username.length < 2) {
      // 이름이 두 글자 미만일 경우 처리
      return username;
    }
    // 두 번째 글자를 'X'로 바꾸고 나머지 부분을 유지
    return username[0] + 'X' + username.substring(2);
  }

  String formatPhoneNumber(String phoneNumber) {
    return "010-xxxx-${phoneNumber.substring(7)}";
  }

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
              'assets/images/won.png',
              fit: BoxFit.cover,
              width: 224,
              height: 224,
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
                    TextSpan(
                      text: '${formatUsername(widget.user!.username)}님\n',
                    ),
                    TextSpan(
                      text: '결제 할까요?\n',
                    ),
                    TextSpan(
                        text: '${formatPhoneNumber(widget.user!.phoneNumber)}님',
                        style: TextStyle(fontSize: 20))
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 84),
            Container(
              width: double.infinity,
              height: 84,
              margin: EdgeInsets.symmetric(horizontal: 64),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/end',
                    arguments: {
                      'payment': widget.payment,
                      'user': widget.user, // user 정보 전달
                    },
                  );
                },
                child: Center(
                  child: Text(
                    '결제하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 24,
            ),
            Container(
              width: double.infinity,
              height: 84,
              margin: EdgeInsets.symmetric(horizontal: 64),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 225, 225, 225),
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () {
                  _deletePayment();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/', (Route<dynamic> route) => false);
                },
                child: Center(
                  child: Text(
                    '취소',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
