import 'package:get/get.dart';
import '../../../../../core/helper/repository.dart';
import '../../../../../core/model/income_model.dart';

class IncomeController extends GetxController {
  var referralEarnings = 0.0.obs;
  var shoppingEarnings = 0.0.obs;
  var rechargeEarnings = 0.0.obs;
  var totalIncome = 0.0.obs;
  var isLoading = false.obs;
  var lastTransaction = Rxn<LastTransaction>();

  @override
  void onInit() {
    super.onInit();
    fetchEarnings();
  }

  Future<void> fetchEarnings() async {
    try {
      isLoading.value = true;
      
      final incomeModel = await Repository.getIncome();
      
      if (incomeModel != null && incomeModel.success) {
        referralEarnings.value = incomeModel.message.fromReferral;
        shoppingEarnings.value = incomeModel.message.fromShopping;
        rechargeEarnings.value = incomeModel.message.fromRecharge;
        totalIncome.value = incomeModel.message.totalIncome;
        lastTransaction.value = incomeModel.message.lastTransaction;
        
        print("Income data loaded successfully:");
        print("From Referral: ${referralEarnings.value}");
        print("From Shopping: ${shoppingEarnings.value}");
        print("From Recharge: ${rechargeEarnings.value}");
        print("Total Income: ${totalIncome.value}");
        if (lastTransaction.value != null) {
          print("Last Transaction: ${lastTransaction.value!.description} - ${lastTransaction.value!.amount}");
        }
      } else {
        print("Failed to load income data");
        // Keep default values (0.0)
      }
    } catch (e) {
      print("Error fetching income: $e");
      // Keep default values (0.0)
    } finally {
      isLoading.value = false;
    }
  }
}
