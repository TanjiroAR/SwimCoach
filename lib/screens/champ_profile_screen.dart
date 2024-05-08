import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import '../data/db.dart';
import '../widgets/slivrt_app_bar_delegate.dart';

class ChampProfile extends StatefulWidget {
  final String champName;
  final String startChamp;
  final String endChamp;
  const ChampProfile(
      {super.key,
      required this.champName,
      required this.startChamp,
      required this.endChamp});

  @override
  State<ChampProfile> createState() => _ChampProfileState();
}

class _ChampProfileState extends State<ChampProfile> {
  final SqlDb sqlDb = SqlDb();

  final List<Map<String, List<Map<String, dynamic>>>> loadedStages = [
    {
      '١١ سنة': [],
      '١٢ سنة': [],
      '١٣ سنة': [],
      '١٤ سنة': [],
      '١٥ سنة': [],
      'عمومي': [],
    }
  ];

  late String? _selectedRaceName;
  late String raceName = races[0][_selectedRaceName] ?? '';
  late String? _selectedAgeStage;
  late String ageStage = stages[0][_selectedAgeStage] ?? '';
  late String? _selectedGender;
  late String gender = genderList[0][_selectedGender] ?? '';
  int age = 11;
  List<String> participants = [];
  List<bool> selected = [];

  final TextEditingController _minuteController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  final TextEditingController _millisecondController = TextEditingController();
  String _selectedTime = "16:30";
  DateTime initialDate = DateTime.now();

  String _startDate =
      DateFormat("dd/MM/yyyy").format(DateTime(DateTime.now().year - 1));
  String _endDate =
      DateFormat("dd/MM/yyyy").format(DateTime(DateTime.now().year + 1));
  String _selectedDate =
      DateFormat("dd/MM/yyyy").format(DateTime(DateTime.now().year + 1));

  @override
  void dispose() {
    _minuteController.dispose();
    _secondController.dispose();
    _millisecondController.dispose();
    super.dispose();
  }

  int _selectedMinute = 0;
  int _selectedSecond = 0;
  int _selectedMillisecond = 0;

  Future<void> _refreshData() async {
    setState(() {});
  }

