// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:kita_traveler/export.dart';
// import 'package:kita_traveler/core/constants/extension.dart';
//
// class AppDropDown<T> extends StatelessWidget {
//   final List<DropdownMenuItem<T>>? items;
//   final T? value;
//   final void Function(T?)? onChanged;
//   final DropdownDirection? direction;
//   final String name;
//   final String suggestion;
//   final double? height;
//   final double width;
//   final double? padding;
//   final void Function()? onTap;
//
//   const AppDropDown({
//     super.key,
//     this.items,
//     this.onChanged,
//     this.value,
//     this.direction,
//     required this.name,
//     required this.suggestion,
//     this.height,
//     required this.width,
//     this.padding,
//     this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: width,
//       height: height,
//       decoration: BoxDecoration(color: ColorConstants.whiteColor.withValues(alpha: 0.30), borderRadius: BorderRadius.circular(26.r)),
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: padding ?? 15.w),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Expanded(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     name,
//                     overflow: TextOverflow.ellipsis,
//                     style: poppinsMedium20w500.copyWith(fontSize: AppFontSize.font16, letterSpacing: -0.32, color: ColorConstants.whiteColor),
//                   ),
//                   suggestion.txt(
//                       style: poppinsRegular16w400.copyWith(fontSize: AppFontSize.font14, letterSpacing: -0.32, color: ColorConstants.notificationColor))
//                 ],
//               ),
//             ),
//             onTap != null
//                 ? GestureDetector(
//                     onTap: onTap,
//                     child: Icon(
//                       Icons.expand_circle_down,
//                       size: 24.w,
//                       color: ColorConstants.whiteColor.withValues(alpha: 0.50),
//                     ),
//                   )
//                 : DropdownButtonHideUnderline(
//                     child: DropdownButton2<T>(
//                       isExpanded: true,
//                       items: items,
//                       value: value,
//                       onChanged: onChanged,
//                       buttonStyleData: ButtonStyleData(
//                         height: 25.h,
//                         width: 25.w,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(14),
//                           color: Colors.transparent,
//                         ),
//                       ),
//                       iconStyleData: IconStyleData(
//                         icon: const Icon(
//                           Icons.expand_circle_down,
//                         ),
//                         iconSize: 24.w,
//                         iconEnabledColor: ColorConstants.whiteColor.withValues(alpha: 0.50),
//                         iconDisabledColor: ColorConstants.whiteColor.withValues(alpha: 0.50),
//                       ),
//                       dropdownStyleData: DropdownStyleData(
//                         maxHeight: 200,
//                         width: 162.w,
//                         direction: DropdownDirection.left,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(14),
//                           color: ColorConstants.whiteColor.withValues(alpha: 0.80),
//                         ),
//                         offset: const Offset(-20, 0),
//                         scrollbarTheme: ScrollbarThemeData(
//                           radius: const Radius.circular(40),
//                           thickness: WidgetStateProperty.all(6),
//                           thumbVisibility: WidgetStateProperty.all(true),
//                         ),
//                       ),
//                       menuItemStyleData: const MenuItemStyleData(
//                         height: 40,
//                         padding: EdgeInsets.only(left: 14, right: 14),
//                       ),
//                     ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }
