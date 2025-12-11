// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import '../../export.dart';
//
// class AppTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final Color? fillColor;
//   final String? hintText;
//   final TextStyle? hintStyle;
//   final Widget? suffixIcon;
//   final Widget? prefixIcon;
//   final bool? obSecure;
//   final TextInputType? type;
//   final void Function()? onTap;
//   final void Function(String)? onChanged;
//   final String? Function(String?)? validator;
//
//   const AppTextField(
//       {super.key,
//       required this.controller,
//       this.fillColor,
//       this.hintText,
//       this.hintStyle,
//       this.suffixIcon,
//       this.prefixIcon,
//       this.type,
//       this.onTap,
//       this.onChanged,
//       this.obSecure,
//       this.validator});
//
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: type,
//       onTap: onTap,
//       onChanged: onChanged,
//       validator: validator,
//       obscureText: obSecure ?? false,
//       cursorColor: ColorConstants.colorConstants,
//       style: const TextStyle(color: ColorConstants.colorConstants),
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: fillColor,
//         hintText: hintText,
//         hintStyle: hintStyle,
//         suffixIcon: suffixIcon,
//         prefixIcon: prefixIcon,
//         constraints: validator == null ? BoxConstraints(maxHeight: 50.h, maxWidth: 350.w) : null,
//         border: OutlineInputBorder(
//           borderSide: BorderSide.none,
//           borderRadius: BorderRadius.circular(
//             10.r,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class AppDescriptionTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final Color? fillColor;
//   final String? hintText;
//   final TextStyle? hintStyle;
//   final Widget? suffixIcon;
//   final Widget? prefixIcon;
//   final bool? obSecure;
//   final int? maxLine;
//   final TextInputType? type;
//   final void Function()? onTap;
//   final void Function(String)? onChanged;
//
//   const AppDescriptionTextField(
//       {super.key,
//       required this.controller,
//       this.fillColor,
//       this.hintText,
//       this.hintStyle,
//       this.suffixIcon,
//       this.prefixIcon,
//       this.type,
//       this.onTap,
//       this.onChanged,
//       this.obSecure,
//       this.maxLine});
//
//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       keyboardType: type,
//       onTap: onTap,
//       onChanged: onChanged,
//       maxLines: maxLine,
//       obscureText: obSecure ?? false,
//       decoration: InputDecoration(
//           filled: true,
//           fillColor: fillColor,
//           hintText: hintText,
//           hintStyle: hintStyle,
//           suffixIcon: suffixIcon,
//           prefixIcon: prefixIcon,
//           constraints: BoxConstraints(maxWidth: 357.w),
//           border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10.r))),
//     );
//   }
// }
//
// class AppSearchTextField extends StatelessWidget {
//   const AppSearchTextField(
//       {super.key,
//       required this.controller,
//       this.fillColor,
//       this.hintText,
//       this.hintStyle,
//       this.suffixIcon,
//       this.prefixIcon,
//       this.type,
//       this.onTap,
//       this.onChanged,
//       required this.width});
//
//   final TextEditingController controller;
//   final Color? fillColor;
//   final String? hintText;
//   final TextStyle? hintStyle;
//   final Widget? suffixIcon;
//   final Widget? prefixIcon;
//   final TextInputType? type;
//   final void Function()? onTap;
//   final void Function(String)? onChanged;
//   final double width;
//
//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       cursorColor: ColorConstants.whiteColor,
//       controller: controller,
//       keyboardType: type,
//       onTap: onTap,
//       onChanged: onChanged,
//       decoration: InputDecoration(
//         contentPadding: const EdgeInsets.symmetric(vertical: 2),
//         filled: true,
//         fillColor: fillColor,
//         border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(50.r)),
//         constraints: BoxConstraints(
//           // maxWidth: 303.w,
//           maxWidth: width,
//           maxHeight: 40.h,
//         ),
//         hintText: hintText,
//         hintStyle: hintStyle,
//         prefixIcon: prefixIcon,
//       ),
//     );
//   }
// }
