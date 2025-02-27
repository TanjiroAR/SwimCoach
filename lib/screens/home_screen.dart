import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:SwimCoach/data/db.dart';

import '../constants.dart';
import 'swim_profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String currentDay; // يحتوي على اسم اليوم الحالي
  SqlDb sqlDb = SqlDb();
  DateTime myDay = DateTime.now();
  Future<List<Map>> readData(String currentDay) async {
    List<Map> response = await sqlDb.readData("SELECT * FROM $currentDay");
    return response;
  }

  Future<List<Map<String, dynamic>>> fetchRacesHappeningToday() async {
    final currentDate = DateFormat('yyyy-MM-dd').format(myDay);
    debugPrint("جاري البحث عن سباقات بتاريخ: $currentDate"); // ✔️

    List<Map<String, dynamic>> raceDataList = [];

    for (String race in SqlDb.races) {
      final query = '''
      SELECT * FROM $race 
      WHERE date = '$currentDate'
    ''';

      debugPrint("الاستعلام: $query"); // ✔️

      List<Map> results = await sqlDb.readData(query);
      debugPrint("النتائج لجدول $race: ${results.length}"); // ✔️

      raceDataList.addAll(results.cast<Map<String, dynamic>>());
    }

    return raceDataList;
  }

  Future<void> _refreshData() async {
    setState(() {
      getCurrentDay();
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentDay();
  }

  // دالة لتحديد اليوم الحالي
  void getCurrentDay() {
    final formatter = DateFormat('EEEE', 'en_US'); // إجباري استخدام الإنجليزية
    currentDay = formatter.format(DateTime.now()).toLowerCase();
    setState(() {});
  }


  // الدالة للحصول على اسم اليوم باللغة العربية
  String getArabicDayName(String currentDay) {
    switch (currentDay) {
      case "monday":
        return 'الاثنين';
      case "tuesday":
        return 'الثلاثاء';
      case "wednesday":
        return 'الأربعاء';
      case "thursday":
        return 'الخميس';
      case "friday":
        return 'الجمعة';
      case "saturday":
        return 'السبت';
      case "sunday":
      default:
        return 'الأحد';
    }
  }

  // عرض التقويم وتحديث اليوم الحالي عند اختيار تاريخ جديد
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: myDay,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != myDay) {
      setState(() {
        myDay = pickedDate;
        currentDay = DateFormat('EEEE', 'en_US').format(pickedDate).toLowerCase(); // الإنجليزية إجباري
      });

      // إعادة تحميل البيانات بعد تغيير التاريخ
      _refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refreshData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                title: const CustomText(
                    text: 'الرئيسية', fontWeight: FontWeight.bold),
                centerTitle: true,
                expandedHeight: screenHeight * 0.2,
                pinned: true,
                floating: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top * 4),
                    child: Center(
                        child: CustomText(
                            text: getArabicDayName(currentDay),
                            fontWeight: FontWeight.normal)),
                  ),
                ),
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchRacesHappeningToday(),
                key: ValueKey<DateTime>(myDay),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverList(
                      delegate: SliverChildListDelegate([]),
                    );
                  } else if (snapshot.hasError) {
                    return SliverList(
                      delegate: SliverChildListDelegate([]),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return SliverList(
                      delegate: SliverChildListDelegate([]),
                    );
                  } else {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          Map<String, dynamic> swimmer = snapshot.data![index];
                          return Card(
                            child: ListTile(
                              title: Text(swimmer['swimmerName']),
                              subtitle: Text(swimmer['time']),
                              trailing: Column(
                                children: [
                                  const Icon(Icons.emoji_events, color: Colors.yellowAccent),
                                  Text(swimmer['champName'] ?? 'لا يوجد بطولة'),
                                ],
                              ),

                            ),
                          );
                        },
                        childCount: snapshot.data!.length,
                      ),
                    );
                  }
                },
              ),
              FutureBuilder<List<Map>>(
                future: readData(currentDay),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CustomText(
                            text: 'حدث خطأ أثناء جلب البيانات',
                            fontWeight: FontWeight.normal),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    List<Map>? data = snapshot.data;
                    if (data == null || data.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: CustomText(
                              text: 'لا يوجد سباحين اليوم',
                              fontWeight: FontWeight.normal),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          Map swimmerData = data[index];
                          return Card(
                            child: ListTile(
                              title: Text(swimmerData['swimmerName']
                                  .toString()), // عرض اسم السباح
                              subtitle: Text(
                                  swimmerData['time'].toString()), // عرض الوقت
                              leading: Icon(
                                Icons.circle,
                                color: swimmerData['come'] == 1 // إذا كانت القيمة رقم
                                    ? Colors.lightGreen
                                    : Colors.white,
                              ),
                              onTap: () {
                                final now = DateTime.now(); // الوقت الحالي
                                final formatter = DateFormat(
                                    'EEEE'); // تنسيق اليوم كامل (مثل الاثنين، الثلاثاء، الخ)
                                String day =
                                    formatter.format(now).toLowerCase();
                                if (kDebugMode) {
                                  print(swimmerData['come']);
                                }
                                if (swimmerData['come'] == "true" &&
                                    day == currentDay) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return SwimmerDetailsScreen(
                                          swimmerName:
                                              swimmerData['swimmerName']
                                                  .toString(),
                                          inDay: true,
                                          come: true,
                                        );
                                      },
                                    ),
                                  ).then((_) {
                                    _refreshData();
                                  });
                                } else if (swimmerData['come'] == "false" &&
                                    day == currentDay) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return SwimmerDetailsScreen(
                                          swimmerName:
                                              swimmerData['swimmerName']
                                                  .toString(),
                                          inDay: true,
                                          come: false,
                                        );
                                      },
                                    ),
                                  ).then((_) {
                                    _refreshData();
                                  });
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return SwimmerDetailsScreen(
                                          swimmerName:
                                              swimmerData['swimmerName']
                                                  .toString(),
                                          inDay: false,
                                          come: false,
                                        );
                                      },
                                    ),
                                  ).then((_) {
                                    _refreshData();
                                  });
                                }
                              },
                            ),
                          );
                        },
                        childCount: data.length,
                      ),
                    );
                  } else {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CustomText(
                            text: 'لا توجد بيانات',
                            fontWeight: FontWeight.normal),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        // Text("HI"),
        Positioned(
          bottom: 80, // ابتعد عن الحافة السفلية
          right: 24,
          child: FloatingActionButton(
            onPressed: () {
              debugPrint("تم الضغط على الزر!"); // تأكد من ظهور هذه الرسالة في الكونسول
              _pickDate(context);
            },
            tooltip: 'اختر تاريخ',
            child: const Icon(Icons.calendar_today),
          ),
        )
      ],
    );
  }
}
