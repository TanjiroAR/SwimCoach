import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:SwimCoach/screens/main_screen.dart';
import 'package:SwimCoach/widgets/dark_theme.dart';
import 'package:SwimCoach/widgets/light_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_ , child){
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SwimCoach',
          theme: lightTheme,
          darkTheme: darkTheme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales:const [
            Locale('en', 'US'), // English, US
            // Locale('en', 'GB'), // English, UK
          ],
          home: const MainScreen(),
        );
      },

    );
  }
}
