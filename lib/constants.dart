import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


List<Map> races = [
  {
    '٥٠ متر حرة': 'free_50m',
    '١٠٠ متر حرة': 'free_100m',
    '٢٠٠ متر حرة': 'free_200m',
    '٤٠٠ متر حرة': 'free_400m',
    '٨٠٠ متر حرة': 'free_800m',
    '١٥٠٠ متر حرة': 'free_1500m',
    '٥٠ متر صدر': 'breast_50m',
    '١٠٠ متر صدر': 'breast_100m',
    '٢٠٠ متر صدر': 'breast_200m',
    '٥٠ متر ظهر': 'back_50m',
    '١٠٠ متر ظهر': 'back_100m',
    '٢٠٠ متر ظهر': 'back_200m',
    '٥٠ متر فراشة': 'butterfly_50m',
    '١٠٠ متر فراشة': 'butterfly_100m',
    '٢٠٠ متر فراشة': 'butterfly_200m',
    '٢٠٠ متر متنوع': 'medley_200m',
    '٤٠٠ متر متنوع': 'medley_400m',
  }
];

List<Map> stages = [
  {
    '١١ سنة': 'year_11',
    '١٢ سنة': 'year_12',
    '١٣ سنة': 'year_13',
    '١٤ سنة': 'year_14',
    '١٥ سنة': 'year_15',
    'عمومي': 'public',
  }
];
List<Map> genderList = [
  {
    'ذكور': 'male',
    'إناث': 'female',
    'الكل': 'all',
  }
];
class CustomText extends StatelessWidget {
  final String text;
  final FontWeight fontWeight;
  final double fontSize;
  const CustomText({super.key, required this.text, required this.fontWeight, this.fontSize = 20.0});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize.sp,
        fontWeight: fontWeight,

      ),
    );
  }
}
