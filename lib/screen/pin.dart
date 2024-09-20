import 'package:face_detection_app/models/payments.dart';
import 'package:face_detection_app/models/users.dart';
import 'package:face_detection_app/services/api.dart';
import 'package:flutter/material.dart';

class PinScreen extends StatefulWidget {
  final PaymentModel payment;
  final User? user;

  const PinScreen({Key? key, required this.payment, this.user})
      : super(key: key);

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String enteredPin = '';
  late ApiService apiService;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();

    // Check balance on screen initialization
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   int paymentPrice = int.parse(widget.payment.price);
    //   int userBalance = int.parse(widget.user.totalPrice);

    //   if (paymentPrice > userBalance) {
    //     Navigator.pushReplacementNamed(
    //       context,
    //       '/error',
    //       arguments: {
    //         'errorCase': 'balance',
    //         'payment': widget.payment,
    //       },
    //     );
    //   }
    // });
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

  Future<void> _checkIdentity() async {
    try {
      final result = await apiService.checkIdentity(
        widget.payment.paymentsId,
        widget.user!.id,
        enteredPin,
      );
      setState(() {
        enteredPin = "";
      });

      if (result == 'Identity confirmed') {
        Navigator.pushNamed(
          context,
          '/verify',
          arguments: {
            'payment': widget.payment,
            'user': widget.user, // user 정보 전달
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('비밀번호가 틀렸습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {}
  }

  Future<void> _getIdentity() async {
    try {
      final users = await apiService.getIdentity(
        widget.payment.paymentsId,
        enteredPin,
      );
      setState(() {
        enteredPin = "";
      });

      if (users.users.isNotEmpty) {
        Navigator.pushNamed(
          context,
          '/verify',
          arguments: {
            'payment': widget.payment,
            'user': users.users.first, // user 정보 전달
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('비밀번호가 틀렸습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {}
  }

  Widget numButton(int number) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Container(
        width: 128, // 원하는 너비로 설정합니다.
        child: TextButton(
          onPressed: () {
            setState(() {
              if (enteredPin.length < 4) {
                enteredPin += number.toString();
                if (enteredPin.length == 4) {
                  if (widget.user != null) {
                    _checkIdentity();
                  } else {
                    _getIdentity();
                  }
                }
              }
            });
          },
          child: Text(
            number.toString(),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(64.0),
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0, right: 12.0),
            child: AppBar(
              leading: Container(),
              elevation: 0,
              title: Image.asset('assets/images/header.png', fit: BoxFit.cover),
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 64),
            physics: const BouncingScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 64.0, right: 64, top: 96, bottom: 32),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 48.0,
                        fontWeight: FontWeight.w500), // 기본 스타일 설정
                    children: [
                      TextSpan(text: '비밀번호를 눌러주세요'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 24,
              ),

              /// pin code area
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) {
                    return Container(
                      margin: const EdgeInsets.all(6.0),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: index < enteredPin.length
                            ? Colors.black.withOpacity(0.25)
                            : Colors.black.withOpacity(0.1),
                      ),
                      child: null,
                    );
                  },
                ),
              ),

              SizedBox(height: 36.0),

              /// digits
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      3,
                      (index) => numButton(1 + 3 * i + index),
                    ).toList(),
                  ),
                ),

              /// 0 digit with back remove
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 128,
                    ),
                    numButton(0),
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Container(
                        width: 128, // 원하는 너비로 설정합니다.
                        child: TextButton(
                          onPressed: () {
                            setState(
                              () {
                                if (enteredPin.isNotEmpty) {
                                  enteredPin = enteredPin.substring(
                                      0, enteredPin.length - 1);
                                }
                              },
                            );
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 48,
                          ),
                        ),
                      ),
                    ),

                    //       TextButton(
                    //         onPressed: () {
                    //           setState(
                    //             () {
                    //               if (enteredPin.isNotEmpty) {
                    //                 enteredPin = enteredPin.substring(
                    //                     0, enteredPin.length - 1);
                    //               }
                    //             },
                    //           );
                    //         },
                    //         child: const Icon(
                    //           Icons.arrow_back,
                    //           color: Colors.black,
                    //           size: 48,
                    //         ),
                    //       ),
                  ],
                ),
              ),
              SizedBox(
                height: 48,
              ),
              // Container(
              //   width: double.infinity,
              //   height: 84,
              //   margin: EdgeInsets.symmetric(horizontal: 64),
              //   decoration: BoxDecoration(
              //     color: Theme.of(context).primaryColor,
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   child: InkWell(
              //     onTap: () {
              //       Navigator.of(context).pushNamed('/camera');
              //     },
              //     child: Center(
              //       child: Text(
              //         '확인',
              //         style: TextStyle(
              //           color: Colors.white,
              //           fontSize: 24,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              // SizedBox(
              //   height: 20,
              // ),

//###--------------------------###

              TextButton(
                onPressed: () {
                  setState(() {
                    enteredPin = '';
                  });
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
            ],
          ),
        ));
  }
}
