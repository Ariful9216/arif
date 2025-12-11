import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/api.dart';
import 'package:arif_mart/core/constants/var_constants.dart';
import 'package:arif_mart/src/screens/offers/Minute_offer/controller/minute_offer_controller.dart';
import 'package:arif_mart/src/widget/build_search_field.dart';
import 'package:arif_mart/src/widget/pending_card.dart';
import 'package:arif_mart/src/widget/show_offer_list_shimer.dart';
import 'package:arif_mart/src/widget/image_slider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/routes/routes.dart';
import '../../../widget/offer_card.dart';
import '../../../widget/operator_icon.dart';

class MinuteOfferScreen extends StatelessWidget {
  MinuteOfferScreen({super.key});

  final controller = Get.put(MinuteOfferController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.appBarColor3,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Get.back();
            },
          ),
          title: const Text('Minute Offer', style: TextStyle(color: Colors.white)),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            // spacing: 20,
            children: [
              TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primaryColor,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                onTap: (val) async {
                  controller.selectedTab.value = val;
                  await controller.getAllData();
                },
                tabs: [Tab(text: "Drive Pack"), Tab(text: "Pending"), Tab(text: "History")],
              ),


              buildSearchField(
                controller: controller.searchController,
                onChanged: (value) => controller.searchOffers(),
              ).paddingSymmetric(horizontal: 10),

              // Minute Offer Slider - Replaces static image
              Obx(
                () =>
                    controller.selectedTab.value == 0
                        ? Container(
                            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                            child: controller.isSlidersLoading.value
                                ? Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                  )
                                : controller.sliderList.isNotEmpty
                                    ? ImageSlider(
                                        sliders: controller.sliderList,
                                        onSliderTap: controller.openSliderUrl,
                                      )
                                    : Container(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Image.asset('assets/logo.png', width: 120, height: 120),
                                      ),
                          )
                        : const SizedBox.shrink(),
              ),

              Obx(() {
                return controller.selectedTab.value == 0
                    ? SizedBox(
                      height: 60,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children:
                                controller.isOperatorsLoading.value
                                    ? List.generate(10, (index) {
                                      return Shimmer(
                                        color: Colors.grey,
                                        colorOpacity: 0.5,
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          margin: EdgeInsets.symmetric(horizontal: 5),
                                          decoration: BoxDecoration(color: Colors.black.withAlpha(20), borderRadius: BorderRadius.circular(50)),
                                        ),
                                      );
                                    })
                                    : List.generate(controller.operatorModel.data.length, (index) {
                                      return InkWell(
                                        onTap: () {
                                          controller.onChangeOperator(id: controller.operatorModel.data[index].id);
                                        },
                                        child: operatorIcon(
                                          "${Apis.operatorBaseUrl}${controller.operatorModel.data[index].image}",
                                          controller.selectedOperators.value == controller.operatorModel.data[index].id,
                                        ),
                                      );
                                    }),
                          ),
                        ),
                      ),
                    )
                    : const SizedBox.shrink();
              }),

              // Tab Views
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Obx(
                      () =>
                          controller.isOffersLoading.value
                              ? ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: 5,
                                itemBuilder:
                                    (context, index) => Shimmer(
                                      color: Colors.grey,
                                      colorOpacity: 0.5,
                                      child: Container(
                                        width: 60,
                                        height: 120,
                                        margin: EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(color: Colors.black.withAlpha(20), borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                              )
                              : RefreshIndicator(
                            color: AppColors.appBarColor3,
                            onRefresh: () async {
                              controller.tempData.remove(controller.selectedOperators.value);
                              controller.getOffers();
                              controller.getSliders(); // Refresh sliders too
                            },
                                child: controller.offerDataList.isNotEmpty
                                ? ListView.builder(
                                  padding: const EdgeInsets.all(12),
                                  itemCount: controller.offerDataList.length,
                                  itemBuilder:
                                      (context, index) => offerCard(
                                        validity: controller.offerDataList[index].validity,
                                        title: controller.offerDataList[index].title,
                                        price: controller.offerDataList[index].price,
                                        discountAmount: controller.offerDataList[index].discountAmount,
                                        description: controller.offerDataList[index].description,
                                        actualPrice: controller.offerDataList[index].actualPrice,
                                        colorTheme: AppColors.appBarColor3,
                                        onTap: () async {
                                          final result = await Get.toNamed(Routes.order, arguments: controller.offerDataList[index]);
                                          if (result == true) {
                                            controller.getPendingOrder();
                                          }
                                        },
                                      ),
                                )
                                    : SingleChildScrollView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  child: SizedBox(
                                    height:
                                    MediaQuery.of(context).size.height/1.8 -
                                        kToolbarHeight - // adjust if you have custom app bar
                                        MediaQuery.of(context).padding.top,
                                    child: Center(child: Text("No Offer Available", style: TextStyle(color: AppColors.appBarColor3))),
                                  ),
                                ),
                              ),
                    ),
                    Obx(
                      () =>
                          controller.isPendingLoading.value
                              ? showOfferListShimer()
                              : RefreshIndicator(
                                color: AppColors.appBarColor3,
                                onRefresh: () async {
                                  VarConstants.pendingOrderModel = null;
                                  controller.getPendingOrder();
                                },
                                child:
                                    controller.pendingOrderList.isNotEmpty
                                        ? ListView.builder(
                                          padding: const EdgeInsets.all(12),
                                          itemCount: controller.pendingOrderList.length,
                                          itemBuilder:
                                              (context, index) => pendingCard(
                                                status: controller.pendingOrderList[index].status.capitalizeFirst??'',
                                                price: controller.pendingOrderList[index].offer.price,
                                                mobileNum: controller.pendingOrderList[index].phoneNo,
                                                discount: controller.pendingOrderList[index].offer.discountAmount,
                                                description: controller.pendingOrderList[index].offer.description,
                                                validity: controller.pendingOrderList[index].offer.validity,
                                                date: controller.pendingOrderList[index].offer.createdAt.toIso8601String(),
                                                onClickCancel: () {},
                                              ),
                                        )
                                        : SingleChildScrollView(
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          child: SizedBox(
                                            height:
                                                MediaQuery.of(context).size.height/1.3 -
                                                kToolbarHeight -
                                                MediaQuery.of(context).padding.top,
                                            child: Center(child: Text("No Pending Offer Available", style: TextStyle(color: AppColors.appBarColor3))),
                                          ),
                                        ),
                              ),
                    ),
                    Obx(
                      () =>
                          controller.isHistoryLoading.value
                              ? showOfferListShimer()
                              : RefreshIndicator(
                                color: AppColors.appBarColor3,
                                onRefresh: () async {
                                  VarConstants.historyOrderModel = null;
                                  controller.getHistoryOrder();
                                },
                                child:
                                    controller.historyOrderList.isNotEmpty
                                        ? ListView.builder(
                                          padding: const EdgeInsets.all(12),
                                          itemCount: controller.historyOrderList.length,
                                          itemBuilder:
                                              (context, index) => pendingCard(
                                                status: controller.historyOrderList[index].status.capitalizeFirst??'',
                                                price: controller.historyOrderList[index].offer.price,
                                                mobileNum: controller.historyOrderList[index].phoneNo,
                                                discount: controller.historyOrderList[index].offer.discountAmount,
                                                description: controller.historyOrderList[index].offer.description,
                                                validity: controller.historyOrderList[index].offer.validity,
                                                date: controller.historyOrderList[index].offer.createdAt.toIso8601String(),
                                                onClickCancel: () {},
                                              ),
                                        )
                                        : SingleChildScrollView(
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          child: SizedBox(
                                            height:
                                                MediaQuery.of(context).size.height/1.3 -
                                                kToolbarHeight - // adjust if you have custom app bar
                                                MediaQuery.of(context).padding.top,
                                            child: Center(child: Text("No History Offer Available", style: TextStyle(color: AppColors.appBarColor3))),
                                          ),
                                        ),
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
