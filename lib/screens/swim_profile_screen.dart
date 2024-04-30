import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:SwimCoach/constants.dart';
import 'package:SwimCoach/widgets/line_chart_dialog.dart';

import '../data/db.dart';
import '../widgets/slivrt_app_bar_delegate.dart';

class SwimmerDetailsScreen extends StatefulWidget {
  final String swimmerName;
  final bool inDay;
  final bool come;
  const SwimmerDetailsScreen(
      {super.key,
      required this.swimmerName,
      required this.inDay,
      required this.come});

  @override
  State<SwimmerDetailsScreen> createState() => _SwimmerDetailsScreenState();
}

class _SwimmerDetailsScreenState extends State<SwimmerDetailsScreen> {
  late bool _come;
  final SqlDb sqlDb = SqlDb();
  final TextEditingController _minuteController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  final TextEditingController _millisecondController = TextEditingController();

  @override
  void dispose() {
    _minuteController.dispose();
    _secondController.dispose();
    _millisecondController.dispose();
    super.dispose();
  }

  Map<String, TimeOfDay> selectedDays = {};
  List<Map<String, String>> daysOfWeek = [
    {
      'Sunday': 'الأحد',
      'Monday': 'الاثنين',
      'Tuesday': 'الثلاثاء',
      'Wednesday': 'الاربعاء',
      'Thursday': 'الخميس',
      'Friday': 'الجمعة',
      'Saturday': 'السبت'
    }
  ];
  int _selectedMinute = 0;
  int _selectedSecond = 0;
  int _selectedMillisecond = 0;

  late String? _selectedLetter;
  late String raceName = races[0][_selectedLetter] ?? '';
  List<String> raceDates = [];
  late String currentDay;
  late String _day;
  Future<void> _refreshData() async {
    setState(() {});
  }

  Future<List<String>> getRegisteredDays() async {
    List<String> registeredDays = [];
    String query = '''
    SELECT monday, tuesday, wednesday, thursday, friday, saturday, sunday
    FROM swimmer
    WHERE name = "${widget.swimmerName}"
    ''';
    List<Map<String, dynamic>> result = await sqlDb.readData(query);
    if (result.isNotEmpty) {
      Map<String, dynamic> swimmerData = result.first;
      swimmerData.forEach((day, time) {
        if (time != null && time.isNotEmpty) {
          if (day == "monday") {
            registeredDays.add('الاثنين');
          } else if (day == "tuesday") {
            registeredDays.add('الثلاثاء');
          } else if (day == "wednesday") {
            registeredDays.add('الاربعاء');
          } else if (day == "thursday") {
            registeredDays.add('الخميس');
          } else if (day == "friday") {
            registeredDays.add('الجمعة');
          } else if (day == "saturday") {
            registeredDays.add('السبت');
          } else if (day == "sunday") {
            registeredDays.add('الأحد');
          }
        }
      });
    }
    return registeredDays;
  }

  Future<Map<String, dynamic>> getSwimmerData() async {
    String query = '''
    SELECT *
    FROM swimmer
    WHERE name = "${widget.swimmerName}"
    ''';
    List<Map<String, dynamic>> result = await sqlDb.readData(query);
    return result.isNotEmpty ? result.first : {};
  }

  void getCurrentDay() {
    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy');
    final day = DateFormat('EEEE');
    final formattedDate = formatter.format(now);
    currentDay = formattedDate.toString();
    _day = day.format(now).toLowerCase();
    setState(() {});
  }

  Future<List<Map>> readData() async {
    String tableName = widget.swimmerName.replaceAll(RegExp(r'\s+'), '');
    List<Map> response = await sqlDb.readData('''
      SELECT * FROM $tableName
      ''');
    return response;
  }

  @override
  void initState() {
    super.initState();
    _come = widget.come;
    _selectedLetter = races[0].keys.first;
    getCurrentDay();
  }

  bool dayHasData = false;
  Future<List<Map>> readDataLineChart() async {
    String tableName = widget.swimmerName.replaceAll(RegExp(r'\s+'), '');
    List<Map> response = await sqlDb.readData('''
    SELECT date, $raceName FROM $tableName
    ''');
    return response;
  }

