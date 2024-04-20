import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:swimming/constants.dart';
import 'package:swimming/data/db.dart';

class AddSwimmerBottomSheet extends StatefulWidget {
  const AddSwimmerBottomSheet({super.key});

  @override
  State<AddSwimmerBottomSheet> createState() => _AddSwimmerBottomSheetState();
}

class _AddSwimmerBottomSheetState extends State<AddSwimmerBottomSheet> {
  SqlDb sqlDb = SqlDb();
  DateTime selectedDate = DateTime.now();
  Map<String, TimeOfDay> selectedDays = {};
  List<Map> daysOfWeek = [
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
  final TextEditingController _nameController =
      TextEditingController(); // إنشاء تحكم لحقل الاسم
  String gender = ''; // متغير لتخزين قيمة الجنس
  @override
  void dispose() {
    _nameController.dispose(); // التخلص من تحكم الاسم عند تحرير الموارد
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenHeight * 0.03),
          child: Column(
            children: [
              // _buildAvatar(context),
              //  SizedBox(height: screenHeight * 0.05),
              TextField(
                decoration: InputDecoration(
                  hintText: 'ادخل الاسم..',
                  border: const OutlineInputBorder(),
                  labelText: 'الاسم',
                  hoverColor: Theme.of(context).colorScheme.primary,
                ),
                controller: _nameController,
                onChanged: (value) {},
              ),
              SizedBox(height: screenHeight * 0.03),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'الجنس:',
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(

                    children: [
                      Radio(
                        value: 'male',
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value.toString();
                          });
                        },
                      ),
                      const Text('ذكر'),
                      Radio(
                        value: 'female',
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value.toString();
                          });
                        },
                      ),
                      const Text('أنثى'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Row(
                  children: [
                    Expanded(
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'تاريخ الميلاد',
                            border: const OutlineInputBorder(),
                            labelText: 'تاريخ الميلاد',
                            hoverColor: Theme.of(context).colorScheme.primary,
                          ),
                          controller: TextEditingController(
                            text:
                                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'العمر',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _calculateAge(selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      enabled: false,
                      controller: TextEditingController(
                          text: selectedDays.keys.join(', ')),
                      decoration: InputDecoration(
                        labelText: 'ايام التدريب',
                        border: const OutlineInputBorder(),
                        hoverColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _showDaysDialog(context);
                    },
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              Row(
                // يمكن استخدام العنصر Row للتأكد من امتداد الزر عبر العرض
                children: [
                  Expanded(
                    // هنا يتم استخدام Expanded لتوسيع الزر عبر العرض
                    child: ElevatedButton(
                      onPressed: () {
                        _submitForm();
                      },
                      style: ButtonStyle(
                        side: MaterialStateProperty.all(BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2.0, // عرض الحدود
                        )),
                      ),
                      child: const CustomText(text: 'تم', fontWeight: FontWeight.bold)
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 10),
              // _showTournamentContainer(context),
            ],
          ),
        ),
      ),
    );
  }

    void _submitForm() async {
      String createTableQuery = '''
        CREATE TABLE '${_nameController.text.replaceAll(RegExp(r'\s+'), '')}' (
          "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          "date" TEXT,
          "champName" TEXT,
          "raceCount" INTEGER,
          "free_50m" TEXT,
          "free_100m" TEXT,
          "free_200m" TEXT,
          "free_400m" TEXT,
          "free_800m" TEXT,
          "free_1500m" TEXT,
          "breast_50m" TEXT,
          "breast_100m" TEXT,
          "breast_200m" TEXT,
          "back_50m" TEXT,
          "back_100m" TEXT,
          "back_200m" TEXT,
          "butterfly_50m" TEXT,
          "butterfly_100m" TEXT,
          "butterfly_200m" TEXT,
          "medley_200m" TEXT,
          "medley_400m" TEXT,
          FOREIGN KEY(champName) REFERENCES champ(name)
        )
      ''';
      int ageValue = int.parse(_calculateAge(selectedDate));
      if (_nameController.text.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('تنبيه'),
              content: const Text('الرجاء إدخال اسم السباح.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('حسناً'),
                ),
              ],
            );
          },
        );
        return;
      }
      else if (gender.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('تنبيه'),
              content: const Text('الرجاء تحديد نجس التدريب.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('حسناً'),
                ),
              ],
            );
          },
        );
        return;
      }
      else if (selectedDays.isEmpty) {
        // عرض رسالة تنبيه إذا لم يتم تحديد أيام التدريب
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('تنبيه'),
              content: const Text('الرجاء تحديد ميعاد التدريب.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('حسناً'),
                ),
              ],
            );
          },
        );
        return;
      }
      else if(ageValue == 0){
        // عرض رسالة تنبيه إذا لم يتم تحديد أيام التدريب
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('تنبيه'),
              content: const Text('الرجاء تحديد عمر السباح.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('حسناً'),
                ),
              ],
            );
          },
        );
        return;
      }
      else {
        try {
          // Wait for the database to be opened
          Database? db = await sqlDb.db;
          List<Map<String, dynamic>> tables = await db!.query(
            'sqlite_master',
            where: 'type = ? AND name = ?',
            whereArgs: ['table', _nameController.text.replaceAll(RegExp(r'\s+'), '')],
          );
          if (tables.isEmpty) {
            await db.execute(createTableQuery);
            // Inform the user that the table has been successfully created
            // إذا تم إدخال جميع البيانات المطلوبة، يمكننا استكمال عملية الإرسال أو الحفظ
            int swimmerData = await sqlDb.insertData('''
                INSERT INTO swimmer (name, age, gender, monday, tuesday, wednesday, thursday, friday, saturday, sunday)
                VALUES (
                "${_nameController.text}",
                "${_calculateAge(selectedDate)}",
                "$gender",
                ${selectedDays['Monday'] != null ? "'${selectedDays['Monday']!.format(context).toString()}'" : 'null'},
                ${selectedDays['Tuesday'] != null ? "'${selectedDays['Tuesday']!.format(context).toString()}'" : 'null'},
                ${selectedDays['Wednesday'] != null ? "'${selectedDays['Wednesday']!.format(context).toString()}'" : 'null'},
                ${selectedDays['Thursday'] != null ? "'${selectedDays['Thursday']!.format(context).toString()}'" : 'null'},
                ${selectedDays['Friday'] != null ? "'${selectedDays['Friday']!.format(context).toString()}'" : 'null'},
                ${selectedDays['Saturday'] != null ? "'${selectedDays['Saturday']!.format(context).toString()}'" : 'null'},
                ${selectedDays['Sunday'] != null ? "'${selectedDays['Sunday']!.format(context).toString()}'" : 'null'}
                 )
            ''');
            if (kDebugMode) {
              print(swimmerData);
            }

            List<Map> response = await sqlDb.readData("SELECT * FROM 'swimmer'");
            if (kDebugMode) {
              print(response);
            }

            selectedDays.forEach((day, time) async {
              int dayData = await sqlDb.insertData(
                  '''
                  INSERT INTO $day (swimmerName, time, come)
                  VALUES ("${_nameController.text}", "${time.format(context).toString()}", "false")
                  ''');
              if (kDebugMode) {
                print("$dayData =================================");
              }
              List<Map> response = await sqlDb.readData("SELECT * FROM '$day'");
              if (kDebugMode) {
                print(response);
              }
            });

            // _printData();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('   تم اضافة${_nameController.text}  سباح جديد  '),
              ),
            );
          }
          else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('تنبيه'),
                  content: const Text('هذا السباح موجود'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('حسناً'),
                    ),
                  ],
                );
              },
            );
            if (kDebugMode) {
              print('Table ${_nameController.text.replaceAll(RegExp(r'\s+'), '')} already exists');
            }
          }

          List<String> tableNames = await sqlDb.getAllTableNames();
          if (kDebugMode) {
            print('All table names: $tableNames');
          }
        } catch (e) {
          // Handle any errors that occur during table creation
          if (kDebugMode) {
            print('Error: $e');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An error occurred while creating the table.'),
            ),
          );
        }
      }
    }

  String _calculateAge(DateTime selectedDate) {
    final now = DateTime.now();
    // final difference = now.difference(selectedDate);
    int years = now.year - selectedDate.year;
    // final age = difference.inDays ~/ 365;
    return '$years';
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: Localizations.override(
            context: context,
            locale: const Locale('en', 'GB'),
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: selectedDate,
              minimumDate: DateTime(1950),
              maximumDate: DateTime.now(),
              onDateTimeChanged: (DateTime newDate) {
                setState(() {
                  selectedDate = newDate;
                });
              },
            ),
          ),
        );
      },
      barrierColor: Theme.of(context).colorScheme.secondary,
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _showDaysDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('حدد مواعيد التدريب'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: daysOfWeek[0].keys.toList().length,
              itemBuilder: (BuildContext context, int index) {
                final String dayEN = daysOfWeek[0].keys.toList()[index];
                final String dayAR = daysOfWeek[0].values.toList()[index];
                final bool isSelected = selectedDays.containsKey(dayEN);
                final String timeText = selectedDays.containsKey(dayEN)
                    ? selectedDays[dayEN]!.format(context)
                    : '';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(dayAR),
                      trailing: isSelected
                          ? IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  selectedDays.remove(dayEN);
                                });
                                Navigator.of(context).pop();
                                _showDaysDialog(context);
                              },
                            )
                          : null,
                      onTap: () async {
                        if (!isSelected) {
                          final TimeOfDay selectedTime =
                              await _showTimePicker(context);
                          setState(() {
                            selectedDays[dayEN] = selectedTime;
                          });
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
                          color: Theme.of(context).colorScheme.secondary,
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
}

// Widget _buildAvatar(context) {
//   return Stack(
//     alignment: Alignment.bottomCenter,
//     children: [
//       const CircleAvatar(
//         radius: 90,
//         backgroundImage: AssetImage("images/user.png"),
//       ),
//       Positioned(
//         bottom: 0,
//         child: IconButton(
//           color: Theme.of(context).colorScheme.primary,
//           icon: const Icon(Icons.edit),
//           onPressed: () {},
//         ),
//       ),
//     ],
//   );
// }

