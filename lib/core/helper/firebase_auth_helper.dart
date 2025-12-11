// import 'package:cazipro/export.dart';
// import 'package:cazipro/firebase_options.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:google_sign_in/google_sign_in.dart';
//
// class FirebaseAuthHelper {
//   static final auth = FirebaseAuth.instance;
//
//   static get currentUser => auth.currentUser;
//
//   static Future<void> init() async {
//     await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   }
//
//   static Future<void> logOut() async {
//     await auth.signOut();
//     Get.offAllNamed(Routes.loginScreen);
//   }
//
//
//   static Future<void> signInWithGoogle() async {
//     try {
//       Loader.showLoader();
//       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//       final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth?.accessToken,
//         idToken: googleAuth?.idToken,
//       );
//       await auth.signInWithCredential(credential);
//       Loader.closeLoader();
//       Get.offAllNamed(Routes.homeScreen);
//     } catch (e) {
//       Loader.closeLoader();
//       rethrow;
//     }
//   }
//
//   static Future<void> signUpWithEmail({required String email, required String password}) async {
//     try {
//       if (Validators.validateEmail(email) != null) {
//         showToast(Validators.validateEmail(email) ?? '');
//       } else if (Validators.validatePassword(password) != null) {
//         showToast(Validators.validatePassword(password) ?? '');
//       } else {
//         Loader.showLoader();
//         await auth.createUserWithEmailAndPassword(
//           email: email,
//           password: password,
//         );
//         Loader.closeLoader();
//         Get.offAllNamed(Routes.homeScreen);
//       }
//     } on FirebaseAuthException catch (e) {
//       Loader.closeLoader();
//       showToast(e.message ?? 'Something went wrong!');
//     } catch (e) {
//       Loader.closeLoader();
//       showToast('Something went wrong!');
//     }
//   }
//
//   static Future<void> signInWithEmail({required String email, required String password}) async {
//     try {
//       if (Validators.validateEmail(email) != null) {
//         showToast(Validators.validateEmail(email) ?? '');
//       } else if (Validators.validatePassword(password) != null) {
//         showToast(Validators.validatePassword(password) ?? '');
//       } else {
//         Loader.showLoader();
//         await auth.signInWithEmailAndPassword(email: email, password: password);
//         Loader.closeLoader();
//         Get.offAllNamed(Routes.homeScreen);
//       }
//     } on FirebaseAuthException catch (e) {
//       Loader.closeLoader();
//       showToast(e.message ?? 'Something went wrong!');
//     } catch (e) {
//       Loader.closeLoader();
//       showToast('Something went wrong!');
//     }
//   }
// }