  List<FlSpot> getSpots(List<Map> data) {
    return data.map((map) {
      final dateString = map['date'] as String;
      final timeString = map['raceName'] as String;
      final timeParts = timeString.split(':').map(int.parse).toList();
      final minutes = timeParts[0];
      final seconds = timeParts[1];
      final milliseconds = timeParts[2];
      final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
      final DateTime dateTime = dateFormat.parse(dateString);
      final dateValue = dateTime.millisecondsSinceEpoch.toDouble();
      final timeValue = minutes + (seconds / 60) + (milliseconds / 60000);
      return FlSpot(dateValue, timeValue);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            // backgroundColor: Colors.transparent,
            heroTag: 'uniqueTag1',
            onPressed: () {
              _recordDialog(context, "إضافة رقم جديد", true);
            },
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            heroTag: 'uniqueTag2',
            onPressed: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) {
                    return MyWidget(
                      swimmerName: widget.swimmerName,
                      raceName: raceName,
                      raceNameAR: _selectedLetter.toString(),
                    );
                  },
                ),
              );
            },
            child: const Icon(Icons.auto_graph),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/sw1.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).colorScheme.background.withOpacity(0.7),
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  centerTitle: true,
                  actions: [
                    IconButton(
                        onPressed: () {
                          _showConfirmationDialog(context);
                        },
                        icon: const Icon(Icons.delete))
                  ],
                  backgroundColor: Colors.transparent,
                  title: CustomText(
                      text: widget.swimmerName, fontWeight: FontWeight.bold),
                  expandedHeight: screenHeight * 0.15,
                  pinned: true,
                  floating: false,
                ),
                SliverPersistentHeader(
                  delegate: SliverAppBarDelegate(
                    minHeight: screenWidth * 0.8,
                    maxHeight: screenHeight * 0.05,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: screenHeight * 0.01,
                            ),
                            _buildInfoRow(": العمر", screenWidth,
                                getSwimmerData().then((data) => data["age"])),
                            SizedBox(
                              height: screenHeight * 0.03,
                            ),
                            _buildInfoRow(
                                ": الجنس",
                                screenWidth,
                                getSwimmerData()
                                    .then((data) => data["gender"])),
                            SizedBox(
                              height: screenHeight * 0.03,
                            ),
                            _buildTrainingDay(),
                            SizedBox(
                              height: screenHeight * 0.03,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildRacesDropDown(),
                                const CustomText(
                                    text: ": الارقام المسجلة ",
                                    fontWeight: FontWeight.normal),
                              ],
                            ),
                            SizedBox(
                              height: screenHeight * 0.03,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  pinned: true,
                ),
                FutureBuilder<List<Map>>(
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
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      );
                    } else {
                      final List<Map>? data = snapshot.data;
                      List<Map> filteredList = data!
                          .where((element) => element[raceName] != null)
                          .toList();
                      if (kDebugMode) {
                        print("$data#############################");
                      }
                      if (filteredList.isEmpty || data.isEmpty) {
                        return const SliverFillRemaining(
                          child: Center(
                            child: CustomText(
                              text: 'لا توجد بيانات لهذا السباق',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        );
                      } else {
                        List<Map> modifiableList = List<Map>.from(data);
                        modifiableList.sort((a, b) {
                          var adate = DateFormat('dd/MM/yyyy').parse(a["date"]);
                          var bdate = DateFormat('dd/MM/yyyy').parse(b["date"]);
                          return bdate.compareTo(adate);
                        });

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              if (modifiableList[index][raceName] == null) {
                                return const SizedBox();
                              } else {
                                return Center(
                                  child: Dismissible(
                                    key: Key(
                                        modifiableList[index]['id'].toString()),
                                    direction: DismissDirection.endToStart,
                                    confirmDismiss: (direction) async {
                                      final bool res = await showDialog(
                                        context: context,
                                        builder: (BuildContext dialogContext) {
                                          return AlertDialog(
                                            title: const Text('تأكيد الحذف'),
                                            content: const Text(
                                              'هل أنت متأكد من أنك تريد حذف هذا السجل؟',
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(dialogContext)
                                                        .pop(false),
                                                child: const Text('الغاء'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(dialogContext)
                                                        .pop(true),
                                                child: const Text('تم'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      return res;
                                    },
                                    onDismissed: (direction) async {
                                      String tableName = widget.swimmerName
                                          .replaceAll(RegExp(r'\s+'), '');
                                      await sqlDb.updateData(
                                        '''
                                        UPDATE $tableName
                                        SET $raceName = NULL
                                        WHERE date = '${modifiableList[index]["date"]}'
                                      ''',
                                      );
                                      await sqlDb.updateData(
                                        '''
                                        UPDATE $raceName
                                        SET score = NULL
                                        WHERE champName = '${modifiableList[index]["champName"]}'
                                        AND swimmerName = '${widget.swimmerName}'
                                        '''
                                      );
                                      setState(() {
                                        modifiableList.removeAt(index);
                                      });
                                    },
                                    background: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 10),
                                      child: const Icon(Icons.delete,
                                          color: Colors.white),
                                    ),
                                    child: Card(
                                      child: ListTile(
                                        title: Text(
                                            "${modifiableList[index][raceName]}"),
                                        subtitle: Text(
                                            "${modifiableList[index]["date"]}"),
                                        leading: modifiableList[index]
                                                    ["champName"] ==
                                                null
                                            ? null
                                            : const Icon(Icons.emoji_events,color: Colors.yellowAccent,),
                                        trailing: modifiableList[index]["champName"] == null
                                            ? IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    currentDay =
                                                        modifiableList[index]
                                                                ["date"]
                                                            .toString();
                                                  });
                                                  _recordDialog(context,
                                                      "تعديل الرقم", false);
                                                },
                                                icon: const Icon(Icons.edit),
                                              )
                                            : Text(modifiableList[index]["champName"]),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            childCount: modifiableList.length,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: widget.inDay
          ? ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    _come ? MaterialStateProperty.all(Colors.lightGreen) : null,
                foregroundColor: MaterialStateProperty.all(
                    Theme.of(context).textTheme.bodyLarge!.color),
              ),
              onPressed: _come
                  ? null
                  : () async {
                      int val = await sqlDb.updateData('''
                          UPDATE '$_day'
                          SET come = 'true'
                          WHERE swimmerName = '${widget.swimmerName}'
                          ''');
                      if (kDebugMode) {
                        print(val);
                      }
                      setState(() {
                        _come = true;
                      });
                    },
              child: CustomText(
                text: _come ? 'تم التسجيل' : 'تسجيل الحضور',
                fontWeight: FontWeight.normal,
              ),
            )
          : null,
    );
  }


  Widget _buildTrainingDay() {
    return FutureBuilder<dynamic>(
      future: getRegisteredDays().then(
          (days) => days.isNotEmpty ? days.join(" , ") : "لا توجد أيام مسجلة"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const CustomText(
            text: 'حدث خطأ أثناء جلب البيانات',
            fontWeight: FontWeight.normal,
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  _showDaysDialog(context);
                },
                icon: const Icon(Icons.edit),
                style: ButtonStyle(iconSize: MaterialStateProperty.all(40)),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: Text(
                  '${snapshot.data}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              const CustomText(
                  text: ': ايام التدريب', fontWeight: FontWeight.bold),
            ],
          );
        }
      },
    );
  }

  Widget _buildInfoRow(
      String title, double screenWidth, Future<dynamic> futureData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: screenWidth * 0.1,
        ),
        FutureBuilder<dynamic>(
          future: futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const CustomText(
                text: 'حدث خطأ أثناء جلب البيانات',
                fontWeight: FontWeight.normal,
              );
            } else {
              return CustomText(
                  text: snapshot.data, fontWeight: FontWeight.bold);
            }
          },
        ),
        CustomText(text: title, fontWeight: FontWeight.bold),
      ],
    );
  }

  Widget _buildRacesDropDown() {
    return Row(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<String>(
          value: _selectedLetter,
          items: races[0].keys.toList().map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: CustomText(
                text: item,
                fontWeight: FontWeight.normal,
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedLetter = newValue!;
              raceName = races[0][_selectedLetter] ?? '';
            });
          },
        ),
      ],
    );
  }

  void _recordDialog(BuildContext context, String text, bool isAdd) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Center(child: Text(text)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(
                              Theme.of(context).textTheme.bodyLarge!.color),
                        ),
                        onPressed: isAdd
                            ? () async {
                                await _pickDate(context, setState);
                              }
                            : null,
                        child: Text(currentDay),
                      ),
                      const Text(": اختر التاريح"),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPickerColumn(
                          'دقيقة', _minuteController, _selectedMinute, (value) {
                        _selectedMinute = value;
                      }, 2),
                      _buildPickerColumn(
                          'ثانية', _secondController, _selectedSecond, (value) {
                        _selectedSecond = value;
                      }, 2),
                      _buildPickerColumn('مل ثانية', _millisecondController,
                          _selectedMillisecond, (value) {
                        _selectedMillisecond = value;
                      }, 3),
                    ],
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.white10),
                        foregroundColor: MaterialStateProperty.all(
                            Theme.of(context).textTheme.bodyLarge!.color),
                      ),
                      child: const Text("إلغاء"),
                    ),
                    TextButton(
                      onPressed: () async {
                        String tableName =
                            widget.swimmerName.replaceAll(RegExp(r'\s+'), '');
                        double seconds = (_selectedMinute * 60) +
                            _selectedSecond +
                            (_selectedMillisecond / 1000);
                        int totalSeconds = seconds.toInt();
                        double min = totalSeconds / 60;
                        int sec = totalSeconds % 60;
                        int milliseconds =
                            ((seconds - totalSeconds) * 1000).toInt();
                        // if(milliseconds < 233){
                        //   milliseconds++;
                        // }
                        String val =
                            // "$_selectedSecond:$_selectedMillisecond";
                            "${min.toInt().toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}:${milliseconds.toString().padLeft(3, '0')}";
                        if (isAdd) {
                          var resultDay = await sqlDb.readData(
                              "SELECT * FROM '$tableName' WHERE date = '$currentDay'");
                          if (kDebugMode) {
                            print(resultDay);
                          }
                          if (resultDay.isEmpty) {
                            await sqlDb.insertData('''
                                INSERT INTO '$tableName'
                                ($raceName, date)
                                VALUES ('$val', '$currentDay')
                                ''');
                            if (kDebugMode) {
                              print("insert table done!##################");
                            }
                          }
                          var result = await sqlDb.readData(
                              "SELECT $raceName FROM '$tableName' WHERE date = '$currentDay'");
                          if (result[0][raceName] == null &&
                              resultDay.isNotEmpty) {
                            await sqlDb.updateData('''
                            UPDATE $tableName
                            SET $raceName = '$val'
                            WHERE date = '$currentDay'
                            ''');
                            if (kDebugMode) {
                              print("update table done!##################");
                            }
                          }
                          if (resultDay.isNotEmpty &&
                              result[0][raceName] != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "لقد سجلت هذا السباق في هذا التاريخ من قبل!"),
                              ),
                            );
                            if (kDebugMode) {
                              print("التاريخ موجود بالفعل");
                            }
                          }
                        } else {
                          await sqlDb.updateData('''
                            UPDATE $tableName
                            SET $raceName = '$val'
                            WHERE date = '$currentDay'
                            ''');
                          if (kDebugMode) {
                            print("update table done!##################");
                          }
                          if (kDebugMode) {
                            print("$tableName,  $val");
                          }
                        }
                        _refreshData();
                        Navigator.of(context).pop();
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.lightGreen),
                        foregroundColor: MaterialStateProperty.all(
                            Theme.of(context).textTheme.bodyLarge!.color),
                      ),
                      child: Text(
                        isAdd ? 'إضافة' : "تعديل",
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pickDate(BuildContext context, StateSetter setState) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2025),
    );
    if (pickedDate != null) {
      final formatter = DateFormat('dd/MM/yyyy');
      setState(() {
        currentDay = formatter.format(pickedDate).toLowerCase();
      });
    }
  }

  Widget _buildPickerColumn(String label, TextEditingController controller,
      int value, ValueChanged<int> onChanged, int maxLength) {
    return Column(
      children: [
        Text(label),
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.2,
          child: TextFormField(
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(maxLength),
            ],
            controller: controller,
            textAlign: TextAlign.center,
            onChanged: (newValue) {
              onChanged(int.tryParse(newValue) ?? value);
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "00",
            ),
          ),
        ),
      ],
    );
  }

  void _showDaysDialog(BuildContext context) async {
    // Get the registered days outside the dialog
    List<String> registeredDays = await getRegisteredDays();
    if (kDebugMode) {
      print(registeredDays);
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تعديل مواعيد التدريب'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: daysOfWeek[0].values.toList().length,
              itemBuilder: (BuildContext context, int index) {
                final String dayAR = daysOfWeek[0].values.toList()[index];
                final String dayEN = daysOfWeek[0].keys.toList()[index];
                final bool isSelected = selectedDays.containsKey(dayEN);
                final bool isRegistered = registeredDays.contains(dayAR);
                final String timeText = selectedDays.containsKey(dayEN)
                    ? selectedDays[dayEN]!.format(context)
                    : '';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(dayAR),
                      trailing: isSelected || isRegistered
                          ? IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await sqlDb.updateData('''
                                  UPDATE swimmer
                                  SET $dayEN = NULL
                                  WHERE name = "${widget.swimmerName}"
                                  ''');
                                await sqlDb.deleteData('''
                                  DELETE FROM $dayEN
                                  WHERE swimmerName = "${widget.swimmerName}"
                                  ''');

                                setState(() {
                                  selectedDays.remove(dayEN);
                                });
                                Navigator.of(context).pop();
                                _showDaysDialog(context);
                              },
                            )
                          : null,
                      onTap: () async {
                        if (!isSelected && !isRegistered) {
                          final TimeOfDay selectedTime =
                              await _showTimePicker(context);
                          String val =
                              '${selectedTime.hour}:${selectedTime.minute}';

                          await sqlDb.insertData('''
                                INSERT INTO $dayEN (swimmerName, time, come)
                                VALUES ("${widget.swimmerName}", "$val", "false")
                                  ''');
                          setState(() {
                            selectedDays[dayEN] = selectedTime;
                          });

                          int response = await sqlDb.updateData('''
                                  UPDATE swimmer
                                  SET $dayEN = '$val'
                                  WHERE name = "${widget.swimmerName}"
                                  ''');

                          if (kDebugMode) {
                            print(response);
                          }
                        }

                        Navigator.of(context).pop();
                      },
                      selected: isSelected,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        timeText,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontStyle:
                              isSelected ? FontStyle.normal : FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<TimeOfDay> _showTimePicker(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    return picked ?? TimeOfDay.now();
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('تأكيد الحذف')),
          content: const Text('هل أنت متأكد أنك تريد حذف هذا السباح؟'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              child: const Text(
                'الغاء',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _deleteSwimmer(widget.swimmerName);
                _deleteTable(widget.swimmerName.replaceAll(RegExp(r'\s+'), ''));
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              child: const Text(
                'حذف',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteTable(String tableName) async {
    try {
      await sqlDb.deleteTable(tableName);
      if (kDebugMode) {
        print('Table $tableName deleted successfully');
      }
      List<String> tableNames = await sqlDb.getAllTableNames();
      if (kDebugMode) {
        print('All table names: $tableNames');
      }
    } catch (e) {
      // Handle errors...
    }
  }

  Future<void> _deleteSwimmer(String swimmerName) async {
    List<String> days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];

    for (String day in days) {
      await sqlDb.deleteData('''
      DELETE FROM $day
      WHERE swimmerName = "$swimmerName"
    ''');
    }

    await sqlDb.deleteData('''
    DELETE FROM swimmer
    WHERE name = "$swimmerName"
  ''');
  }
}
