// import 'package:kita_traveler/core/constants/extension.dart';
//
// import '../../export.dart';
//
// class CustomDatePicker extends StatefulWidget {
//   const CustomDatePicker({super.key});
//
//   @override
//   State<CustomDatePicker> createState() => _CustomDatePickerState();
// }
//
// class _CustomDatePickerState extends State<CustomDatePicker> {
//   DateTime currentMonth = DateTime(2024, 11);
//   DateTime selectedDate = DateTime.now();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade200,
//       body: Center(
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           margin: const EdgeInsets.all(15),
//           decoration: BoxDecoration(
//             color: Colors.orange.shade50,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 "From",
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.orange,
//                 ),
//               ),
//               _buildHeader(),
//               _buildCalendarWithLines(),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   Get.log("Selected Date: $selectedDate");
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.orange,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                 ),
//                 child: const Text(
//                   "Done",
//                   style: TextStyle(fontSize: 16, color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         IconButton(
//           onPressed: () {
//             setState(() {
//               currentMonth =
//                   DateTime(currentMonth.year, currentMonth.month - 1);
//             });
//           },
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
//         ),
//         Text(
//           "${_monthName(currentMonth.month)} ${currentMonth.year}",
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         IconButton(
//           onPressed: () {
//             setState(() {
//               currentMonth =
//                   DateTime(currentMonth.year, currentMonth.month + 1);
//             });
//           },
//           icon: const Icon(Icons.arrow_forward_ios, color: Colors.black54),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildCalendarWithLines() {
//     return Stack(
//       children: [
//         CustomPaint(
//           size: const Size(double.infinity, 320),
//           painter: GridLinesPainter(),
//         ),
//         _buildCalendarContent(),
//       ],
//     );
//   }
//
//   Widget _buildCalendarContent() {
//     final daysInMonth =
//         DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
//     final firstWeekday =
//         DateTime(currentMonth.year, currentMonth.month, 1).weekday % 7;
//
//     List<Widget> calendarDays = [];
//
//     // Weekdays Row
//     final weekdays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
//     calendarDays.addAll(weekdays.map(
//       (day) => Column(
//         children: [
//           const SizedBox(
//             height: 27, // Increased height for better spacing
//           ),
//           Text(
//             day,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//     ));
//
//     // Empty Containers for Offset Before First Day
//     for (int i = 0; i < firstWeekday; i++) {
//       calendarDays.add(Container());
//     }
//
//     for (int day = 1; day <= daysInMonth; day++) {
//       //final isToday = DateTime.now().day == day &&
//           DateTime.now().month == currentMonth.month &&
//           DateTime.now().year == currentMonth.year;
//
//       calendarDays.add(
//         GestureDetector(
//           onTap: () {
//             setState(() {
//               selectedDate =
//                   DateTime(currentMonth.year, currentMonth.month, day);
//             });
//           },
//           child: Column(
//             children: [
//               5.0.addHSpace(),
//               Container(
//                 height: 43,
//                 // Increased height of the container
//                 width: 43,
//                 // Increased width of the container
//                 margin: const EdgeInsets.symmetric(vertical: 3),
//                 // Adjusted margin for better spacing
//                 decoration: BoxDecoration(
//                   color: selectedDate.day == day &&
//                           selectedDate.month == currentMonth.month &&
//                           selectedDate.year == currentMonth.year
//                       ? Colors.orange
//                       : Colors.transparent,
//                   borderRadius:
//                       BorderRadius.circular(8), // Slightly rounded corners
//                 ),
//                 alignment: Alignment.center,
//                 child: Text(
//                   "$day",
//                   style: TextStyle(
//                     color:
//                         selectedDate.day == day ? Colors.white : Colors.black,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return GridView.count(
//       crossAxisCount: 7,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       children: calendarDays,
//     );
//   }
//
//   String _monthName(int month) {
//     const months = [
//       "January",
//       "February",
//       "March",
//       "April",
//       "May",
//       "June",
//       "July",
//       "August",
//       "September",
//       "October",
//       "November",
//       "December"
//     ];
//     return months[month - 1];
//   }
// }
//
// class GridLinesPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.black.withValues(alpha:0.20)
//       ..strokeWidth = 1;
//
//     final double rowHeight = size.height / 7; // Reduced rows
//     final double columnWidth = size.width / 7; // Reduced columns
//
//     for (int i = 1; i <= 7; i++) {
//       canvas.drawLine(
//         Offset(0, i * rowHeight),
//         Offset(size.width, i * rowHeight),
//         paint,
//       );
//     }
//
//     for (int i = 0; i <= 7; i++) {
//       canvas.drawLine(
//         Offset(i * columnWidth, 45),
//         Offset(i * columnWidth, size.height),
//         paint,
//       );
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
