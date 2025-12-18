import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/food_entry.dart';

class WebStorageHelper {
  static const String _entriesKey = 'food_entries';

  Future<List<FoodEntry>> getAllFoodEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? entriesJson = prefs.getString(_entriesKey);
      
      if (entriesJson == null || entriesJson.isEmpty) {
        print('No entries found in storage');
        return [];
      }

      final List<dynamic> decoded = jsonDecode(entriesJson);
      final entries = decoded.map((json) => FoodEntry.fromMap(json)).toList();
      print('Retrieved ${entries.length} entries from web storage');
      return entries;
    } catch (e) {
      print('Error loading entries from web storage: $e');
      return [];
    }
  }

  Future<int> insertFoodEntry(FoodEntry entry) async {
    try {
      final entries = await getAllFoodEntries();
      
      // Generate a simple ID
      final id = entries.isEmpty ? 1 : entries.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      final entryWithId = entry.copyWith(id: id);
      
      entries.add(entryWithId);
      await _saveEntries(entries);
      
      print('Inserted food entry: ${entry.name}, ID: $id');
      return id;
    } catch (e) {
      print('Error inserting food entry to web storage: $e');
      rethrow;
    }
  }

  Future<void> deleteFoodEntry(int id) async {
    try {
      final entries = await getAllFoodEntries();
      entries.removeWhere((entry) => entry.id == id);
      await _saveEntries(entries);
      print('Deleted food entry with ID: $id');
    } catch (e) {
      print('Error deleting food entry from web storage: $e');
      rethrow;
    }
  }

  Future<void> deleteOldEntries(int daysToKeep) async {
    try {
      final entries = await getAllFoodEntries();
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      
      final filtered = entries.where((entry) => entry.dateTime.isAfter(cutoffDate)).toList();
      await _saveEntries(filtered);
      print('Deleted entries older than $daysToKeep days');
    } catch (e) {
      print('Error deleting old entries from web storage: $e');
      rethrow;
    }
  }

  Future<void> _saveEntries(List<FoodEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = entries.map((e) => e.toMap()).toList();
    final String encoded = jsonEncode(jsonList);
    await prefs.setString(_entriesKey, encoded);
    print('Saved ${entries.length} entries to web storage');
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_entriesKey);
    print('Cleared all entries from web storage');
  }
}
