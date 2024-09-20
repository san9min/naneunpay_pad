import 'package:face_detection_app/models/payments.dart';
import 'package:face_detection_app/models/users.dart';
import 'package:face_detection_app/services/api.dart';
import 'package:flutter/material.dart';

class SelectUserScreen extends StatefulWidget {
  final PaymentModel payment;
  final List<User> users;

  const SelectUserScreen({Key? key, required this.payment, required this.users})
      : super(key: key);

  @override
  State<SelectUserScreen> createState() => _SelectUserScreenState();
}

class _SelectUserScreenState extends State<SelectUserScreen> {
  late List<User> _users; // 상태 변수로 선언합니다.
  late ApiService apiService;
  @override
  void initState() {
    super.initState();
    _users = widget.users; // 전달받은 users를 상태 변수로 설정합니다.
    apiService = ApiService();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(64.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 24.0, right: 12.0),
          child: AppBar(
            backgroundColor: Color(0xFFF5F5F5),
            leading: Container(),
            elevation: 0,
            title: Image.asset('assets/images/header.png', fit: BoxFit.cover),
          ),
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 64.0, vertical: 64),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 36.0,
                      fontWeight: FontWeight.w600,
                      height: 2, // 줄 간격을 조절하는 속성, 폰트 크기의 배수
                    ),
                    children: [
                      TextSpan(
                        text: '유사한 얼굴이 여러개 인식되었습니다\n',
                      ),
                      TextSpan(text: '본인의 계정을 선택해주세요'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 128),
              child: Container(
                height: _users.length * 128,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2), // changes position of shadow
                    ),
                  ],
                ),
                child: ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/pin',
                          arguments: {
                            'payment': widget.payment,
                            'user': _users[index],
                          },
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.asset(
                                'assets/images/user_profile.png',
                                width: 84,
                                height: 84,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    formatUsername(user.username),
                                    style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    user.phoneNumber.substring(
                                        user.phoneNumber.length -
                                            4), // 전화번호 마지막 4자리
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Spacer(),
            TextButton(
              onPressed: () {
                _deletePayment();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/', (Route<dynamic> route) => false);
              },
              child: const Text(
                '결제 취소',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(
              height: 36,
            )
          ],
        ),
      ),
    );
  }
}
