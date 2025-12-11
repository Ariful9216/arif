// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:kita_traveler/export.dart';
// import 'package:kita_traveler/core/constants/extension.dart';
//
// class AppButton extends StatelessWidget {
//   final void Function()? onTap;
//   final String text;
//   final double? fontSize;
//   final Widget? image;
//   final Color? buttonColor;
//   final Color? borderColor;
//   final Color? textColor;
//
//   const AppButton({super.key, this.onTap, required this.text, this.buttonColor, this.borderColor, this.textColor, this.image, this.fontSize});
//
//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     //final h = MediaQuery.of(context).size.height;
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 53.h,
//         width: 357.w,
//         decoration:
//             BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: borderColor ?? const Color(0xff8D2A00))),
//         child: Center(
//             child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (image != null) image!,
//             (w * 0.02).addWSpace(),
//             Text(
//               text,
//               overflow: TextOverflow.ellipsis,
//               style:
//                   poppinsMedium20w500.copyWith(letterSpacing: -0.32, fontSize: fontSize ?? AppFontSize.font18, color: textColor ?? ColorConstants.whiteColor),
//             )
//           ],
//         )),
//       ),
//     );
//   }
// }
//
// class AppRoundButton extends StatelessWidget {
//   final void Function()? onTap;
//   final String text;
//   final Color? buttonColor;
//   final Color? borderColor;
//   final Color? textColor;
//
//   const AppRoundButton({super.key, this.onTap, required this.text, this.buttonColor, this.borderColor, this.textColor});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 53.h,
//         width: 357.w,
//         decoration: BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(53.r), border: Border.all(color: borderColor ?? Colors.transparent)),
//         child: Center(
//           child: text.txt(style: poppinsMedium20w500.copyWith(fontSize: AppFontSize.font18, color: textColor ?? ColorConstants.whiteColor)),
//         ),
//       ),
//     );
//   }
// }
