import 'package:flutter/material.dart';
import 'package:swimming/constants.dart';
import 'package:swimming/data/db.dart';

Widget myDrawer(context){
  SqlDb sqlDb = SqlDb();
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
         DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
          ),
          child:  const CustomText(text: "المدرب", fontWeight: FontWeight.bold),
        ),
        // ListTile(
        //   title: const Text('حذف قاعدة البيانات'),
        //   onTap: () async{
        //     await sqlDb.deleteMyDatabase();
        //   },
        // ),
        // ListTile(
        //   title: const Text('الاعدادات'),
        //   onTap: () {
        //   },
        // ),
      ],
    ),
  );
}