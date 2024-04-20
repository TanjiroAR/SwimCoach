import 'package:flutter/material.dart';

class CategorySwimmer {
  final String id;
  final String name;
  final String photo;
  final String age;
  final List<String> trainingDate;
  final List<String> trainingTime;
  final List<String> champs;
  final List<String> scores;

  CategorySwimmer({
    required this.id,
    required this.name,
    required this.photo,
    required this.age,
    required this.trainingDate,
    required this.trainingTime,
    required this.champs,
    required this.scores,
  });
}
