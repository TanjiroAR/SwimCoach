import 'package:flutter/material.dart';

class DateSelectionPage extends StatefulWidget {
  const DateSelectionPage({super.key});

  @override
  State<DateSelectionPage> createState() => _DateSelectionPageState();
}

class _DateSelectionPageState extends State<DateSelectionPage> {
  DateTime? _firstDate;
  DateTime? _lastDate;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  void _selectFirstDate(BuildContext context) async {
    final DateTime? pickedFirstDate = await showDatePicker(
      context: context,
      initialDate: _firstDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: _lastDate ?? DateTime.now(),
    );

    if (pickedFirstDate != null) {
      setState(() {
        _firstDate = pickedFirstDate;
      });
    }
  }

  void _selectLastDate(BuildContext context) async {
    final DateTime? pickedLastDate = await showDatePicker(
      context: context,
      initialDate: _lastDate ?? DateTime.now(),
      firstDate: _firstDate ?? DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedLastDate != null) {
      setState(() {
        _lastDate = pickedLastDate;
      });
    }
  }

  void _showCalendar(BuildContext context) {
    if (_firstDate != null && _lastDate != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Select Dates"),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(
                    _lastDate!.difference(_firstDate!).inDays + 1,
                        (index) {
                      DateTime date = _firstDate!.add(Duration(days: index));
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (_selectedStartDate == null) {
                              _selectedStartDate = date;
                            } else if (_selectedEndDate == null) {
                              _selectedEndDate = date;
                            } else {
                              _selectedStartDate = date;
                              _selectedEndDate = null;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            color: (_selectedStartDate != null && date == _selectedStartDate) ||
                                (_selectedEndDate != null && date == _selectedEndDate) ||
                                (date.isAfter(_selectedStartDate ?? DateTime.now()) &&
                                    date.isBefore(_selectedEndDate ?? DateTime.now()))
                                ? Colors.blue
                                : null,
                          ),
                          child: Text("${date.day}/${date.month}/${date.year}"),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("Please select both start and end dates first."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Date Selection")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _selectFirstDate(context),
              child: Text(_firstDate == null ? "Select First Date" : "First Date: ${_firstDate!.day}/${_firstDate!.month}/${_firstDate!.year}"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _selectLastDate(context),
              child: Text(_lastDate == null ? "Select Last Date" : "Last Date: ${_lastDate!.day}/${_lastDate!.month}/${_lastDate!.year}"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showCalendar(context),
              child: const Text("Show Calendar"),
            ),
          ],
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:swimming/data/db.dart';
//
// import '../constants.dart';
// import '../widgets/slivrt_app_bar_delegate.dart';
//
// class NewSwimmerDetailsScreen extends StatefulWidget {
//   final String swimmerName;
//   final bool inDay;
//   final bool come;
//   const NewSwimmerDetailsScreen(
//       {super.key,
//       required this.inDay,
//       required this.come,
//       required this.swimmerName});
//   @override
//   State<NewSwimmerDetailsScreen> createState() =>
//       _NewSwimmerDetailsScreenState();
// }
//
// class _NewSwimmerDetailsScreenState extends State<NewSwimmerDetailsScreen> {
//   SqlDb sqlDb = SqlDb();
//   late bool _come;
//   Map<String, TimeOfDay> selectedDays = {};
//
//   List<Map<String, String>> daysOfWeek = [
//     {
//       'Sunday': 'الأحد',
//       'Monday': 'الاثنين',
//       'Tuesday': 'الثلاثاء',
//       'Wednesday': 'الاربعاء',
//       'Thursday': 'الخميس',
//       'Friday': 'الجمعة',
//       'Saturday': 'السبت'
//     }
//   ];
//   Future<List<String>> getRegisteredDays() async {
//     List<String> registeredDays = [];
//     String query = '''
//     SELECT monday, tuesday, wednesday, thursday, friday, saturday, sunday
//     FROM swimmer
//     WHERE name = "${widget.swimmerName}"
//     ''';
//     List<Map<String, dynamic>> result = await sqlDb.readData(query);
//     if (result.isNotEmpty) {
//       Map<String, dynamic> swimmerData = result.first;
//       swimmerData.forEach((day, time) {
//         if (time != null && time.isNotEmpty) {
//           if (day == "monday") {
//             registeredDays.add("الاثنين");
//           } else if (day == "tuesday") {
//             registeredDays.add("الثلاثاء");
//           } else if (day == "wednesday") {
//             registeredDays.add("الاربعاء");
//           } else if (day == "thursday") {
//             registeredDays.add("الخميس");
//           } else if (day == "friday") {
//             registeredDays.add("الجمعة");
//           } else if (day == "saturday") {
//             registeredDays.add("السبت");
//           } else if (day == "sunday") {
//             registeredDays.add("الأحد");
//           }
//         }
//       });
//     }
//     return registeredDays;
//   }
//
//   Future<Map<String, dynamic>> getSwimmerData() async {
//     String query = '''
//     SELECT *
//     FROM swimmer
//     WHERE name = "${widget.swimmerName}"
//     ''';
//     List<Map<String, dynamic>> result = await sqlDb.readData(query);
//     return result.isNotEmpty ? result.first : {};
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _come = widget.come;
//   }
//
//   Future<void> _refreshData() async {
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     double screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       floatingActionButton: Padding(
//         padding: EdgeInsets.only(
//           left: screenWidth * 0.07,
//           bottom: screenHeight * 0.05,
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             FloatingActionButton(
//               heroTag: 'uniqueTag1',
//               onPressed: () {
//                 _recordDialog(context, "إضافة رقم جديد", true);
//               },
//               child: const Icon(Icons.add),
//             ),
//             FloatingActionButton(
//               heroTag: 'uniqueTag2',
//               onPressed: () {},
//               child: const Icon(Icons.auto_graph),
//             ),
//           ],
//         ),
//       ),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage("images/sw1.jpg"),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Container(
//           width: double.infinity,
//           height: double.infinity,
//           color: Theme.of(context).colorScheme.background.withOpacity(0.7),
//           child: Stack(
//             children: [
//               RefreshIndicator(
//                 onRefresh: _refreshData,
//                 child: CustomScrollView(
//                   physics: const AlwaysScrollableScrollPhysics(),
//                   slivers: [
//                     SliverAppBar(
//                       centerTitle: true,
//                       actions: [
//                         IconButton(
//                             onPressed: () {}, icon: const Icon(Icons.delete))
//                       ],
//                       backgroundColor: Colors.transparent,
//                       title: CustomText(
//                           text: widget.swimmerName,
//                           fontWeight: FontWeight.bold),
//                       expandedHeight: screenHeight * 0.3,
//                       pinned: true,
//                       floating: false,
//                       flexibleSpace: FlexibleSpaceBar(
//                         background: Container(
//                           padding: EdgeInsets.only(
//                               top: MediaQuery.of(context).padding.top * 5),
//                           child: Center(
//                             child: _buildAvatar(),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SliverPersistentHeader(
//                       delegate: SliverAppBarDelegate(
//                         minHeight: screenWidth * 0.35,
//                         maxHeight: screenHeight * 0.1,
//                         child: Center(
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               children: [
//                                 SizedBox(
//                                   height: screenHeight * 0.01,
//                                 ),
//                                 _buildInfoRow(
//                                     ": العمر",
//                                     screenWidth,
//                                     getSwimmerData()
//                                         .then((data) => data["age"])),
//                                 SizedBox(
//                                   height: screenHeight * 0.03,
//                                 ),
//                                 _buildInfoRow(
//                                     ": الجنس",
//                                     screenWidth,
//                                     getSwimmerData()
//                                         .then((data) => data["gender"])),
//                                 SizedBox(
//                                   height: screenHeight * 0.03,
//                                 ),
//                                 _buildTrainingDay(),
//                                 SizedBox(
//                                   height: screenHeight * 0.03,
//                                 ),
//                                 Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     _buildRacesDropDown(),
//                                     const CustomText(
//                                         text: ": الارقام المسجلة ",
//                                         fontWeight: FontWeight.normal),
//                                   ],
//                                 ),
//                                 SizedBox(
//                                   height: screenHeight * 0.03,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       pinned: true,
//                     ),
//                     const SliverFillRemaining(
//                       child: Center(
//                         child: CustomText(
//                             text: 'لا توجد بيانات',
//                             fontWeight: FontWeight.normal),
//                       ),
//                     )
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: widget.inDay
//           ? ElevatedButton(
//               style: ButtonStyle(
//                 backgroundColor:
//                     _come ? MaterialStateProperty.all(Colors.lightGreen) : null,
//                 foregroundColor: MaterialStateProperty.all(
//                     Theme.of(context).textTheme.bodyLarge!.color),
//               ),
//               onPressed: _come
//                   ? null
//                   : () {
//                       setState(() {
//                         _come = true;
//                       });
//                     },
//               child: CustomText(
//                 text: _come ? 'تم التسجيل' : 'تسجيل الحضور',
//                 fontWeight: FontWeight.normal,
//               ),
//             )
//           : null,
//     );
//   }
//
//   Widget _buildInfoRow(
//       String title, double screenWidth, Future<dynamic> futureData) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         SizedBox(
//           width: screenWidth * 0.1,
//         ),
//         FutureBuilder<dynamic>(
//           future: futureData,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const CircularProgressIndicator();
//             } else if (snapshot.hasError) {
//               return const CustomText(
//                 text: 'حدث خطأ أثناء جلب البيانات',
//                 fontWeight: FontWeight.normal,
//               );
//             } else {
//               return CustomText(
//                   text: snapshot.data, fontWeight: FontWeight.bold);
//             }
//           },
//         ),
//         CustomText(text: title, fontWeight: FontWeight.bold),
//       ],
//     );
//   }
//
//   void _showDaysDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('حدد مواعيد التدريب'),
//           content: SizedBox(
//             width: double.maxFinite,
//             child: ListView.builder(
//               shrinkWrap: true,
//               itemCount: daysOfWeek[0].values.toList().length,
//               itemBuilder: (BuildContext context, int index) {
//                 final String dayAR = daysOfWeek[0].values.toList()[index];
//                 final String dayEN = daysOfWeek[0].keys.toList()[index];
//                 final bool isSelected = selectedDays.containsKey(dayEN);
//                 final String timeText = selectedDays.containsKey(dayEN)
//                     ? selectedDays[dayEN]!.format(context)
//                     : '';
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     ListTile(
//                       title: Text(dayAR),
//                       trailing: isSelected
//                           ? IconButton(
//                               icon: const Icon(Icons.delete),
//                               onPressed: () {
//                                 setState(() {
//                                   selectedDays.remove(dayEN);
//                                 });
//                                 Navigator.of(context).pop();
//                                 _showDaysDialog(context);
//                               },
//                             )
//                           : null,
//                       onTap: () async {
//                         if (!isSelected) {
//                           final TimeOfDay selectedTime =
//                               await _showTimePicker(context);
//                           setState(() {
//                             selectedDays[dayEN] = selectedTime;
//                           });
//                         }
//                         Navigator.of(context).pop();
//                       },
//                       selected: isSelected,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 16.0),
//                       child: Text(
//                         timeText,
//                         style: TextStyle(
//                           color: Theme.of(context).colorScheme.primary,
//                           fontStyle:
//                               isSelected ? FontStyle.normal : FontStyle.italic,
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Future<TimeOfDay> _showTimePicker(BuildContext context) async {
//     final TimeOfDay? picked =
//         await showTimePicker(context: context, initialTime: TimeOfDay.now());
//     return picked ?? TimeOfDay.now();
//   }
// }

// FutureBuilder<List<Map>>(
//   future: readData(),
//   builder: (context, snapshot) {
//     if (snapshot.connectionState ==
//         ConnectionState.waiting) {
//       return const SliverFillRemaining(
//         child: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     } else if (snapshot.hasError) {
//       return const SliverFillRemaining(
//         child: Center(
//           child: CustomText(
//             text: 'حدث خطأ أثناء جلب البيانات',
//             fontWeight: FontWeight.normal,
//           ),
//         ),
//       );
//     } else {
//       final List<Map>? data = snapshot.data;
//       List<Map> filteredList = data!
//           .where((element) => element[raceName] != null)
//           .toList();
//       if (kDebugMode) {
//         print("$data#############################");
//       }
//       if (filteredList.isEmpty || data.isEmpty) {
//         return const SliverFillRemaining(
//           child: Center(
//             child: CustomText(
//               text: 'لا توجد بيانات لهذا السباق',
//               fontWeight: FontWeight.normal,
//             ),
//           ),
//         );
//       }
//       else {
//         List<Map> modifiableList = List<Map>.from(data);
//         modifiableList.sort((a, b) {
//           var adate =
//               DateFormat('dd/MM/yyyy').parse(a["date"]);
//           var bdate =
//               DateFormat('dd/MM/yyyy').parse(b["date"]);
//           return bdate.compareTo(adate);
//         });
//
//         return SliverList(
//           delegate: SliverChildBuilderDelegate(
//             (BuildContext context, int index) {
//               if(modifiableList[index][raceName] == null){
//                 return const SizedBox();
//               }
//               else{
//                 return Center(
//                   child: Dismissible(
//                     key: Key(modifiableList[index]['id']
//                         .toString()),
//                     direction: DismissDirection.endToStart,
//                     confirmDismiss: (direction) async {
//                       final bool res = await showDialog(
//                         context: context,
//                         builder:
//                             (BuildContext dialogContext) {
//                           return AlertDialog(
//                             title: const Text('تأكيد الحذف'),
//                             content: const Text(
//                               'هل أنت متأكد من أنك تريد حذف هذا السجل؟',
//                             ),
//                             actions: <Widget>[
//                               TextButton(
//                                 onPressed: () => Navigator.of(
//                                     dialogContext)
//                                     .pop(false),
//                                 child: const Text('الغاء'),
//                               ),
//                               TextButton(
//                                 onPressed: () => Navigator.of(
//                                     dialogContext)
//                                     .pop(true),
//                                 child: const Text('تم'),
//                               ),
//                             ],
//                           );
//                         },
//                       );
//                       return res;
//                     },
//                     onDismissed: (direction) async {
//                       String tableName = widget.swimmerName
//                           .replaceAll(RegExp(r'\s+'), '');
//                       await sqlDb.updateData(
//                         '''
//                         UPDATE $tableName
//                         SET $raceName = NULL
//                         WHERE date = '${modifiableList[index]["date"]}'
//                       ''',
//                       );
//                       setState(() {
//                         modifiableList.removeAt(index);
//                       });
//                     },
//                     background: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.red,
//                         borderRadius:
//                         BorderRadius.circular(4.0),
//                       ),
//                       alignment: Alignment.centerRight,
//                       padding:
//                       const EdgeInsets.only(right: 20),
//                       child: const Icon(Icons.delete,
//                           color: Colors.white),
//                     ),
//                     child: Card(
//                       child: ListTile(
//                         title: Text(
//                             "${modifiableList[index][raceName]}"),
//                         subtitle: Text(
//                             "${modifiableList[index]["date"]}"),
//                         trailing: IconButton(
//                           onPressed: () {
//                             setState(() {
//                               currentDay =
//                                   modifiableList[index]
//                                   ["date"]
//                                       .toString();
//                             });
//                             _recordDialog(context,
//                                 "تعديل الرقم", false);
//                           },
//                           icon: const Icon(Icons.edit),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               }
//             },
//             childCount: modifiableList.length,
//           ),
//         );
//       }
//     }
//   },
// ),
