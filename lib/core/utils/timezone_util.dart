/// Utility class for handling timezone-related functionality
/// 
/// This provides a centralized place for date handling in the app, making it
/// easier to modify timezone behavior in the future if needed.
class TimezoneUtil {
  
  /// Manually parse a date string, treating the time part as local time
  /// regardless of any timezone indicators like 'Z'
  static DateTime? parseAsLocalTime(String? dateString) {
    if (dateString == null) return null;
    
    try {
      // Remove the Z suffix or any timezone indicator
      String cleanDateString = dateString;
      if (cleanDateString.endsWith('Z')) {
        cleanDateString = cleanDateString.substring(0, cleanDateString.length - 1);
      }
      
      // Extract just the date and time parts
      RegExp dateTimeRegex = RegExp(r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})');
      var match = dateTimeRegex.firstMatch(cleanDateString);
      if (match != null) {
        String dateTimePart = match.group(1)!;
        
        // Split into components
        List<String> dateParts = dateTimePart.split('T')[0].split('-');
        List<String> timeParts = dateTimePart.split('T')[1].split(':');
        
        int year = int.parse(dateParts[0]);
        int month = int.parse(dateParts[1]);
        int day = int.parse(dateParts[2]);
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        int second = int.parse(timeParts[2]);
        
        // Create a local DateTime with these values
        return DateTime(year, month, day, hour, minute, second);
      }
      
      // Fallback to default parsing if regex fails
      return DateTime.parse(cleanDateString);
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }
  // Flag to enable detailed debugging (disabled in production)
  static bool debugMode = false;
  
  /// Returns the current datetime
  /// 
  /// Returns the device's local time without any conversion
  static DateTime getCurrentTime() {
    final now = DateTime.now();
    
    if (debugMode) {
      // Debug timezone information
      print('🕒 TIMEZONE INFORMATION:');
      print('📱 Device timezone offset: ${now.timeZoneOffset.inHours}h ${now.timeZoneOffset.inMinutes % 60}m');
      print('📱 Local DateTime: $now');
      print('🌐 UTC DateTime: ${now.toUtc()}');
      print('🔄 Is device in Bangladesh timezone: ${isDeviceInBangladeshTimezone() ? 'YES' : 'NO'}');
    }
    
    return now;
  }
  
  /// Converts a UTC datetime string to local time
  /// 
  /// This method explicitly handles UTC to local time conversion
  static DateTime? convertUtcToLocal(String? utcDateString) {
    if (utcDateString == null) return null;
    
    try {
      // Parse the UTC date string
      final dateUtc = DateTime.parse(utcDateString);
      
      // Convert to local time
      final localTime = dateUtc.toLocal();
      
      if (debugMode) {
        print('🔄 TIMEZONE CONVERSION:');
        print('🌐 Original UTC time: $dateUtc');
        print('📱 Converted to local: $localTime');
      }
      
      return localTime;
    } catch (e) {
      print('⚠️ Error converting UTC time to local: $e');
      return null;
    }
  }
  
  /// Get detailed timezone information as a formatted string
  static String getDeviceTimezoneInfo() {
    final now = DateTime.now();
    final utc = now.toUtc();
    final offset = now.timeZoneOffset;
    final bangladeshTime = _getBangladeshTime();
    
    return '''
    📱 TIMEZONE DEBUG INFO:
    Local time: $now
    UTC time: $utc
    Device offset: ${offset.inHours}h ${offset.inMinutes % 60}m
    Bangladesh time (GMT+6): $bangladeshTime
    Is device in Bangladesh timezone: ${isDeviceInBangladeshTimezone() ? 'Yes' : 'No'}
    ''';
  }
  
  /// Format a datetime for display, optionally including the timezone label
  static String formatDateTime(DateTime? dateTime, {bool showTimezone = false}) {
    if (dateTime == null) return '';
    
    final formattedDate = '${dateTime.year}-${_pad(dateTime.month)}-${_pad(dateTime.day)} '
        '${_pad(dateTime.hour)}:${_pad(dateTime.minute)}';
    
    return showTimezone ? '$formattedDate (GMT+6)' : formattedDate;
  }
  
  /// Compare two dates and provide debug info about the comparison
  static bool compareDates(DateTime date1, DateTime date2, {String label = 'Date comparison'}) {
    final result = date1.isAtSameMomentAs(date2);
    
    if (debugMode) {
      print('📅 $label:');
      print('  Date 1: $date1');
      print('  Date 2: $date2');
      print('  Equal: ${result ? 'YES' : 'NO'}');
      
      if (!result) {
        final difference = date1.difference(date2);
        print('  Difference: ${_formatDuration(difference)}');
      }
    }
    
    return result;
  }
  
  /// Log details about a date in relation to now
  static void logDateRelationToNow(DateTime date, {String label = 'Date'}) {
    final now = getCurrentTime();
    final difference = date.difference(now);
    
    print('⏰ $label time relation:');
    print('  Now: $now');
    print('  $label: $date');
    if (date.isAfter(now)) {
      print('  Status: FUTURE - ${_formatDuration(difference)} from now');
    } else if (date.isBefore(now)) {
      print('  Status: PAST - ${_formatDuration(difference.abs())} ago');
    } else {
      print('  Status: SAME MOMENT');
    }
  }
  
  /// Check if device is in GMT+6 timezone (Bangladesh)
  static bool isDeviceInBangladeshTimezone() {
    final offset = DateTime.now().timeZoneOffset;
    return offset.inHours == 6 && offset.inMinutes % 60 == 0;
  }
  
  /// Calculate the current time in Bangladesh (GMT+6)
  static DateTime _getBangladeshTime() {
    final utcNow = DateTime.now().toUtc();
    return utcNow.add(Duration(hours: 6));
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
  
  // Helper to pad single digits with leading zero
  static String _pad(int number) => number.toString().padLeft(2, '0');
}