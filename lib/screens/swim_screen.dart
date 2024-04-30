import 'package:flutter/material.dart';
import 'package:SwimCoach/constants.dart';
import 'package:SwimCoach/data/db.dart';
import 'package:SwimCoach/widgets/edit_swimmer.dart';

import '../widgets/swim_bottom_sheet.dart';
import 'swim_profile_screen.dart';

class SwimPage extends StatefulWidget {
  const SwimPage({super.key});

  @override
  State<SwimPage> createState() => _SwimPageState();
}

class _SwimPageState extends State<SwimPage> {
  SqlDb sqlDb = SqlDb();
  DateTime selectedDate = DateTime.now();
  // bool isSelected = false;
  Future<List<Map<String, dynamic>>?> readData() async {
    List<Map<String, dynamic>>? response =
        await sqlDb.readData("SELECT * FROM 'swimmer'");
    return response;
  }

  Future<List<String>> getRegisteredDays(String swimmerName) async {
    List<String> registeredDays = [];
    String query = '''
    SELECT monday, tuesday, wednesday, thursday, friday, saturday, sunday 
    FROM swimmer
    WHERE name = "$swimmerName"
  ''';
    List<Map<String, dynamic>> daysOfWeek = [
      {
        'monday': 'الاثنين',
        'tuesday': 'الثلاثاء',
        'wednesday': 'الاربعاء',
        'thursday': 'الخميس',
        'friday': 'الجمعة',
        'saturday': 'السبت',
        'sunday': 'الأحد'
      }
    ];
    List<Map<String, dynamic>> result = await sqlDb.readData(query);
    if (result.isNotEmpty) {
      Map<String, dynamic> swimmerData = result.first;
      swimmerData.forEach((day, time) {
        if (time != null && time.isNotEmpty) {
          registeredDays.add(daysOfWeek[0][day]);
        }
      });
    }
    return registeredDays;
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refreshData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                title: const CustomText(
                    text: 'السباحون', fontWeight: FontWeight.bold),
                centerTitle: true,
                expandedHeight: screenHeight * 0.2,
                pinned: true,
                floating: false,
              ),
              FutureBuilder<List<Map<String, dynamic>>?>(
                future: readData(),
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
                    List<Map<String, dynamic>>? data = snapshot.data;
                    if (data == null || data.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: CustomText(
                              text: 'لا يوجد سباحين',
                              fontWeight: FontWeight.normal),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          Map<String, dynamic> swimmerData = data[index];
                          return Card(
                            child: ListTile(
                              title: Text(swimmerData['name'].toString()),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("العمر: ${swimmerData['age']}"),
                                  FutureBuilder<List<String>>(
                                    future: getRegisteredDays(
                                        swimmerData['name'].toString()),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return const CustomText(
                                            text: 'حدث خطأ أثناء جلب البيانات',
                                            fontWeight: FontWeight.normal);
                                      } else if (snapshot.hasData) {
                                        List<String> registeredDays =
                                            snapshot.data!;
                                        return Text(
                                            'الأيام المسجلة: ${registeredDays.join(', ')}');
                                      } else {
                                        return const CustomText(
                                            text: 'لا توجد بيانات',
                                            fontWeight: FontWeight.normal);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    useSafeArea: true,
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return  EditSwimmer(name: swimmerData["name"], age: swimmerData["age"]);
                                    },
                                  );
                                },
                                icon: const Icon(Icons.edit),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return SwimmerDetailsScreen(
                                        swimmerName:
                                            swimmerData['name'].toString(),
                                        inDay: false,
                                        come: false,
                                      );
                                    },
                                  ),
                                );
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
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 16.0,
          right: MediaQuery.of(context).padding.right + 16.0,
          child: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                useSafeArea: true,
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return const AddSwimmerBottomSheet();
                },
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
