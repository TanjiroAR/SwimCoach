import 'package:flutter/material.dart';
import 'package:swimming/screens/champ_screen.dart';
import 'package:swimming/screens/home_screen.dart';
import 'package:swimming/screens/swim_screen.dart';
import 'package:swimming/widgets/drawer.dart';
import 'package:swimming/widgets/navigation_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const ChampPage(),
    const SwimPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: myDrawer(context),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
            image: DecorationImage(
          image: AssetImage("images/sw1.jpg"),
          fit: BoxFit.cover,
        )),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).colorScheme.background.withOpacity(0.7),
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar:
          myNavigationBar(_selectedIndex, _onItemTapped, context),
    );
  }
}
