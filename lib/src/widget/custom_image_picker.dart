// import 'dart:io';
//
// import 'package:file_picker/file_picker.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
//
// import '../../export.dart';
//
// Future<File?>? customPickFile() async {
//   FilePickerResult? result = await FilePicker.platform.pickFiles();
//
//   if (result != null) {
//     // Process the file
//     File file = File(result.files.single.path!);
//     return file;
//   } else {
//     // User canceled the picker
//     return null;
//   }
// }
//
// Future<File?>? customImagePicker({int imageCropType = 0, bool isWithoutCrop = true}) {
//   return customBottomSheet(options: [
//     BottomSheetOptionModel(
//       name: "Camera",
//       onTap: () {
//         Get.back(result: ImageSource.camera);
//       },
//     ),
//     BottomSheetOptionModel(
//       name: "Gallery",
//       onTap: () => Get.back(result: ImageSource.gallery),
//     ),
//   ]).then((source) {
//     if (source != null) {
//       return ImagePicker().pickImage(source: source, imageQuality: 10).then(
//             (value) async {
//           if (value != null) {
//             if (isWithoutCrop) {
//               return File(value.path);
//             } else {
//               try {
//                 // Setup based on imageCropType
//                 List<CropAspectRatioPreset> aspectRatios;
//                 CropAspectRatio? initialRatio;
//
//                 switch (imageCropType) {
//                   case 1:
//                     aspectRatios = [CropAspectRatioPreset.ratio16x9];
//                     initialRatio = const CropAspectRatio(ratioX: 16, ratioY: 9);
//                     break;
//                   case 2:
//                     aspectRatios = [CropAspectRatioPreset.ratio4x3];
//                     initialRatio = const CropAspectRatio(ratioX: 3, ratioY: 4);
//                     break;
//                   default:
//                     aspectRatios = [
//                       CropAspectRatioPreset.original,
//                       CropAspectRatioPreset.square,
//                       CropAspectRatioPreset.ratio4x3,
//                       CropAspectRatioPreset.ratio3x2,
//                       CropAspectRatioPreset.ratio16x9,
//
//                     ];
//                 }
//
//                 CroppedFile? cropped = await ImageCropper().cropImage(
//                   sourcePath: value.path,
//                   compressQuality: 10,
//                   maxHeight: 800,
//                   aspectRatio: initialRatio,
//                   uiSettings: [
//                     AndroidUiSettings(
//                       toolbarTitle: 'Crop Image',
//                       toolbarColor: ColorConstants.blackColor,
//                       activeControlsWidgetColor: ColorConstants.blackColor,
//                       toolbarWidgetColor: Colors.white,
//                       aspectRatioPresets: aspectRatios,
//                       initAspectRatio: imageCropType == 0
//                           ? CropAspectRatioPreset.original
//                           : aspectRatios.first,
//                       lockAspectRatio: imageCropType != 0, // lock only when 1 or 2
//                     ),
//                     IOSUiSettings(
//                       title: 'Crop Image',
//                       aspectRatioLockEnabled: imageCropType != 0,
//                       aspectRatioPresets: aspectRatios,
//                     ),
//                   ],
//                 );
//
//                 if (cropped != null) {
//                   return File(cropped.path);
//                 }
//               } catch (e) {
//                 Get.log("Error =====>>> $e");
//               }
//             }
//           }
//           return null;
//         },
//       );
//     }
//     return null;
//   });
// }
//
// // Future<File?>? customImagePicker({required int imageCropType, bool? isWithoutCrop = true}) {
// //   return customBottomSheet(options: [
// //     BottomSheetOptionModel(
// //       name: "Camera",
// //       onTap: () {
// //         Get.back(result: ImageSource.camera);
// //       },
// //     ),
// //     BottomSheetOptionModel(
// //       name: "Gallery",
// //       onTap: () => Get.back(result: ImageSource.gallery),
// //     ),
// //   ]).then((source) {
// //     if (source != null) {
// //       return ImagePicker().pickImage(source: source, imageQuality: 10).then(
// //         (value) async {
// //           if (value != null) {
// //             if (isWithoutCrop == true) {
// //               return File(value.path);
// //             } else {
// //               try {
// //                 CroppedFile? cropped = await ImageCropper.platform.cropImage(
// //                   sourcePath: value.path ?? '',
// //                   // aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
// //                   compressQuality: 10,
// //                   maxHeight: 800,
// //                   uiSettings: [
// //                     AndroidUiSettings(
// //                       toolbarTitle: 'Crop Image',
// //                       toolbarColor: ColorConstants.blackColor,
// //                       activeControlsWidgetColor: ColorConstants.blackColor,
// //                       toolbarWidgetColor: Colors.white,
// //                       aspectRatioPresets: (imageCropType == 0)
// //                           ? [
// //                               CropAspectRatioPreset.original,
// //                               CropAspectRatioPreset.ratio4x3,
// //                               CropAspectRatioPreset.ratio5x3,
// //                               CropAspectRatioPreset.ratio5x4,
// //                               CropAspectRatioPreset.ratio7x5,
// //                               CropAspectRatioPreset.square,
// //                               CropAspectRatioPreset.ratio3x2,
// //                               CropAspectRatioPreset.ratio16x9,
// //                             ]
// //                           : [
// //                               if (imageCropType == 2) CropAspectRatioPreset.ratio3x2,
// //                               if (imageCropType == 1) CropAspectRatioPreset.ratio16x9,
// //                             ],
// //                     ),
// //                     IOSUiSettings(
// //                       title: 'Crop Image',
// //                       cancelButtonTitle: 'Cancel',
// //                       doneButtonTitle: 'Done',
// //                       aspectRatioPresets: (imageCropType == 0)
// //                           ? [
// //                               CropAspectRatioPreset.original,
// //                               CropAspectRatioPreset.ratio4x3,
// //                               CropAspectRatioPreset.ratio5x3,
// //                               CropAspectRatioPreset.ratio5x4,
// //                               CropAspectRatioPreset.ratio7x5,
// //                               CropAspectRatioPreset.square,
// //                               CropAspectRatioPreset.ratio3x2,
// //                               CropAspectRatioPreset.ratio16x9,
// //                             ]
// //                           : [
// //                               if (imageCropType == 2) CropAspectRatioPreset.ratio3x2,
// //                               if (imageCropType == 1) CropAspectRatioPreset.ratio16x9,
// //                             ],
// //                     ),
// //                   ],
// //                 );
// //                 if (cropped != null) {
// //                   return File(cropped.path);
// //                 }
// //               } catch (e) {
// //                 Get.log("Error =====>>> ${e}");
// //               }
// //             }
// //           }
// //
// //           return null;
// //         },
// //       );
// //     }
// //     return null;
// //   });
// // }
//
// Future<List<File>?>? customMultipleImagePicker() {
//   return customBottomSheet(options: [
//     BottomSheetOptionModel(
//       name: "Camera",
//       onTap: () async {
//         final image = await ImagePicker().pickImage(source: ImageSource.camera);
//         if (image != null) {
//           Get.back(result: [File(image.path)]);
//         }
//       },
//     ),
//     BottomSheetOptionModel(
//       name: "Gallery",
//       onTap: () async {
//         final images = await ImagePicker().pickMultiImage();
//         if (images.isNotEmpty) {
//           Get.back(result: images.map((image) => File(image.path)).toList());
//         }
//       },
//     ),
//   ]).then((dynamic result) {
//     if (result != null) {
//       return Future.value(result.cast<File>());
//     }
//     return null;
//   });
// }
//
// Future customBottomSheet({required List<BottomSheetOptionModel> options}) {
//   return Get.bottomSheet(
//     Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const SizedBox(height: 14),
//         Container(
//           width: 24.96,
//           height: 2.33,
//           decoration: const ShapeDecoration(
//             color: ColorConstants.colorConstants,
//             shape: StadiumBorder(),
//           ),
//         ),
//         const SizedBox(height: 30),
//         ...options.map((e) {
//           return ListTile(
//             onTap: e.onTap,
//             leading: e.icon != null ? Icon(e.icon) : Text(e.name, style: poppinsRegular16w400),
//             title: (e.icon != null) ? Text(e.name, style: poppinsRegular16w400) : null,
//           );
//         }),
//         const SizedBox(height: 30),
//       ],
//     ),
//     backgroundColor: ColorConstants.whiteColor,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.only(
//         topRight: Radius.circular(20),
//         topLeft: Radius.circular(20),
//       ),
//     ),
//   );
// }
//
// class BottomSheetOptionModel {
//   String name;
//   IconData? icon;
//   void Function()? onTap;
//
//   BottomSheetOptionModel({required this.name, this.icon, required this.onTap});
// }
