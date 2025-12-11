import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/var_constants.dart';
import 'package:arif_mart/core/helper/export.dart';
import 'package:arif_mart/core/model/my_profile_model.dart';
import 'package:arif_mart/src/widget/custom_loader.dart';
import 'package:arif_mart/src/widget/custom_toast.dart';

class EditProfileController extends GetxController {
  TextEditingController nameController = TextEditingController(text: VarConstants.myProfileModel.value.data?.name??'');
  TextEditingController phoneController = TextEditingController(text: VarConstants.myProfileModel.value.data?.phoneNo??'');

  GlobalKey<FormState> editFormKey = GlobalKey<FormState>();

  onClickSave() async {
    Loader.showLoader();
    try{
      if(editFormKey.currentState!.validate()){
        final data = await Repository.editProfile(name: nameController.text, phoneNo: phoneController.text);
        if(data!=null){
          Loader.closeLoader();
          VarConstants.myProfileModel.value=MyProfileModel.fromJson(data);
          Get.back();
          showToast(data['message']);
        }
      }
    }catch(e){
      Get.log("$e");
    }finally{
      Loader.closeLoader();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    phoneController.dispose();
  }

}