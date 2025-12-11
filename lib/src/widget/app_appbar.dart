// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:kita_traveler/export.dart';
// import 'package:kita_traveler/ui/HomeView/HomeScreen/controller/home_controller.dart';
// import 'package:kita_traveler/core/constants/extension.dart';
// import 'package:super_tooltip/super_tooltip.dart';
//
// class HomeAppbar extends StatelessWidget implements PreferredSizeWidget {
//   final void Function()? notificationOnTap;
//   final void Function()? sosOnTap;
//   final HomeController controller;
//
//   const HomeAppbar(
//       {super.key,
//       this.notificationOnTap,
//       this.sosOnTap,
//       required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     return Container(
//       height: 100.h,
//       width: 393.w,
//       color: Colors.transparent,
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 19.w),
//         child: Row(
//           children: [
//             Image.asset(
//               AppAsset.kitaText,
//               height: 23.2.h,
//               width: 68.w,
//             ),
//             const Spacer(),
//             GestureDetector(
//               onTap: notificationOnTap,
//               child: Container(
//                 width: 38.w,
//                 height: 38.h,
//                 decoration: BoxDecoration(
//                   color: ColorConstants.whiteColor.withValues(alpha:0.30),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Center(
//                   child: Image.asset(
//                     AppAsset.notification,
//                     height: 24.h,
//                     width: 24.w,
//                     fit: BoxFit.fill,
//                   ),
//                 ),
//               ),
//             ),
//             (w * 0.02).addWSpace(),
//             // GestureDetector(
//             //   onTap: sosOnTap,
//             //   child: Container(
//             //     width: 38.w,
//             //     height: 38.h,
//             //     decoration: const BoxDecoration(
//             //       color: ColorConstants.cream,
//             //       shape: BoxShape.circle,
//             //     ),
//             //     child: Center(
//             //       child: AppString.sos.txt(
//             //           style: poppinsBold24w800.copyWith(
//             //               fontSize: AppFontSize.font14,
//             //               color: const Color(0xff8D0000))),
//             //     ),
//             //   ),
//             // ),
//             GestureDetector(
//               onDoubleTap: () {
//                 showDialog(
//                   context: context,
//                   builder: (context) {
//                     return CommonDialog(
//                       height: 260.h,
//                       width: 317.h,
//                       closeIcon: true,
//                       icon: Image.asset(
//                         AppAsset.handImg,
//                         height: 151.h,
//                         width: 317.w,
//                       ),
//                       message: Column(
//                         children: [
//                           AppString.emergencyContacts.txt(
//                             textAlign: TextAlign.center,
//                             style: poppinsMedium20w500.copyWith(
//                                 fontSize: AppFontSize.font16,
//                                 letterSpacing: -0.32,
//                                 color: ColorConstants.greenColor),
//                           ),
//                           (10.h).addHSpace(),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               },
//               onTap: () async {
//                 await controller.controller.showTooltip();
//               },
//               child: SuperTooltip(
//                 arrowLength: 24.h,
//                 arrowBaseWidth: 28.w,
//                 arrowTipDistance: 25.h,
//                 borderRadius: 7.r,
//                 showBarrier: true,
//                 controller: controller.controller,
//                 popupDirection: TooltipDirection.down,
//                 backgroundColor: ColorConstants.whiteColor,
//                 borderWidth: 1.0,
//                 content: SizedBox(
//                   width: 242.w,
//                   height: 90.h,
//                   child: Center(
//                     child: AppString.sosTitle.txt(
//                       style: poppinsRegular14w500.copyWith(
//                           color: ColorConstants.sosTitleColor,
//                           letterSpacing: -0.32),
//                       textAlign: TextAlign.start,
//                     ),
//                   ),
//                 ),
//                 child: Container(
//                   width: 38.w,
//                   height: 38.h,
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: ColorConstants.cream,
//                   ),
//                   child: Center(
//                     child: AppString.sos.txt(
//                       style: poppinsBold24w800.copyWith(
//                         fontSize: AppFontSize.font14,
//                         color: ColorConstants.sosColor,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   // TODO: implement preferredSize
//   Size get preferredSize => Size.fromHeight(80.h);
// }
//
// class CommanAppBar extends StatelessWidget implements PreferredSizeWidget {
//   Widget? titleText;
//   Widget? leadingIcon;
//   final List<Widget>? action;
//   double? appBarHeight;
//   double? appBarwidth;
//   final Color? appBarColor;
//   ShapeBorder? shapeBorder;
//   PreferredSizeWidget? bottom;
//   double? toolBarHeight;
//
//   CommanAppBar( {
//     Key? key,
//     this.titleText,
//     this.action,
//     this.leadingIcon,
//     this.appBarHeight,
//     this.appBarColor,
//     this.shapeBorder,
//     this.bottom,
//     this.toolBarHeight,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       title: titleText,
//       bottom: bottom,
//       centerTitle: true,
//       // backgroundColor: Colors.transparent,
//       backgroundColor: ColorConstants.colorConstants,
//       actions: action,
//       leading: leadingIcon,
//     );
//   }
//
//   @override
//   Size get preferredSize => Size.fromHeight(appBarHeight ?? 50);
// }
