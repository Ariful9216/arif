// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:kita_traveler/core/constants/extension.dart';
//
// import '../../export.dart';
//
// class CommonDialog extends StatelessWidget {
//   final Widget message;
//   final Widget? icon;
//   final VoidCallback? onClose;
//   final double height;
//   final double width;
//   final Widget? text;
//   final bool? closeIcon;
//   final Widget? showCloseIcon;
//
//   const CommonDialog({
//     super.key,
//     required this.message,
//     this.icon,
//     this.onClose,
//     required this.height,
//     required this.width,
//     this.text,
//     this.closeIcon,
//     this.showCloseIcon,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // var h = MediaQuery.of(context).size.height;
//     // var w = MediaQuery.of(context).size.width;
//     return Dialog(
//       insetPadding: EdgeInsets.zero,
//       child: Container(
//         height: height,
//         width: width,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(14.r),
//           gradient: const LinearGradient(
//             colors: ColorConstants.dialogBoxLinerGradiant,
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Stack(
//           children: [
//             Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   if (icon != null) icon!,
//                   message,
//                   if (height > 250.h) text ?? const SizedBox(),
//                 ],
//               ),
//             ),
//             closeIcon == true
//                 ? Positioned(
//                     top: 8,
//                     right: 8,
//                     child: IconButton(
//                       highlightColor: Colors.transparent,
//                       onPressed: onClose ?? () => Navigator.of(context).pop(),
//                       icon: assetImage(AppAsset.removeIcon,
//                           height: 24.h, width: 24.w),
//                     ),
//                   )
//                 : const SizedBox(),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class CommonDialogWithDesc extends StatelessWidget {
//   final Widget message;
//   final Widget? desc;
//   final Widget? icon;
//   final VoidCallback? onClose;
//   final double height;
//   final double width;
//   final Widget? text;
//   final String? hintText;
//   final Color? hintColor;
//   final VoidCallback? onTap;
//
//   const CommonDialogWithDesc({
//     super.key,
//     required this.message,
//     this.icon,
//     this.onClose,
//     required this.height,
//     required this.width,
//     this.text,
//     this.desc,
//     this.hintText,
//     this.hintColor,
//     this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final h = MediaQuery.of(context).size.height;
//     //final w = MediaQuery.of(context).size.width;
//     return Dialog(
//       child: Container(
//         height: height,
//         width: width,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(14.r),
//           gradient: const LinearGradient(
//             colors: ColorConstants.dialogBoxLinerGradiant,
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Stack(
//           children: [
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.r),
//               child: Center(
//                 child: Column(
//                   children: [
//                     (h * 0.05).addHSpace(),
//                     message,
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         if (icon != null) icon!,
//                       ],
//                     ),
//                     (h * 0.02).addHSpace(),
//                     Container(
//                       width: 289.w,
//                       height: 145.h,
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10.r),
//                           border: Border.all(
//                               color:
//                                   ColorConstants.profileColor.withValues(alpha:0.32),
//                               width: 1.5.w)),
//                       child: AppDescriptionTextField(
//                         hintStyle: poppinsRegular14w500.copyWith(
//                             letterSpacing: -0.32,
//                             color: hintColor ?? ColorConstants.brownTextColor,
//                             fontSize: AppFontSize.font14),
//                         fillColor: Colors.transparent,
//                         controller: TextEditingController(),
//                         maxLine: 5,
//                         hintText: hintText.toString(),
//                       ),
//                     ),
//                     (h * 0.01).addHSpace(),
//                     desc!,
//                     Padding(
//                       padding: EdgeInsets.only(top: 40.h),
//                       child: GestureDetector(
//                         onTap: onTap,
//                         child: Container(
//                           height: 46.h,
//                           width: 256.w,
//                           decoration: BoxDecoration(
//                             color: ColorConstants.notificationColor,
//                             borderRadius: BorderRadius.circular(53.r),
//                           ),
//                           child: Center(child: text),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Positioned(
//               top: 8,
//               right: 8,
//               child: IconButton(
//                 highlightColor: Colors.transparent,
//                 onPressed: onClose ?? () => Navigator.of(context).pop(),
//                 icon:
//                     assetImage(AppAsset.removeIcon, height: 24.h, width: 24.w),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // class CommonDialogWithDesc extends StatelessWidget {
// //   final Widget message;
// //   final Widget? icon;
// //   final VoidCallback? onClose;
// //   final double height;
// //   final double width;
// //   final Widget? text;
// //
// //   const CommonDialogWithDesc({
// //     super.key,
// //     required this.message,
// //     this.icon,
// //     this.onClose,
// //     required this.height,
// //     required this.width,
// //     this.text,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final h = MediaQuery.of(context).size.height;
// //     final w = MediaQuery.of(context).size.width;
// //     return Dialog(
// //       child: Container(
// //         height: height,
// //         width: width,
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(14.r),
// //           gradient: const LinearGradient(
// //             colors: ColorConstants.dialogBoxLinerGradiant,
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //           ),
// //         ),
// //         child: Stack(
// //           children: [
// //             Padding(
// //               padding: EdgeInsets.symmetric(horizontal: 16.r),
// //               child: Center(
// //                 child: Column(
// //                   children: [
// //                     (h * 0.05).addHSpace(),
// //                     message,
// //                     Row(
// //                       crossAxisAlignment: CrossAxisAlignment.center,
// //                       children: [
// //                         (h * 0.10).addHSpace(),
// //                         if (icon != null) icon!,
// //                       ],
// //                     ),
// //                     Container(
// //                       decoration: BoxDecoration(
// //                           borderRadius: BorderRadius.circular(10.r),
// //                           border: Border.all(
// //                               color: ColorConstants.profileColor.withValues(alpha:0.32),
// //                               width: 1.5.w)),
// //                       child: AppDescriptionTextField(
// //                         hintStyle: poppinsRegular14w500.copyWith(
// //                             letterSpacing: -0.32,
// //                             color: ColorConstants.brownTextColor,
// //                             fontSize: AppFontSize.font14),
// //                         fillColor: Colors.transparent,
// //                         controller: TextEditingController(),
// //                         maxLine: 5,
// //                         hintText: AppString.addComment,
// //                       ),
// //                     ),
// //                     Padding(
// //                       padding: EdgeInsets.only(top: 40.h),
// //                       child: Container(
// //                         height: 46.h,
// //                         width: 256.w,
// //                         decoration: BoxDecoration(
// //                           color: ColorConstants.notificationColor,
// //                           borderRadius: BorderRadius.circular(53.r),
// //                         ),
// //                         child: Center(child: text),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //             Positioned(
// //               top: 8,
// //               right: 8,
// //               child: IconButton(
// //                 highlightColor: Colors.transparent,
// //                 onPressed: onClose ?? () => Navigator.of(context).pop(),
// //                 icon:
// //                     assetImage(AppAsset.removeIcon, height: 24.h, width: 24.w),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
