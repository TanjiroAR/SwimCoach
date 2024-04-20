import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:swimming/data/db.dart';

import '../constants.dart';

class EditSwimmer extends StatefulWidget {
  final String name;
  final String age;
  const EditSwimmer({super.key, required this.name , required this.age});

  @override
  State<EditSwimmer> createState() => _EditSwimmerState();
}

class _EditSwimmerState extends State<EditSwimmer> {
  SqlDb sqlDb = SqlDb();

  final TextEditingController _nameController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: screenHeight * 0.5,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(
              screenHeight * 0.03),
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * 0.03,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText:widget.name,
                  border:
                  const OutlineInputBorder(),
                  labelText: "تعديل الاسم",
                  hoverColor:
                  Theme.of(context)
                      .colorScheme
                      .primary,
                ),
                controller: _nameController,
                onChanged: (value) {},
              ),
              SizedBox(
                  height:
                  screenHeight * 0.03),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Row(
                  children: [
                    Expanded(
                      child: AbsorbPointer(
                        child: TextField(
                          decoration:
                          InputDecoration(
                            hintText:
                            'تاريخ الميلاد',
                            border:
                            const OutlineInputBorder(),
                            labelText:
                            'تاريخ الميلاد',
                            hoverColor: Theme
                                .of(context)
                                .colorScheme
                                .primary,
                          ),
                          controller:
                          TextEditingController(
                            text:
                            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding:
                      const EdgeInsets
                          .all(8),
                      decoration:
                      BoxDecoration(
                        borderRadius:
                        BorderRadius
                            .circular(5),
                        border: Border.all(
                            color: Theme.of(
                                context)
                                .colorScheme
                                .primary),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .center,
                        children: [
                          Text(
                            'العمر',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                    context)
                                    .colorScheme
                                    .primary),
                          ),
                          const SizedBox(
                              height: 4),
                          Text(
                            _calculateAge(
                                selectedDate),
                            style:
                            const TextStyle(
                                fontSize:
                                16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Row(
                // يمكن استخدام العنصر Row للتأكد من امتداد الزر عبر العرض
                children: [
                  Expanded(
                    // هنا يتم استخدام Expanded لتوسيع الزر عبر العرض
                    child: ElevatedButton(
                        onPressed: () {
                          _submit(widget.name);
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
            ],
          ),
        ),
      ),
    );
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
  String _calculateAge(DateTime selectedDate) {
    final now = DateTime.now();
    // final difference = now.difference(selectedDate);
    int years = now.year - selectedDate.year;
    // final age = difference.inDays ~/ 365;
    return '$years';
  }
  void _submit(String swimmerName) async{
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
    else if(ageValue == 0){
      // عرض رسالة تنبيه
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
    else{
      try{
        // Wait for the database to be opened
        Database? db = await sqlDb.db;
        List<Map<String, dynamic>> tables = await db!.query(
          'sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['table', _nameController.text.replaceAll(RegExp(r'\s+'), '')],
        );
        if (tables.isEmpty){
          await db.execute('''
            ALTER TABLE ${swimmerName.replaceAll(RegExp(r'\s+'), '')}
            RENAME TO ${_nameController.text.replaceAll(RegExp(r'\s+'), '')}
            ''');
          await sqlDb.updateData(
            '''
            UPDATE swimmer 
            SET name = '${_nameController.text}', age = '${_calculateAge(selectedDate)}'
            WHERE name = '$swimmerName'
            '''
          );
          Navigator.of(context).pop();
          // Inform the user that the table name has been successfully changed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تعديل اسم السباح الى ${_nameController.text}'),
            ),
          );
        }else {
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
      }catch (e) {
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
}
