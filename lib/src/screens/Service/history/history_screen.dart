import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/model/history_model.dart';
import 'package:arif_mart/core/services/history_service.dart';
import 'package:arif_mart/core/helper/hive_helper.dart';
import 'controller/history_screen_controller.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final HistoryController _controller = Get.put(HistoryController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    // Debug auth info
    _debugAuthInfo();
    
    // Check auth status before loading data
    _checkAndHandleAuth();
    
    // Initialize with the first tab's data
    Future.delayed(Duration.zero, () {
      _controller.fetchRechargeHistory();
    });
  }
  
  // Check authentication and handle any issues
  void _checkAndHandleAuth() {
    final token = HiveHelper.getToken;
    final isLoggedIn = HiveHelper.getIsLogin;
    
    if (!isLoggedIn || token == null || token.isEmpty) {
      // Show a message to the user
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You need to be logged in to view your history'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Optionally redirect to login page
        // Get.offAllNamed(Routes.loginScreen);
      });
    }
  }
  
  // Debug method to check auth status
  void _debugAuthInfo() {
    // Check if token exists
    final token = HiveHelper.getToken;
    print('HISTORY SCREEN AUTH DEBUG:');
    print('Is user logged in? ${HiveHelper.getIsLogin}');
    print('Token exists? ${token != null && token.isNotEmpty}');
    if (token != null && token.isNotEmpty) {
      print('Token length: ${token.length}');
      print('Token starts with Bearer? ${token.startsWith('Bearer ')}');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    // Update controller when tab changes
    if (_tabController.indexIsChanging) {
      _controller.changeTab(_tabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Transaction History',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Recharge'),
            Tab(text: 'Credit'),
            Tab(text: 'Withdrawal'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRechargeHistoryTab(),
          _buildCreditHistoryTab(),
          _buildWithdrawalHistoryTab(),
        ],
      ),
    );
  }

  // Recharge History Tab
  Widget _buildRechargeHistoryTab() {
    return Obx(() {
      if (_controller.isLoadingRecharge.value && _controller.rechargeHistory.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.hasErrorRecharge.value) {
        return _buildErrorView(_controller.errorMsgRecharge.value, () => _controller.refreshRechargeHistory());
      }

      if (_controller.rechargeHistory.isEmpty) {
        return _buildEmptyView('No recharge history found', 'You haven\'t made any recharges yet.');
      }

      return Column(
        children: [
          // ListView
          Expanded(
            child: RefreshIndicator(
              onRefresh: _controller.refreshRechargeHistory,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _controller.rechargeHistory.length,
                itemBuilder: (context, index) {
                  final item = _controller.rechargeHistory[index];
                  return _buildRechargeHistoryItem(item);
                },
              ),
            ),
          ),
          // Pagination Controls
          Obx(() => _buildPaginationControls(
            currentPage: _controller.rechargeCurrentPage.value,
            totalPages: _controller.rechargeTotalPages.value,
            totalRecords: _controller.rechargeTotalRecords.value,
            hasNextPage: _controller.rechargeHasNextPage.value,
            hasPrevPage: _controller.rechargeHasPrevPage.value,
            isLoading: _controller.isLoadingRecharge.value,
            onPrevious: _controller.rechargeLoadPreviousPage,
            onNext: _controller.rechargeLoadNextPage,
          )),
        ],
      );
    });
  }

  // Credit History Tab
  Widget _buildCreditHistoryTab() {
    return Obx(() {
      if (_controller.isLoadingCredit.value && _controller.creditHistory.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.hasErrorCredit.value) {
        return _buildErrorView(_controller.errorMsgCredit.value, () => _controller.refreshCreditHistory());
      }

      if (_controller.creditHistory.isEmpty) {
        return _buildEmptyView('No credit history found', 'You haven\'t received any credits yet.');
      }

      return Column(
        children: [
          // ListView
          Expanded(
            child: RefreshIndicator(
              onRefresh: _controller.refreshCreditHistory,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _controller.creditHistory.length,
                itemBuilder: (context, index) {
                  final item = _controller.creditHistory[index];
                  return _buildCreditHistoryItem(item);
                },
              ),
            ),
          ),
          // Pagination Controls
          Obx(() => _buildPaginationControls(
            currentPage: _controller.creditCurrentPage.value,
            totalPages: _controller.creditTotalPages.value,
            totalRecords: _controller.creditTotalRecords.value,
            hasNextPage: _controller.creditHasNextPage.value,
            hasPrevPage: _controller.creditHasPrevPage.value,
            isLoading: _controller.isLoadingCredit.value,
            onPrevious: _controller.creditLoadPreviousPage,
            onNext: _controller.creditLoadNextPage,
          )),
        ],
      );
    });
  }

  // Withdrawal History Tab
  Widget _buildWithdrawalHistoryTab() {
    return Obx(() {
      if (_controller.isLoadingWithdrawal.value && _controller.withdrawalHistory.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.hasErrorWithdrawal.value) {
        return _buildErrorView(_controller.errorMsgWithdrawal.value, () => _controller.refreshWithdrawalHistory());
      }

      if (_controller.withdrawalHistory.isEmpty) {
        return _buildEmptyView('No withdrawal history found', 'You haven\'t made any withdrawal requests yet.');
      }

      return Column(
        children: [
          // ListView
          Expanded(
            child: RefreshIndicator(
              onRefresh: _controller.refreshWithdrawalHistory,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _controller.withdrawalHistory.length,
                itemBuilder: (context, index) {
                  final item = _controller.withdrawalHistory[index];
                  return _buildWithdrawalHistoryItem(item);
                },
              ),
            ),
          ),
          // Pagination Controls
          Obx(() => _buildPaginationControls(
            currentPage: _controller.withdrawalCurrentPage.value,
            totalPages: _controller.withdrawalTotalPages.value,
            totalRecords: _controller.withdrawalTotalRecords.value,
            hasNextPage: _controller.withdrawalHasNextPage.value,
            hasPrevPage: _controller.withdrawalHasPrevPage.value,
            isLoading: _controller.isLoadingWithdrawal.value,
            onPrevious: _controller.withdrawalLoadPreviousPage,
            onNext: _controller.withdrawalLoadNextPage,
          )),
        ],
      );
    });
  }

  // Recharge History Item Card
  Widget _buildRechargeHistoryItem(RechargeHistoryItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.operator,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _buildStatusBadge(item.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Mobile: ${item.mobileNumber}',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Amount: ৳${item.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                item.formattedDate,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Credit History Item Card
  Widget _buildCreditHistoryItem(CreditHistoryItem item) {
    // Determine icon and color based on type
    IconData icon;
    Color iconColor;
    
    if (item.type.toLowerCase() == 'credit') {
      icon = Icons.add_circle_outline;
      iconColor = Colors.green;
    } else {
      icon = Icons.remove_circle_outline;
      iconColor = Colors.red;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _capitalize(item.type),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          _buildStatusBadge(item.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.type.toLowerCase() == 'credit' ? '+' : '-'}৳${item.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: item.type.toLowerCase() == 'credit' ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (item.paymentMethod != 'N/A')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Payment Method',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.paymentMethod,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                item.formattedDate,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Withdrawal History Item Card
  Widget _buildWithdrawalHistoryItem(WithdrawalHistoryItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '৳${item.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                _buildStatusBadge(item.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  (item.type == 'mobile_banking' || item.mobileOperator != null)
                    ? Icons.phone_android 
                    : Icons.account_balance,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  item.typeDisplayName,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Show details based on type or available fields
            if (item.type == 'mobile_banking' || (item.mobileOperator != null || item.mobileNumber != null)) ...[
              _buildInfoRow('Operator', item.mobileOperator ?? 'N/A'),
              const SizedBox(height: 4),
              _buildInfoRow('Mobile Number', item.mobileNumber ?? 'N/A'),
            ] else if (item.type == 'bank_transfer' || (item.bankName != null || item.bankAccountNumber != null)) ...[
              _buildInfoRow('Bank Name', item.bankName ?? 'N/A'),
              const SizedBox(height: 4),
              _buildInfoRow('Branch', item.bankBranchName ?? 'N/A'),
              const SizedBox(height: 4),
              _buildInfoRow('Account Number', item.bankAccountNumber ?? 'N/A'),
              const SizedBox(height: 4),
              _buildInfoRow('Account Holder', item.accountHolderName ?? 'N/A'),
            ],
            
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                item.formattedDate,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for info rows
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Status badge widget
  Widget _buildStatusBadge(String status) {
    Color color;
    
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'processing':
        color = Colors.blue;
        break;
      case 'failed':
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        _capitalize(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Error view
  Widget _buildErrorView(String message, VoidCallback retryAction) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: retryAction,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Empty view
  Widget _buildEmptyView(String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper method to capitalize strings
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Pagination Controls Widget
  Widget _buildPaginationControls({
    required int currentPage,
    required int totalPages,
    required int totalRecords,
    required bool hasNextPage,
    required bool hasPrevPage,
    required bool isLoading,
    required VoidCallback onPrevious,
    required VoidCallback onNext,
  }) {
    // Hide pagination if only 1 page
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          // Info Badges Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Page $currentPage of $totalPages',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Total: $totalRecords',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Navigation Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading || !hasPrevPage ? null : onPrevious,
                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                  label: const Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasPrevPage ? AppColors.primaryColor : Colors.grey[300],
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[500],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading || !hasNextPage ? null : onNext,
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  label: const Text('Next'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasNextPage ? AppColors.primaryColor : Colors.grey[300],
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[500],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
