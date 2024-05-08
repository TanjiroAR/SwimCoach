import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:SwimCoach/constants.dart';
import 'package:SwimCoach/data/db.dart';

class AddChampScreen extends StatefulWidget {
  const AddChampScreen({super.key});

  @override
  State<AddChampScreen> createState() => _AddChampScreenState();
}

class _AddChampScreenState extends State<AddChampScreen> {
  SqlDb sqlDb = SqlDb();
  // String dropDownValue = "";
  // قائمة لتتبع حالة اللون لكل Card
  List<String> participants = [];
  List<bool> selected = [];
  final List<Map<String, List<Map<String, dynamic>>>> stage = [
    {
      '١١ سنة': [],
      '١٢ سنة': [],
      '١٣ سنة': [],
      '١٤ سنة': [],
      '١٥ سنة': [],
      'عمومي': [],
    }
  ];
  bool formSaved = false;
  late String? _selectedRaceName;
  late String raceName = races[0][_selectedRaceName] ?? '';
  late String? _selectedAgeStage;
  late String ageStage = stages[0][_selectedAgeStage] ?? '';
  late String? _selectedGender;
  late String gender = genderList[0][_selectedGender] ?? '';

  String _selectedTime = "16:30";
  DateTime initialDate = DateTime.now();

  String _startDate =
      DateFormat("dd/MM/yyyy").format(DateTime(DateTime.now().year - 1));
  String _endDate =
      DateFormat("dd/MM/yyyy").format(DateTime(DateTime.now().year + 1));
  String _selectedDate =
  DateFormat("dd/MM/yyyy").format(DateTime(DateTime.now().year + 1));
  int age = 11;
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
    List<Map<String, dynamic>> response = await sqlDb.readData(
        "SELECT * FROM swimmer WHERE $ageCondition $genderCondition");
    return response;
  }
  final TextEditingController _nameController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {});
    _selectedRaceName = races[0].keys.first;
    _selectedAgeStage = stages[0].keys.first;
    _selectedGender = genderList[0].keys.first;
  }

  // عرض التقويم وتحديث اليوم الحالي عند اختيار تاريخ جديد
  Future<void> _pickStartAndEndDate(BuildContext context, bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ,
      firstDate: DateFormat('dd/MM/yyyy').parse(_startDate),
      lastDate: DateFormat('dd/MM/yyyy').parse(_endDate),
    );
    if (pickedDate != null) {
      DateFormat formatter = DateFormat('dd/MM/yyyy');
      if (isStart) {
        setState(() {
          _startDate = formatter.format(pickedDate);
          _selectedDate = _startDate;
          initialDate = pickedDate;
        });
      } else {
        setState(() {
          _endDate = formatter.format(pickedDate).toLowerCase();
        });
      }
    }
  }

  // // عرض التقويم وتحديث اليوم الحالي عند اختيار تاريخ جديد
  Future<void> _pickRaceDate(BuildContext context, StateSetter setState) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: formSaved,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('تحذير'),
              content: const Text('سوف تخسر جميع البيانات، هل تريد الاستمرار؟'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    formSaved = true;
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('تم'),
                ),
                TextButton(
                  onPressed: () {
                    formSaved = false;
                    Navigator.of(context).pop();
                  },
                  child: const Text('إلغاء'),
                ),
              ],
            ),
          );
          // return shouldPop ?? false;
        }
        // return didPop;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const CustomText(
            text: "إضافة بطولة جديدة",
            fontWeight: FontWeight.normal,
            fontSize: 30,
          ),
          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/sw1.jpg"), fit: BoxFit.fill),
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(screenHeight * 0.01),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.03),
                    // هنا ادخل اسم البطولة
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'ادخل الاسم..',
                        border: const OutlineInputBorder(),
                        labelText: 'اسم البطولة',
                        hoverColor: Theme.of(context).colorScheme.primary,
                      ),
                      controller: _nameController,
                      onChanged: (value) {},
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // هنا اختر مواعيد البطولة
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const CustomText(
                              text: ": إلى",
                              fontWeight: FontWeight.normal,
                              fontSize: 10,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _pickStartAndEndDate(context, false);
                              },
                              child: CustomText(
                                text: _endDate == '' ? 'حدد الوقت' : _endDate,
                                fontWeight: FontWeight.normal,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const CustomText(
                              text: ": من",
                              fontWeight: FontWeight.normal,
                              fontSize: 10,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _pickStartAndEndDate(context, true);
                              },
                              child: CustomText(
                                text:
                                    _startDate == '' ? 'حدد الوقت' : _startDate,
                                fontWeight: FontWeight.normal,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const CustomText(
                            text: ": فترة البطولة",
                            fontWeight: FontWeight.bold),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // هنا اختر المرحلة العمرية
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            DropdownButton<String>(
                              value: _selectedAgeStage,
                              items: stages[0].keys.toList().map((item) {
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
                                  ageStage = stages[0][_selectedAgeStage] ?? '';
                                  if (_selectedAgeStage == "١١ سنة") {
                                    age = 11;
                                  } else if (_selectedAgeStage == "١٢ سنة") {
                                    age = 12;
                                  } else if (_selectedAgeStage == "١٣ سنة") {
                                    age = 13;
                                  } else if (_selectedAgeStage == "١٤ سنة") {
                                    age = 14;
                                  } else if (_selectedAgeStage == "١٥ سنة") {
                                    age = 15;
                                  } else if (_selectedAgeStage == "عمومي") {
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
                    SizedBox(height: screenHeight * 0.02),
                    ElevatedButton(
                      onPressed: () {
                        _addRaceDialog(context, screenHeight);
                        setState(() {
                          participants = [];
                          selected = [];
                        });
                      },
                      child: const CustomText(
                          text: "إضافة", fontWeight: FontWeight.normal),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Column(
                      children: stage[0].entries.map((stage) {
                        return Card(
                          child: ListTile(
                            title: Text(stage.key),
                            subtitle: stage.value.isEmpty
                                ? const Text("لم يتم إضافة اي سباق")
                                : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: stage.value.map((race) {
                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text("${race['race']}"),
                                                Text("${race['date']}"),
                                                // Text("${race['time']}"),
                                                // ...race['swimmers'].map((e) => Text(e)).toList(),
                                              ],
                                            ),
                                            SizedBox(
                                              width: screenHeight * 0.01,
                                            )
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: ElevatedButton(
          onPressed: () {
            _submit(context);
          },
          child: const CustomText(text: "نم", fontWeight: FontWeight.normal),
        ),
      ),
    );
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
              content: SizedBox(
                height: double.infinity,
                child: Column(
                  children: [
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
                                    fontSize: 10,
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedRaceName = newValue!;
                                  raceName = races[0][_selectedRaceName] ?? '';
                                });
                              },
                            ),
                          ],
                        ),
                        const CustomText(
                          text: ": نوع السباق",
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButton<String>(
                          value: _selectedGender,
                          items: genderList[0].keys.toList().map((item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: CustomText(
                                text: item,
                                fontWeight: FontWeight.normal,
                                fontSize: 10,
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedGender = newValue!;
                              gender = genderList[0][_selectedGender] ?? '';
                            });
                          },
                        ),
                        const CustomText(
                          text: ": الجنس",
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
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
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: readData(age, gender),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Map<String, dynamic>>>
                                snapshot) {
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
                                      int count = countName(stage, swimmer['name']);
                                      if(count >= 5){
                                        _errorDialog(context, "لقد بلغ هذا السباح العدد الاقصى للسباقات المشترك بها.");
                                      }else{
                                        if(isSwimmerScheduled(swimmer['name'], _selectedDate, _selectedTime, stage[0][_selectedAgeStage]!)){
                                          _errorDialog(context, "السباح ${swimmer['name']} مشترك بالفعل في سباق آخر في نفس التاريخ والوقت.");
                                        }
                                        else{
                                          setState(() {
                                            selected[index] = !selected[index];
                                            // إضافة أو حذف اسم السباح من قائمة المشاركين
                                            if (selected[index]) {
                                              participants.add(swimmer['name']);
                                            } else {
                                              participants.remove(swimmer['name']);
                                            }
                                          });
                                        }

                                      }

                                    },

                                  ),
                                );
                              },
                            );
                          }
                          return const CustomText(
                              text: "لا يوجد سباحين",
                              fontWeight: FontWeight.bold);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Center(
                  child: ElevatedButton(

                    onPressed: () {
                      setState(() {
                        stage[0][_selectedAgeStage]!.add({
                          'race': _selectedRaceName!,
                          'date': _selectedDate,
                          'time': _selectedTime,
                          'swimmers': participants,
                          'gender': gender,
                        });
                      });
                      Navigator.of(context).pop();
                      _updateUI();
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
  bool isSwimmerScheduled(String swimmerName, String date, String time, List<Map<String, dynamic>> stages) {
    for (var stage in stages) {
      if (stage['date'] == date && stage['time'] == time && stage['swimmers'].contains(swimmerName)) {
        return true; // السباح موجود بالفعل في نفس التاريخ والوقت
      }
    }
    return false; // السباح غير موجود ويمكن إضافته
  }
  void _submit(BuildContext context) async{
    bool hasData = stage.any((map) => map.values.any((list) => list.isNotEmpty));
    if (_nameController.text.isEmpty) {
      _errorDialog(context, 'الرجاء إدخال اسم البطولة.');
      return;
    }else if (!hasData){
      _errorDialog(context, 'الرجاء إضافة سباق على الأقل.');
    }else{
      await sqlDb.insertData(
        '''
        INSERT INTO champ ('name', 'start', 'end')
        VALUES ("${_nameController.text}", "${_startDate.toString()}", "${_endDate.toString()}")
        '''
      );
      for(var category in stage){
        for (var ageStage in category.entries){
          for (var event in ageStage.value){
            if (event.isNotEmpty){
              // String raceTable = event['race'];
              String raceTable = getRaceTable(event['race'], races);
              String date = event['date'];
              String time = event['time'];
              String gender = event['gender'];
              List<String> swimmers = event['swimmers'];
              for (String swimmerName in swimmers){
                await sqlDb.insertData(
                  '''
                  INSERT INTO $raceTable (swimmerName, gender, ageStage, date, time, champName)
                  VALUES ("$swimmerName", "$gender", "${getAgeStage(ageStage.key, stages)}", "$date", "$time", "${_nameController.text}")
                  '''
                );
              }
            }
          }
        }
      }
      formSaved = true;
      Navigator.of(context).pop();

    }
  }
  String getRaceTable(String raceName, List<Map> races) {
    for (var raceMap in races) {
      if (raceMap.containsKey(raceName)) {
        return raceMap[raceName];
      }
    }
    return '';
  }
  String getAgeStage(String ageStage, List<Map> stages) {
    for (var raceMap in stages) {
      if (raceMap.containsKey(ageStage)) {
        return raceMap[ageStage];
      }
    }
    return '';
  }
  void _updateUI() {
    setState(() {});
  }
  void _errorDialog(BuildContext context, String text){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تنبيه'),
          content: Text(text),
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
  }
  int countName(List<Map<String, List<Map<String, dynamic>>>> stage, String name) {
    int count = 0;
    for (var ageGroup in stage) {
      for (var races in ageGroup.values) {
        for (var race in races) {
          List<dynamic> swimmers = race['swimmers'];
          if (swimmers.contains(name)) {
            count++;
          }
        }
      }
    }
    return count;
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
}
