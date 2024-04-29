import 'package:flutter/material.dart';

Widget myNavigationBar(selectedIndex, onItemTapped, context) {
  return BottomNavigationBar(
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'الرئيسية',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.add_alert),
        label: 'البطولات',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_circle_outlined),
        label: 'السباحون',
      ),
    ],
    currentIndex: selectedIndex,
    selectedItemColor: Theme.of(context).colorScheme.primary,
    onTap: onItemTapped,
  );
}
