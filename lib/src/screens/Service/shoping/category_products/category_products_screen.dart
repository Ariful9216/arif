import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/constants/routes/routes.dart';
import 'controller/category_products_controller.dart';
import 'widgets/category_product_card.dart';

class CategoryProductsScreen extends StatelessWidget {
  const CategoryProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryProductsController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Obx(
          () => Text(
            controller.categoryName.value,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: controller.refreshProducts,
        child: Obx(() {
          // Loading state
          if (controller.isLoading.value && controller.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading products...',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (controller.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This category has no products yet',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          // Products grid
          return Column(
            children: [
              // Product count header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
                child: Text(
                  '${controller.totalCount.value} Product${controller.totalCount.value == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),

              // Products grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount:
                      controller.products.length +
                      (controller.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Load more indicator
                    if (index == controller.products.length) {
                      if (controller.isLoadingMore.value) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryColor,
                              ),
                            ),
                          ),
                        );
                      } else if (controller.hasMore.value) {
                        // Trigger load more
                        Future.delayed(Duration.zero, () {
                          controller.loadMoreProducts();
                        });
                        return const SizedBox.shrink();
                      }
                      return const SizedBox.shrink();
                    }

                    final product = controller.products[index];
                    return CategoryProductCard(
                      product: product,
                      onTap: () {
                        Get.toNamed(
                          Routes.productDetail,
                          arguments: {'productId': product.id},
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
