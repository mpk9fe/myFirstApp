import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/calorie_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedTab = 0; // 0: Week, 1: Month

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Consumer<CalorieProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Tab selector
              Padding(
                padding: const EdgeInsets.all(16),
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(
                      value: 0,
                      label: Text('Week'),
                      icon: Icon(Icons.view_week),
                    ),
                    ButtonSegment(
                      value: 1,
                      label: Text('Month'),
                      icon: Icon(Icons.calendar_month),
                    ),
                  ],
                  selected: {_selectedTab},
                  onSelectionChanged: (Set<int> selected) {
                    setState(() {
                      _selectedTab = selected.first;
                    });
                  },
                ),
              ),

              // Average calories card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Average Daily Calories',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedTab == 0
                              ? '${provider.getAverageDailyCalories(7).toStringAsFixed(0)} cal'
                              : '${provider.getAverageDailyCalories(30).toStringAsFixed(0)} cal',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedTab == 0 ? 'Last 7 days' : 'Last 30 days',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Daily breakdown
              Expanded(
                child: _selectedTab == 0
                    ? _buildWeeklyBreakdown(provider)
                    : _buildMonthlyBreakdown(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWeeklyBreakdown(CalorieProvider provider) {
    final now = DateTime.now();
    final dailyCalories = provider.getDailyCaloriesForWeek(now);
    final sortedDates = dailyCalories.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final calories = dailyCalories[date] ?? 0;
        final goal = provider.dailyCalorieGoal;
        final progress = calories / goal;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEEE, MMM d').format(date),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '$calories cal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _getCalorieColor(progress),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress > 1.0 ? 1.0 : progress,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getCalorieColor(progress),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% of goal',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthlyBreakdown(CalorieProvider provider) {
    final now = DateTime.now();
    final dailyCalories = provider.getDailyCaloriesForMonth(now);
    final sortedDates = dailyCalories.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final calories = dailyCalories[date] ?? 0;
        final goal = provider.dailyCalorieGoal;
        final progress = calories / goal;

        // Skip days with no entries
        if (calories == 0) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEEE, MMM d').format(date),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '$calories cal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _getCalorieColor(progress),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress > 1.0 ? 1.0 : progress,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getCalorieColor(progress),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% of goal',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getCalorieColor(double progress) {
    if (progress < 0.7) {
      return Colors.green;
    } else if (progress < 1.0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
