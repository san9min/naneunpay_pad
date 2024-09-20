import 'dart:io';

import 'package:face_detection_app/models/payments.dart';
import 'package:face_detection_app/services/api.dart';
import 'package:flutter/material.dart';

import 'package:face_camera/face_camera.dart';
import 'package:flutter/services.dart';
import 'camera.dart';

class ErrorScreen extends StatefulWidget {
  final String errorCase;
  final PaymentModel payment;
  const ErrorScreen({Key? key, required this.errorCase, required this.payment})
      : super(key: key);

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  late ApiService apiService;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    _deletePayment();
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

  @override
  Widget build(BuildContext context) {
    String errorMessage;
    if (widget.errorCase == 'limit') {
      errorMessage = '결제한도를 넘었습니다😢';
    } else if (widget.errorCase == 'balance') {
      errorMessage = '잔액이 부족합니다😢';
    } else if (widget.errorCase == 'face') {
      errorMessage = '얼굴을 인식할 수 없습니다😢';
    } else {
      errorMessage = '알 수 없는 오류가 발생했습니다😢';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(84.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 24.0, right: 12.0),
          child: AppBar(
            leading: Container(),
            elevation: 0,
            title: Image.asset(
              'assets/images/header.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 32),
            Image.asset(
              'assets/images/error.png',
              fit: BoxFit.cover,
              width: 256,
              height: 256,
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
                      text: errorMessage,
                    ),
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
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/',
                    (Route<dynamic> route) => false,
                  );
                },
                child: Center(
                  child: Text(
                    '확인',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
