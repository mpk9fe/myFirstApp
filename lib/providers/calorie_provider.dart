import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_entry.dart';
import '../database/database_helper.dart';

class CalorieProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<FoodEntry> _allEntries = [];
  int _dailyCalorieGoal = 2000;
  int _dataRetentionDays = 90;
  bool _isInitialized = false;

  List<FoodEntry> get allEntries => _allEntries;
  int get dailyCalorieGoal => _dailyCalorieGoal;
  int get dataRetentionDays => _dataRetentionDays;
  bool get isInitialized => _isInitialized;

  CalorieProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _loadSettings();
      await loadAllEntries();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing CalorieProvider: $e');
      _isInitialized = true; // Set to true anyway to show UI
      notifyListeners();
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _dailyCalorieGoal = prefs.getInt('dailyCalorieGoal') ?? 2000;
    _dataRetentionDays = prefs.getInt('dataRetentionDays') ?? 90;
    notifyListeners();
  }

  Future<void> setDailyCalorieGoal(int goal) async {
    _dailyCalorieGoal = goal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyCalorieGoal', goal);
    notifyListeners();
  }

  Future<void> setDataRetentionDays(int days) async {
    _dataRetentionDays = days;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dataRetentionDays', days);
    await _dbHelper.deleteOldEntries(days);
    await loadAllEntries();
    notifyListeners();
  }

  Future<void> loadAllEntries() async {
    try {
      _allEntries = await _dbHelper.getAllFoodEntries();
      notifyListeners();
    } catch (e) {
      print('Error loading entries: $e');
      _allEntries = [];
      notifyListeners();
    }
  }

  Future<void> addFoodEntry(FoodEntry entry) async {
    try {
      print('Adding food entry: ${entry.name}');
      await _dbHelper.insertFoodEntry(entry);
      await loadAllEntries();
      print('Food entry added successfully');
    } catch (e) {
      print('Error adding food entry: $e');
      rethrow;
    }
  }

  Future<void> updateFoodEntry(FoodEntry entry) async {
    await _dbHelper.updateFoodEntry(entry);
    await loadAllEntries();
  }

  Future<void> deleteFoodEntry(int id) async {
    await _dbHelper.deleteFoodEntry(id);
    await loadAllEntries();
  }

  List<FoodEntry> getEntriesForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _allEntries.where((entry) {
      return entry.dateTime.isAfter(startOfDay) &&
          entry.dateTime.isBefore(endOfDay);
    }).toList();
  }

  int getTotalCaloriesForDate(DateTime date) {
    final entries = getEntriesForDate(date);
    return entries.fold(0, (sum, entry) => sum + entry.calories);
  }

  List<FoodEntry> getEntriesInRange(DateTime start, DateTime end) {
    return _allEntries.where((entry) {
      return entry.dateTime.isAfter(start) && entry.dateTime.isBefore(end);
    }).toList();
  }

  int getTotalCaloriesInRange(DateTime start, DateTime end) {
    final entries = getEntriesInRange(start, end);
    return entries.fold(0, (sum, entry) => sum + entry.calories);
  }

  Map<DateTime, int> getDailyCaloriesForWeek(DateTime date) {
    final Map<DateTime, int> dailyCalories = {};
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));

    for (int i = 0; i < 7; i++) {
      final day = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day + i,
      );
      dailyCalories[day] = getTotalCaloriesForDate(day);
    }

    return dailyCalories;
  }

  Map<DateTime, int> getDailyCaloriesForMonth(DateTime date) {
    final Map<DateTime, int> dailyCalories = {};
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;

    for (int i = 1; i <= daysInMonth; i++) {
      final day = DateTime(date.year, date.month, i);
      dailyCalories[day] = getTotalCaloriesForDate(day);
    }

    return dailyCalories;
  }

  double getAverageDailyCalories(int days) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final entries = getEntriesInRange(startDate, now);

    if (entries.isEmpty) return 0;

    final totalCalories = entries.fold(0, (sum, entry) => sum + entry.calories);
    return totalCalories / days;
  }
}
