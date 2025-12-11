import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/var_constants.dart';
import 'package:arif_mart/core/helper/export.dart';
import 'package:arif_mart/core/model/operator_model.dart';
import 'package:arif_mart/core/model/offer_order_model.dart';
import 'package:arif_mart/core/model/offers_model.dart';
import 'package:arif_mart/core/model/slider_model.dart';
import 'package:arif_mart/src/widget/custom_toast.dart';
import 'package:url_launcher/url_launcher.dart';

class ComboOfferController extends GetxController {
  var selectedTab = 0.obs;
  RxString selectedOperators = "".obs;
  RxBool isOperatorsLoading = true.obs;
  RxBool isOffersLoading = true.obs;
  RxBool isPendingLoading = true.obs;
  RxBool isHistoryLoading = true.obs;
  late OperatorModel operatorModel;
  late List<OfferData> offerDataList;
  Map<String, List<OfferData>> tempData = {};
  List<OfferOrderData> allPendingOrderList = [];
  List<OfferOrderData> pendingOrderList = [];
  List<OfferOrderData> allHistoryOrderList = [];
  List<OfferOrderData> historyOrderList = [];
  TextEditingController searchController = TextEditingController();

  // Sliders
  var sliderList = <SliderItem>[].obs;
  var isSlidersLoading = false.obs;

  Future<void> getSliders() async {
    try {
      isSlidersLoading.value = true;
      
      // Fetch both combo and all type sliders
      final comboResponse = await Repository.getSliders(type: 'combo');
      final allResponse = await Repository.getSliders(type: 'all');
      
      List<SliderItem> combinedSliders = [];
      
      if (comboResponse != null && comboResponse.success) {
        combinedSliders.addAll(comboResponse.data.where((slider) => slider.isActive));
      }
      
      if (allResponse != null && allResponse.success) {
        combinedSliders.addAll(allResponse.data.where((slider) => slider.isActive));
      }
      
      sliderList.value = combinedSliders;
      print("Combo sliders loaded: ${sliderList.length} items (combo + all types)");
    } catch (e) {
      print("Error loading combo sliders: $e");
    } finally {
      isSlidersLoading.value = false;
    }
  }

