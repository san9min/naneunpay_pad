import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:face_detection_app/models/payments.dart';
import 'package:face_detection_app/models/users.dart';
import 'package:face_detection_app/services/api.dart';
import 'package:flutter/material.dart';

import 'package:face_camera/face_camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CameraScreen extends StatefulWidget {
  final PaymentModel payment;

  const CameraScreen({super.key, required this.payment});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _capturedImage;

  late FaceCameraController controller;
  late ApiService apiService;
  bool isNavigating = false;
  int num_trying = 0;
  Timer? _timer;
  String _message = '가까이 다가와 얼굴을 인식해주세요';
  bool sent = false;
  bool captureTriggered = false;
  @override
  void initState() {
    controller = FaceCameraController(
      autoCapture: true,
      enableAudio: false,
      imageResolution: ImageResolution.ultraHigh,
      defaultFlashMode: CameraFlashMode.off,
      performanceMode: FaceDetectorMode.fast,
      orientation: CameraOrientation.portraitUp,
      defaultCameraLens: CameraLens.front,
      onCapture: (File? image) {
        setState(() => _capturedImage = image);
      },
      onFaceDetected: (Face? face) {
        //Do something
      },
    );
    apiService = ApiService();
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 250), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        num_trying += 250;
        if (num_trying == 2000) {
          _message = '더 가까이 와주세요';
        } else if (num_trying == 4500 && !captureTriggered && !sent) {
          captureTriggered = true;
          _captureImage();
        }

        // else if (num_trying == 4750) {
        //   _navigateToNextScreen(null);
        // }
      });
    });
  }

  Future<void> _captureImage() async {
    final xfile = await controller.takePicture();
    setState(() {
      _capturedImage = File(xfile!.path);
    });
  }

  void _handleImageUpload(int paymentId) async {
    try {
      if (!sent) {
        sent = true;
        final payment = await apiService.facePay(paymentId, _capturedImage!);
        // final users =
        //     await apiService.sendUserFaceImage(paymentId, _capturedImage!);

        // 사용자 정보 처리
        _navigateToNextScreen(payment);
      }
    } catch (e) {
      // 오류 처리
      print('Error uploading image: $e');
    }
  }

  void _navigateToNextScreen(PaymentModel? payment
      //Users? users
      ) async {
    if (!mounted || isNavigating) return; // 위젯이 여전히 화면에 있는지 확인
    isNavigating = true;
    if (payment != null) {
      await Navigator.popAndPushNamed(
        context,
        '/end',
        arguments: {'payment': payment},
      );
    }
    // if (users != null && users.users.length == 1) {
    //   await Navigator.popAndPushNamed(
    //     context,
    //     '/pin',
    //     arguments: {
    //       'payment': widget.payment,
    //       'user': users.users.first,
    //     },
    //   );
    // } else if (users != null && users.users.length > 1) {
    //   await Navigator.popAndPushNamed(
    //     context,
    //     '/user_select',
    //     arguments: {
    //       'payment': widget.payment,
    //       'users': users.users,
    //     },
    //   );
    // } else {
    //   await Navigator.popAndPushNamed(
    //     context,
    //     '/pin',
    //     arguments: {
    //       'payment': widget.payment,
    //     },
    //   );
    // }
  }

  // void _navigateToNextScreen(Users users) async {
  //   if (!mounted) return; // 위젯이 여전히 화면에 있는지 확인
  //   if (users.users.length == 1) {
  //     await Navigator.popAndPushNamed(
  //       context,
  //       '/pin',
  //       arguments: {
  //         'payment': widget.payment,
  //         'user': users.users.first,
  //       },
  //     );
  //   } else if (users.users.length > 1) {
  //     await Navigator.popAndPushNamed(
  //       context,
  //       '/user_select',
  //       arguments: {
  //         'payment': widget.payment,
  //         'users': users.users,
  //       },
  //     );
  //   } else {
  //     await Navigator.popAndPushNamed(
  //       context,
  //       '/pin',
  //       arguments: {
  //         'payment': widget.payment,
  //       },
  //     );
  //     // if (num_trying < 2) {
  //     //   num_trying += 1;
  //     //   await controller.startImageStream();
  //     //   setState(() => _capturedImage = null);
  //     // } else {
  //     //   await Navigator.popAndPushNamed(
  //     //     context,
  //     //     '/error',
  //     //     arguments: {
  //     //       'errorCase': 'face',
  //     //       'payment': widget.payment,
  //     //     },
  //     //   );
  //     // }
  //   }
  // }
  @override
  void dispose() {
    _timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF18171E),
        body: Builder(builder: (context) {
          if (_capturedImage != null) {
            _handleImageUpload(widget.payment.paymentsId);

            return Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: LoadingAnimationWidget.twoRotatingArc(
                  color: Color(0xFFFF5050),
                  size: MediaQuery.sizeOf(context).width * 0.5,
                ),
              ),
            );
          }
          return Center(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.8,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SmartFaceCamera(
                      indicatorBuilder: (context, detectedFace, imageSize) {
                        return Stack(
                          children: [
                            // Grey overlay
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withOpacity(0.7),
                              ),
                            ),
                            // Transparent circular area in the center
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  (detectedFace!.wellPositioned == false)
                                      ? Container(
                                          width: imageSize!.width *
                                              0.9, // Adjust the size as needed
                                          height: imageSize!.width *
                                              0.9, // Adjust the size as needed
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.transparent,
                                            border: Border.all(
                                              color: (num_trying <= 4000)
                                                  ? Colors.white
                                                  : Color(
                                                      0xFFFF5050), // Border color of the indicator
                                              width:
                                                  12.0, // Border width of the indicator
                                            ),
                                          ),
                                        )
                                      : Image.asset(
                                          "assets/images/indicator.png",
                                          width: imageSize!.width *
                                              0.9, // Adjust the size as needed
                                          height: imageSize!.width *
                                              0.9, // Adjust the size as needed
                                          fit: BoxFit.cover,
                                        ),
                                  SizedBox(
                                    height: (num_trying < 2000) ? 28.0 : 14.0,
                                  ), // Adjust the space between the circle and the text
                                  Text(
                                    _message,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          (num_trying < 2000) ? 24.0 : 36.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      controller: controller,
                      showControls: false,
                    ),
                  ),
                ],
              ),
            ),
          );
        }));
  }

  // Widget _message(String msg) => Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 36),
  //       child: Text(msg,
  //           textAlign: TextAlign.center,
  //           style: const TextStyle(
  //               fontSize: 36,
  //               height: 1.5,
  //               fontWeight: FontWeight.w600,
  //               color: Colors.white)),
  //     );
}
