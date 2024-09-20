import 'dart:io';

import 'package:face_detection_app/models/payments.dart';
import 'package:face_detection_app/services/api.dart';
import 'package:flutter/material.dart';

import 'package:face_camera/face_camera.dart';
import 'package:flutter/services.dart';
import 'camera.dart';

class PaystartScreen extends StatelessWidget {
  final PaymentModel payment;
  final apiservice = ApiService();

  PaystartScreen({super.key, required this.payment});
  String formatCurrency(String amount) {
    return amount.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},');
  }

  Future<void> _deletePayment(BuildContext context) async {
    try {
      await apiservice.deletePayment(payment.paymentsId);
    } catch (e) {
      print('Error deleting payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting payment')),
      );
    }
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
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64.0),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 64.0,
                      fontWeight: FontWeight.w600,
                      height: 1.5, // 줄 간격을 조절하는 속성, 폰트 크기의 배수
                    ),
                    children: [
                      TextSpan(
                          text: '결제하기',
                          style:
                              TextStyle(color: Theme.of(context).primaryColor)),
                      TextSpan(text: '를 눌러\n'),
                      TextSpan(
                          text: '얼굴',
                          style:
                              TextStyle(color: Theme.of(context).primaryColor)),
                      TextSpan(text: '을 인식해주세요'),
                    ],
                  ),
                  textAlign: TextAlign.left,
                )),
            SizedBox(height: 72),
            Image.asset(
              'assets/images/face_id.png',
              fit: BoxFit.cover,
              width: 256,
              height: 256,
            ),
            SizedBox(height: 64),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 128.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '금액',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${formatCurrency(payment.price)}원',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 60),
            Container(
              width: double.infinity,
              height: 84,
              margin: EdgeInsets.symmetric(horizontal: 128),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/camera',
                    arguments: payment,
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
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 84,
              margin: EdgeInsets.symmetric(horizontal: 128),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 225, 225, 225),
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () {
                  _deletePayment(context);
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