  Future<void> openSliderUrl(String url) async {
    if (url.isEmpty) return;
    
    try {
      final uri = Uri.parse(url);
      bool canLaunch = await canLaunchUrl(uri);
      
      if (canLaunch) {
        bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) return;
      }
      
      await Clipboard.setData(ClipboardData(text: url));
      showToast('Link copied to clipboard: ${_extractDomainName(url)}');
    } catch (e) {
      try {
        await Clipboard.setData(ClipboardData(text: url));
        showToast('Link copied to clipboard: ${_extractDomainName(url)}');
      } catch (clipboardError) {
        showToast('Unable to open link');
      }
    }
  }

  String _extractDomainName(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceAll('www.', '');
    } catch (e) {
      return url;
    }
  }

  getOperators()async{
    isOperatorsLoading.value=true;
    isOffersLoading.value=true;
    try{
      final response = await Repository.getOperators();
      if(response!=null){
        operatorModel = OperatorModel.fromJson(response);
        selectedOperators.value=operatorModel.data.first.id;
        getOffers();
      }
    }catch(e){
      showToast("Something Went Wrong");
    }finally{
      isOperatorsLoading.value=false;
    }
  }

  void searchOffers(){
    final query = searchController.text.toLowerCase();
    if(selectedTab.value==0){
      final originalList = tempData[selectedOperators.value] ?? [];
      isOffersLoading.value=true;
      if(query.isNotEmpty){
        offerDataList = originalList.where((offer) {
          final title = offer.title.toLowerCase();
          final description = offer.description.toLowerCase();
          return title.contains(query) || description.contains(query);
        }).toList();
      }else{
        offerDataList=tempData[selectedOperators.value]??[];
      }
      isOffersLoading.value=false;
    }else if(selectedTab.value==1){
      final originalList=allPendingOrderList;
      isPendingLoading.value=true;
      if(query.isNotEmpty){
        pendingOrderList=originalList.where((order) {
          final title=order.offer.title.toLowerCase();
          final description=order.offer.description.toLowerCase();
          final price = order.offer.price.toString().toLowerCase();
          final phone = order.phoneNo.toString().toLowerCase();
          final stateDivision = order.stateDivision.toString().toLowerCase();
          return title.contains(query) || description.contains(query) || price.contains(query) || phone.contains(query) || stateDivision.contains(query);
        },).toList();
      }else{
        pendingOrderList=allPendingOrderList;
      }
      isPendingLoading.value=false;
    }else if(selectedTab.value==2){
      final originalList=allHistoryOrderList;
      isHistoryLoading.value=true;
      if(query.isNotEmpty){
        historyOrderList=originalList.where((order) {
          final title=order.offer.title.toLowerCase();
          final description=order.offer.description.toLowerCase();
          final price = order.offer.price.toString().toLowerCase();
          final phone = order.phoneNo.toString().toLowerCase();
          final stateDivision = order.stateDivision.toString().toLowerCase();
          return title.contains(query) || description.contains(query) || price.contains(query) || phone.contains(query) || stateDivision.contains(query);
        },).toList();
      }else{
        historyOrderList=allHistoryOrderList;
      }
      isHistoryLoading.value=false;
    }
  }

  onChangeOperator({required String id}) async {
    selectedOperators.value=id;
    Get.log("change operator = ${selectedOperators.value}");
    await getOffers();
    searchOffers();
  }

  getOffers() async {
    isOffersLoading.value=true;
    if(tempData.containsKey(selectedOperators.value)){
      offerDataList = tempData[selectedOperators.value]??[];
    }else{
      final response = await Repository.getOffers(operator: selectedOperators.value, type: "combo");
      if (response != null) {
        offerDataList = OffersModel.fromJson(response).data;
        tempData[selectedOperators.value] = offerDataList;
      }
    }
    isOffersLoading.value=false;
  }

  getOrders({required String type}) async {
    try {
      OfferOrderModel orderModel = await Repository.getOrder(type: type);
      if(type=='pending'){
        VarConstants.pendingOrderModel=orderModel;
      }else{
        VarConstants.historyOrderModel=orderModel;
      }
    } catch (e) {
      Get.log("$e");
    } finally {
      isPendingLoading.value = false;
      isHistoryLoading.value=false;
    }
  }

  getPendingOrder() async {
    isPendingLoading.value = true;
    if (VarConstants.pendingOrderModel == null) {
      await getOrders(type: "pending");
    }
    allPendingOrderList=VarConstants.pendingOrderModel!.data?.where((element) => element.offer.offerType=="combo",).toList() ?? [];
    pendingOrderList=allPendingOrderList;
    isPendingLoading.value = false;
  }

  getHistoryOrder() async {
    isHistoryLoading.value=true;
    if (VarConstants.historyOrderModel == null) {
      await getOrders(type: 'history');
    }
    allHistoryOrderList=VarConstants.historyOrderModel!.data?.where((element) => element.offer.offerType=="combo",).toList() ?? [];
    historyOrderList=allHistoryOrderList;
    isHistoryLoading.value = false;
  }

  iniData() async {
    await getOperators();
    await getPendingOrder();
    await getHistoryOrder();
    await getSliders();
  }

  getAllData() async {
    isHistoryLoading.value=true;
    isPendingLoading.value=true;
    isOperatorsLoading.value = true;
    isOffersLoading.value = true;
    tempData.clear();
    VarConstants.pendingOrderModel=null;
    VarConstants.historyOrderModel=null;
    await iniData();
    searchOffers();
  }

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();
    await Future.delayed(Duration(microseconds: 100));
    await iniData();
  }

}