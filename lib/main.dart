import 'dart:async';
import 'dart:io';

import 'package:face_detection_app/models/payments.dart';
import 'package:face_detection_app/models/users.dart';
import 'package:face_detection_app/screen/error.dart';
import 'package:face_detection_app/screen/pay_end.dart';
import 'package:face_detection_app/screen/pay_start.dart';
import 'package:face_detection_app/screen/pin.dart';
import 'package:face_detection_app/screen/select_user.dart';
import 'package:face_detection_app/screen/verify.dart';
import 'package:face_detection_app/services/api.dart';
import 'package:flutter/material.dart';
import 'package:face_camera/face_camera.dart';
import 'package:flutter/services.dart';
import 'screen/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await FaceCamera.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '나는Pay',
      theme: ThemeData(
        fontFamily: "NotoSansKR",
        primaryColor: Color(0xFFFF5050),
        appBarTheme: AppBarTheme(
          color: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePageScreen(),
        '/paystart': (context) => PaystartScreen(
              payment:
                  ModalRoute.of(context)!.settings.arguments as PaymentModel,
            ),
        '/camera': (context) {
          final PaymentModel payment =
              ModalRoute.of(context)!.settings.arguments as PaymentModel;
          return CameraScreen(payment: payment);
        },
        '/pin': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          final payment = args['payment'] as PaymentModel;
          final user = args['user'] as User?;
          return PinScreen(payment: payment, user: user);
        },
        '/verify': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          final payment = args['payment'] as PaymentModel;
          final user = args['user'] as User;
          return VerifyScreen(payment: payment, user: user);
        },
        '/end': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return PayEndScreen(
            payment: args['payment'] as PaymentModel,
            //user: args['user'] as User,
          );
        },
        '/user_select': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          final payment = args['payment'] as PaymentModel;
          final users = args['users'] as List<User>;
          return SelectUserScreen(payment: payment, users: users);
        },
        '/error': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          final errorCase = args['errorCase'] as String;
          final payment = args['payment'] as PaymentModel;
          return ErrorScreen(errorCase: errorCase, payment: payment);
        },
      },
    );
  }
}

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen>
    with WidgetsBindingObserver {
  late ApiService apiService;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    apiService = ApiService();
    _startCheckingPayments();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // 앱이 백그라운드로 전환될 때
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      // 앱이 포어그라운드로 돌아올 때
      _startCheckingPayments();
    }
  }

  void _startCheckingPayments() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      await _checkLatestPayment();
    });
  }

  Future<void> _checkLatestPayment() async {
    try {
      final latestPayment = await apiService.getLatestPayment();
      if (!latestPayment.isDone && latestPayment.store_id! == 0) {
        _timer?.cancel(); // Stop the timer when navigating
        Navigator.pushReplacementNamed(
          context,
          '/paystart',
          arguments: latestPayment,
        );
      }
    } catch (e) {
      // Handle error
      print('Error fetching latest payment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/home.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}

// import 'dart:async';
// import 'dart:io';

// import 'package:face_detection_app/models/payments.dart';
// import 'package:face_detection_app/models/users.dart';
// import 'package:face_detection_app/screen/error.dart';
// import 'package:face_detection_app/screen/pay_end.dart';
// import 'package:face_detection_app/screen/pay_start.dart';
// import 'package:face_detection_app/screen/pin.dart';
// import 'package:face_detection_app/screen/select_user.dart';
// import 'package:face_detection_app/services/api.dart';
// import 'package:flutter/material.dart';

// import 'package:face_camera/face_camera.dart';
// import 'package:flutter/services.dart';
// import 'screen/camera.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//   await FaceCamera.initialize();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp();
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: '나는Pay',
//       theme: ThemeData(
//         fontFamily: "NotoSansKR",
//         primaryColor: Color(0xFFFF5050),
//         appBarTheme: AppBarTheme(
//           color: Colors.white,
//         ),
//       ),
//       initialRoute: '/',
//       routes: {
//         '/': (context) => HomePageScreen(),
//         '/paystart': (context) => PaystartScreen(
//               payment:
//                   ModalRoute.of(context)!.settings.arguments as PaymentModel,
//             ),
//         '/camera': (context) {
//           final PaymentModel payment =
//               ModalRoute.of(context)!.settings.arguments as PaymentModel;
//           return CameraScreen(payment: payment);
//         },
//         '/pin': (context) {
//           final args = ModalRoute.of(context)!.settings.arguments
//               as Map<String, dynamic>;
//           final payment = args['payment'] as PaymentModel;
//           final user = args['user'] as User;
//           return PinScreen(payment: payment, user: user);
//         },
//         '/end': (context) {
//           final args = ModalRoute.of(context)!.settings.arguments as Map;
//           return PayEndScreen(
//             payment: args['payment'] as PaymentModel,
//             user: args['user'] as User?,
//           );
//         },
//         '/user_select': (context) {
//           final args = ModalRoute.of(context)!.settings.arguments
//               as Map<String, dynamic>;
//           final payment = args['payment'] as PaymentModel;
//           final users = args['users'] as List<User>;
//           return SelectUserScreen(payment: payment, users: users);
//         },
//         '/error': (context) {
//           final args = ModalRoute.of(context)!.settings.arguments
//               as Map<String, dynamic>;
//           final errorCase = args['errorCase'] as String;
//           final payment = args['payment'] as PaymentModel;
//           return ErrorScreen(errorCase: errorCase, payment: payment);
//         },
//       },
//     );
//   }
// }

// class HomePageScreen extends StatefulWidget {
//   const HomePageScreen({super.key});

//   @override
//   _HomePageScreenState createState() => _HomePageScreenState();
// }

// class _HomePageScreenState extends State<HomePageScreen> {
//   late ApiService apiService;
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     apiService = ApiService();
//     _startCheckingPayments();
//   }

//   void _startCheckingPayments() {
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
//       await _checkLatestPayment();
//     });
//   }

//   Future<void> _checkLatestPayment() async {
//     try {
//       final latestPayment = await apiService.getLatestPayment();
//       print(latestPayment.isDone);
//       if (!latestPayment.isDone) {
//         _timer?.cancel(); // Stop the timer when navigating
//         Navigator.pushReplacementNamed(
//           context,
//           '/paystart',
//           arguments: latestPayment,
//         );
//       }
//     } catch (e) {
//       // Handle error
//       print('Error fetching latest payment: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Image.asset(
//           'assets/images/home.png',
//           fit: BoxFit.cover,
//           width: double.infinity,
//           height: double.infinity,
//         ),
//       ),
//     );
//   }
// }
