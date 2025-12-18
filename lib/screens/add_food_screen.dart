import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/calorie_provider.dart';
import '../models/food_entry.dart';

class AddFoodScreen extends StatefulWidget {
  final DateTime selectedDate;

  const AddFoodScreen({super.key, required this.selectedDate});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  late DateTime _selectedDateTime;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.selectedDate;
    _selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food Entry'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Food name field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Food Name',
                    hintText: 'e.g., Chicken Salad',
                    prefixIcon: Icon(Icons.restaurant),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a food name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Calories field
                TextFormField(
                  controller: _caloriesController,
                  decoration: const InputDecoration(
                    labelText: 'Calories',
                    hintText: 'e.g., 350',
                    prefixIcon: Icon(Icons.local_fire_department),
                    border: OutlineInputBorder(),
                    suffixText: 'cal',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter calories';
                    }
                    final calories = int.tryParse(value);
                    if (calories == null || calories <= 0) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Date picker
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      DateFormat('EEEE, MMMM d, y').format(_selectedDateTime),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Time picker
                InkWell(
                  onTap: _selectTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      prefixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(_selectedTime.format(context)),
                  ),
                ),

                const SizedBox(height: 24),

                // Quick calorie buttons
                const Text(
                  'Quick Add',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildQuickCalorieChip('Snack (100 cal)', 100),
                    _buildQuickCalorieChip('Light Meal (300 cal)', 300),
                    _buildQuickCalorieChip('Medium Meal (500 cal)', 500),
                    _buildQuickCalorieChip('Large Meal (800 cal)', 800),
                  ],
                ),

                const SizedBox(height: 32),

                // Save button
                ElevatedButton(
                  onPressed: _saveFoodEntry,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Entry',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCalorieChip(String label, int calories) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        setState(() {
          _caloriesController.text = calories.toString();
        });
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _saveFoodEntry() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<CalorieProvider>(context, listen: false);

      final entry = FoodEntry(
        name: _nameController.text.trim(),
        calories: int.parse(_caloriesController.text),
        dateTime: _selectedDateTime,
      );

      await provider.addFoodEntry(entry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food entry added successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}
