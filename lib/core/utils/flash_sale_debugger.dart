import 'package:arif_mart/core/model/product_model.dart';
import 'package:arif_mart/core/utils/timezone_util.dart';

/// Helper class for debugging flash sale issues
class FlashSaleDebugger {
  /// Analyze a flash sale product and print detailed debug information
  static void analyzeProduct(ProductData product) {
    print('\n🔍 FLASH SALE ANALYSIS FOR: ${product.name}');
    print('📋 Product ID: ${product.id}');
    
    // Check if product has flash sale
    if (!product.flashSale.isActive) {
      print('❌ Flash sale is not enabled for this product');
      return;
    }
    
    // Get current time
    final now = DateTime.now();
    
    // Flash sale details
    final startDate = product.flashSale.startDate;
    final endDate = product.flashSale.endDate;
    
    print('📅 Flash Sale Configuration:');
    print('  - Flash sale active flag: ${product.flashSale.isActive ? 'YES' : 'NO'}');
    print('  - Regular price: ${product.price}');
    print('  - Flash sale price: ${product.flashSale.discountPrice}');
    
    // Time information with precise hour/minute display
    print('\n⏰ Time Information:');
    print('  - Current time: $now');
    print('  - Current time (hour:min): ${now.hour}:${now.minute}');
    print('  - Start time: ${startDate ?? 'Not set'} (Direct comparison - ignoring Z suffix)');
    if (startDate != null) {
      print('  - Start time (hour:min): ${startDate.hour}:${startDate.minute}');
    }
    print('  - End time: ${endDate ?? 'Not set'} (Direct comparison - ignoring Z suffix)');
    if (endDate != null) {
      print('  - End time (hour:min): ${endDate.hour}:${endDate.minute}');
    }
    
    // Millisecond-based comparison (absolute values)
    print('\n🔢 Millisecond epoch comparisons:');
    print('  - Now ms: ${now.millisecondsSinceEpoch}');
    if (startDate != null) {
      print('  - Start ms: ${startDate.millisecondsSinceEpoch}');
      print('  - Diff (now - start): ${now.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch}');
    }
    if (endDate != null) {
      print('  - End ms: ${endDate.millisecondsSinceEpoch}');
      print('  - Diff (end - now): ${endDate.millisecondsSinceEpoch - now.millisecondsSinceEpoch}');
    }
    
    // Time checks with more details
    if (startDate != null) {
      final beforeStart = now.isBefore(startDate);
      print('\n🚦 Start Time Check:');
      print('  - Is before start time: ${beforeStart ? 'YES' : 'NO'}');
      final startDiff = startDate.difference(now);
      if (beforeStart) {
        print('  - Time until start: ${_formatDuration(startDiff)}');
      } else {
        print('  - Time since start: ${_formatDuration(startDiff.abs())}');
      }
      
      // Component-wise comparison
      print('  - Component comparison:');
      _printComponentComparison('Year', now.year, startDate.year);
      _printComponentComparison('Month', now.month, startDate.month);
      _printComponentComparison('Day', now.day, startDate.day);
      _printComponentComparison('Hour', now.hour, startDate.hour);
      _printComponentComparison('Minute', now.minute, startDate.minute);
    } else {
      print('\n⚠️ No start time set!');
    }
    
    if (endDate != null) {
      final afterEnd = now.isAfter(endDate);
      print('\n🏁 End Time Check:');
      print('  - Is after end time: ${afterEnd ? 'YES' : 'NO'}');
      final endDiff = endDate.difference(now);
      if (afterEnd) {
        print('  - Time since end: ${_formatDuration(endDiff.abs())}');
      } else {
        print('  - Time until end: ${_formatDuration(endDiff)}');
      }
      
      // Component-wise comparison
      print('  - Component comparison:');
      _printComponentComparison('Year', now.year, endDate.year);
      _printComponentComparison('Month', now.month, endDate.month);
      _printComponentComparison('Day', now.day, endDate.day);
      _printComponentComparison('Hour', now.hour, endDate.hour);
      _printComponentComparison('Minute', now.minute, endDate.minute);
    } else {
      print('\n⚠️ No end time set!');
    }
    
    // Is flash sale currently active?
    final isActive = product.flashSale.isCurrentlyActive;
    print('\n📊 Flash Sale Status:');
    print('  - Is currently active: ${isActive ? 'YES' : 'NO'}');
    
    if (isActive) {
      final remaining = product.flashSale.timeRemaining;
      print('  - Time remaining: ${_formatDuration(remaining ?? Duration.zero)}');
      print('  - Effective price: ${product.effectivePrice}');
      print('  - Discount percentage: ${product.discountPercentage.toStringAsFixed(2)}%');
    }
    
    print('\n-------------------------------------');
  }
  
  /// Analyze a list of products with flash sales and print summary
  static void analyzeProductList(List<ProductData> products) {
    // Count statistics
    int totalProducts = products.length;
    int withFlashSaleConfig = 0;
    int activeFlashSales = 0;
    int upcoming = 0;
    int expired = 0;
    
    for (var product in products) {
      if (product.flashSale.isActive) {
        withFlashSaleConfig++;
        
        if (product.flashSale.isCurrentlyActive) {
          activeFlashSales++;
        } else {
          // Check if upcoming or expired
          final now = TimezoneUtil.getCurrentTime();
          if (product.flashSale.startDate != null && now.isBefore(product.flashSale.startDate!)) {
            upcoming++;
          } else if (product.flashSale.endDate != null && now.isAfter(product.flashSale.endDate!)) {
            expired++;
          }
        }
      }
    }
    
    // Print summary
    print('\n📊 FLASH SALE SUMMARY:');
    print('Total products: $totalProducts');
    print('Products with flash sale config: $withFlashSaleConfig');
    print('Currently active flash sales: $activeFlashSales');
    print('Upcoming flash sales: $upcoming');
    print('Expired flash sales: $expired');
    print('-------------------------------------');
  }
  
  /// Format a duration in a human-readable format
  static String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (days > 0) {
      return "$days days, $hours hours, $minutes minutes";
    } else if (hours > 0) {
      return "$hours hours, $minutes minutes";
    } else if (minutes > 0) {
      return "$minutes minutes, $seconds seconds";
    } else {
      return "$seconds seconds";
    }
  }
  
  /// Print a comparison of two time components
  static void _printComponentComparison(String component, int nowValue, int otherValue) {
    final comparison = nowValue == otherValue 
        ? '=' 
        : (nowValue > otherValue ? '>' : '<');
    final symbol = comparison == '=' ? '✓' : (comparison == '>' ? '↑' : '↓');
    
    print('    - $component: $nowValue $comparison $otherValue $symbol');
  }
}