  Future<List<Map>> _readData(
      String tableName, String stageSelected, String? gender) async {
    String genderCondition = '';
    if (gender != null && gender != 'all') {
      genderCondition = "AND gender = '$gender'";
    }
    List<Map> response = await sqlDb.readData('''
      SELECT * FROM $tableName 
      WHERE ageStage = "$stageSelected" 
      AND champName = "${widget.champName}"
      $genderCondition
      ''');
    return response;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _startDate = widget.startChamp;
      _endDate = widget.endChamp;
      _selectedDate = widget.startChamp;
    });
    _selectedRaceName = races[0].keys.first;
    _selectedAgeStage = stages[0].keys.first;
    _selectedGender = genderList[0].keys.first;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // initialDate = DateFormat('dd/MM/yyyy').parse(widget.startChamp);
          _addRaceDialog(context, screenHeight);
        },
        child: const Icon(Icons.add),
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
          color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
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
                      text: widget.champName, fontWeight: FontWeight.bold),
                  expandedHeight: screenHeight * 0.1,
                  pinned: true,
                  floating: false,
                  // flexibleSpace: FlexibleSpaceBar(
                  //   background: Container(
                  //     padding: EdgeInsets.only(
                  //         top: MediaQuery.of(context).padding.top * 4),
                  //     child: Center(
                  //       child: _buildAvatar(screenHeight),
                  //     ),
                  //   ),
                  // ),
                ),
                SliverPersistentHeader(
                  delegate: SliverAppBarDelegate(
                    minHeight: screenWidth * 0.8,
                    maxHeight: screenHeight * 0.05,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(screenHeight * 0.01),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(": إلى"),
                                    ElevatedButton(
                                        onPressed: () {},
                                        child: Text(_endDate)),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(": من"),
                                    ElevatedButton(
                                        onPressed: () {},
                                        child: Text(_startDate)),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: screenHeight * 0.01,
                            ),
                            // هنا اختر المرحلة العمرية
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    DropdownButton<String>(
                                      value: _selectedAgeStage,
                                      items:
                                          stages[0].keys.toList().map((item) {
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
                                          _selectedAgeStage = newValue!;
                                          ageStage = stages[0]
                                                  [_selectedAgeStage] ??
                                              '';
                                          if (_selectedAgeStage == "١١ سنة") {
                                            age = 11;
                                          } else if (_selectedAgeStage ==
                                              "١٢ سنة") {
                                            age = 12;
                                          } else if (_selectedAgeStage ==
                                              "١٣ سنة") {
                                            age = 13;
                                          } else if (_selectedAgeStage ==
                                              "١٤ سنة") {
                                            age = 14;
                                          } else if (_selectedAgeStage ==
                                              "١٥ سنة") {
                                            age = 15;
                                          } else if (_selectedAgeStage ==
                                              "عمومي") {
                                            age = 16;
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const CustomText(
                                    text: ": المرحلة العمرية",
                                    fontWeight: FontWeight.bold),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    DropdownButton<String>(
                                      value: _selectedRaceName,
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
                                          _selectedRaceName = newValue!;
                                          raceName =
                                              races[0][_selectedRaceName] ?? '';
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const CustomText(
                                  text: ": نوع السباق",
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                DropdownButton<String>(
                                  value: _selectedGender,
                                  items:
                                      genderList[0].keys.toList().map((item) {
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
                                      _selectedGender = newValue!;
                                      gender =
                                          genderList[0][_selectedGender] ?? '';
                                    });
                                  },
                                ),
                                const CustomText(
                                  text: ": الجنس",
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            const CustomText(
                                text: ": المشتركين",
                                fontWeight: FontWeight.bold),
                          ],
                        ),
                      ),
                    ),
                  ),
                  pinned: true,
                ),
                FutureBuilder(
                  future: _readData(raceName, ageStage, gender),
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
                      data!
                          .where((element) => element[widget.champName] != null)
                          .toList();
                      if (kDebugMode) {
                        print("$data#############################");
                      }
                      if (data.isEmpty) {
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
                                    String swimmer = modifiableList[index]
                                            ["swimmerName"]
                                        .replaceAll(RegExp(r'\s+'), '');
                                    String tableName = raceName;
                                    await sqlDb.deleteData('''
                                      DELETE FROM '$tableName' 
                                      WHERE swimmerName = "${modifiableList[index]["swimmerName"]}"
                                      AND ageStage = "$ageStage"
                                      AND champName = "${widget.champName}"
                                      ''');
                                    await sqlDb.deleteData('''
                                      DELETE FROM '$swimmer'
                                      WHERE champName = '${widget.champName}'
                                      AND date = '${modifiableList[index]["date"]}'
                                      ''');
                                    setState(() {
                                      modifiableList.removeAt(index);
                                    });
                                  },
                                  background: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Icon(Icons.delete,
                                        color: Colors.white),
                                  ),
                                  child: Card(
                                    child: ListTile(
                                      title: Center(
                                        child: Text(
                                            "${modifiableList[index]["swimmerName"]}"),
                                      ),
                                      subtitle: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            children: [
                                              const Text(": النوقيت"),
                                              Text(
                                                  "${modifiableList[index]["time"]}"),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              const Text(": موعد المشاركة"),
                                              Text(
                                                  "${modifiableList[index]["date"]}"),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              const Text(": الرقم المسجل"),
                                              Text(modifiableList[index]
                                                          ["score"] ==
                                                      null
                                                  ? "لم يتم التسجيل"
                                                  : "${modifiableList[index]["score"]}"),
                                            ],
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        if (modifiableList[index]["score"] ==
                                            null) {
                                          _recordDialog(
                                              context,
                                              "إضافة رقم جديد",
                                              modifiableList[index]
                                                  ["swimmerName"],
                                              modifiableList[index]["date"],
                                              true);
                                        } else {
                                          _recordDialog(
                                              context,
                                              "تعديل الرقم",
                                              modifiableList[index]
                                                  ["swimmerName"],
                                              modifiableList[index]["date"],
                                              false);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              );
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
    );
  }

  Future<List<Map<String, dynamic>>> readData(
      int ageState, String? genderState) async {
    String ageCondition = '';
    if (ageState == 16) {
      ageCondition = "CAST(age AS INTEGER) >= $ageState";
    } else {
      ageCondition = "CAST(age AS INTEGER) = $ageState";
    }
    String genderCondition = '';
    if (genderState != null && genderState != 'all') {
      genderCondition = "AND gender = '$genderState'";
    }
    List<Map<String, dynamic>> response = await sqlDb
        .readData("SELECT * FROM swimmer WHERE $ageCondition $genderCondition");
    return response;
  }

  void _addRaceDialog(BuildContext context, double screenHeight) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Center(
                child: Text("${_selectedRaceName!}(${_selectedAgeStage!})"),
              ),
              content: Column(
                children: [
                  // هنا حدد موعد السباق
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _pickRaceDate(context, setState);
                        },
                        child: CustomText(
                          text: _selectedDate == ''
                              ? 'dd/MM/yyyy'
                              : _selectedDate,
                          fontWeight: FontWeight.normal,
                          fontSize: 10,
                        ),
                      ),
                      const CustomText(
                        text: ": حدد موعد السباق",
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  const Center(
                    child: CustomText(
                      text: ": السباحين المتاحين",
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  SizedBox(
                    height: screenHeight * 0.4,
                    width: screenHeight  * 0.6,
                    child: FutureBuilder(
                      future: readData(age, gender),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data?.length ?? 0,
                            itemBuilder: (context, index) {
                              if (selected.length != snapshot.data!.length) {
                                selected = List.generate(
                                    snapshot.data!.length, (index) => false);
                              }
                              var swimmer = snapshot.data![index];
                              return Card(
                                color: selected[index]
                                    ? Colors.lightGreen
                                    : Theme.of(context).colorScheme.surface,
                                child: ListTile(
                                  title: Text(swimmer['name']),
                                  subtitle: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${swimmer['age']} : العمر '),
                                      Text('${swimmer['gender']} : الجنس '),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      selected[index] = !selected[index];
                                      // إضافة أو حذف اسم السباح من قائمة المشاركين
                                      if (selected[index]) {
                                        participants.add(swimmer['name']);
                                      } else {
                                        participants.remove(swimmer['name']);
                                      }
                                    });
                                    // loadStagesFromDatabase();
                                    if (kDebugMode) {
                                      print(participants);
                                    }
                                  },
                                ),
                              );
                            },
                          );
                        }
                        return const CustomText(
                            text: "لا يوجد سباحين", fontWeight: FontWeight.bold);
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                Center(
                  child: ElevatedButton(

                    onPressed: () async{
                      if(participants.isNotEmpty){
                        for(var val in participants){
                          await sqlDb.insertData(
                            '''
                            INSERT INTO $raceName (swimmerName, gender, ageStage, date, time, champName)
                            VALUES ("$val", "$gender", "${getAgeStage(_selectedAgeStage!, stages)}", "$_selectedDate", "$_selectedTime", "${widget.champName}")
                            '''
                          );
                        }
                      }
                      Navigator.of(context).pop();
                      _refreshData();
                      selected = [];
                      participants = [];
                    },

                    child: const CustomText(
                        text: "إضافة", fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  String getAgeStage(String ageStage, List<Map> stages) {
    for (var raceMap in stages) {
      if (raceMap.containsKey(ageStage)) {
        return raceMap[ageStage];
      }
    }
    return '';
  }

  bool isSwimmerScheduled(String swimmerName, String date, String time,
      List<Map<String, dynamic>> stages) {
    for (var stage in stages) {
      if (stage['date'] == date &&
          stage['time'] == time &&
          stage['swimmers'].contains(swimmerName)) {
        return true; // السباح موجود بالفعل في نفس التاريخ والوقت
      }
    }
    return false; // السباح غير موجود ويمكن إضافته
  }

  // // عرض التقويم وتحديث اليوم الحالي عند اختيار تاريخ جديد
  Future<void> _pickRaceDate(BuildContext context, StateSetter setState) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateFormat('dd/MM/yyyy').parse(_startDate),
      firstDate: DateFormat('dd/MM/yyyy').parse(_startDate),
      lastDate: DateFormat('dd/MM/yyyy').parse(_endDate),
    );
    if (pickedDate != null) {
      DateFormat formatter = DateFormat('dd/MM/yyyy');
      setState(() {
        _selectedDate = formatter.format(pickedDate).toLowerCase();
        _showTimePicker(context);
      });
    }
  }

  Future<String> _showTimePicker(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      // تحويل الوقت إلى نص

      setState(() {
        _selectedTime = picked.format(context);
      });
      return _selectedTime;
    } else {
      return TimeOfDay.now().format(context);
    }
  }

  void _recordDialog(BuildContext context, String text, String swimmerName,
      String currentDay, bool isAdd) {
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
                            WidgetStateProperty.all<Color>(Colors.white10),
                        foregroundColor: WidgetStateProperty.all(
                            Theme.of(context).textTheme.bodyLarge!.color),
                      ),
                      child: const Text("إلغاء"),
                    ),
                    TextButton(
                      onPressed: () async {
                        String tableName =
                            swimmerName.replaceAll(RegExp(r'\s+'), '');
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
                          await sqlDb.updateData('''
                            UPDATE $raceName
                            SET score = '$val'
                            WHERE swimmerName = '$swimmerName'
                            AND ageStage = '$ageStage'
                            AND champName = '${widget.champName}'
                            ''');
                          await sqlDb.insertData('''
                            INSERT INTO '$tableName'
                            ($raceName, date, champName)
                            VALUES ('$val', '$currentDay', '${widget.champName}')
                            ''');
                        } else {
                          await sqlDb.updateData('''
                            UPDATE $raceName
                            SET score = '$val'
                            WHERE swimmerName = '$swimmerName'
                            AND ageStage = '$ageStage'
                            AND champName = '${widget.champName}'
                            ''');
                          await sqlDb.updateData('''
                            UPDATE $tableName
                            SET $raceName = '$val'
                            WHERE date = '$currentDay'
                            AND champName = '${widget.champName}'
                            ''');
                        }
                        _refreshData();
                        Navigator.of(context).pop();
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all<Color>(Colors.lightGreen),
                        foregroundColor: WidgetStateProperty.all(
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
                backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
              ),
              child: const Text(
                'الغاء',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _deleteChamp(widget.champName);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
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

  Future<void> _deleteChamp(String champName) async {
    await sqlDb.deleteData('''
    DELETE FROM champ
    WHERE name = "$champName"
  ''');
    for (String race in SqlDb.races) {
      await sqlDb.deleteData('''
        DELETE FROM $race WHERE champName = "${widget.champName}"
        ''');
    }
  }
}
