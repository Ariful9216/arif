import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';

class InAppUpdateService extends GetxService {
  Future<InAppUpdateService> init() async {
    print('🔄 Checking for app updates...');

    if (!GetPlatform.isAndroid) {
      print('⚠️ In-app updates are only supported on Android.');
      return this;
    }

    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        print('✅ Update available - showing native prompt');
        await InAppUpdate.performImmediateUpdate();
      } else {
        print('✅ No update available');
      }
    } catch (e) {
      print('❌ Error checking for updates: $e');
    }
    return this;
  }
}
