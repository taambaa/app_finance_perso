import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:app_finance_perso/models/expense.dart';
import 'package:app_finance_perso/models/income.dart';
import 'package:app_finance_perso/services/firestore_service.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Résumé des totaux
            StreamBuilder<List<Income>>(
              stream: firestoreService.getIncomes(),
              builder: (context, incomeSnapshot) {
                return StreamBuilder<List<Expense>>(
                  stream: firestoreService.getExpenses(),
                  builder: (context, expenseSnapshot) {
                    final incomes = incomeSnapshot.data ?? [];
                    final expenses = expenseSnapshot.data ?? [];
                    final totalIncome = incomes.fold<double>(0, (sum, i) => sum + i.amount);
                    final totalExpense = expenses.fold<double>(0, (sum, e) => sum + e.amount);
                    final balance = totalIncome - totalExpense;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'Résumé Financier',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildSummaryItem(
                                  'Revenus',
                                  currencyFormat.format(totalIncome),
                                  Colors.green,
                                  Icons.trending_up,
                                ),
                                _buildSummaryItem(
                                  'Dépenses',
                                  currencyFormat.format(totalExpense),
                                  Colors.red,
                                  Icons.trending_down,
                                ),
                                _buildSummaryItem(
                                  'Solde',
                                  currencyFormat.format(balance),
                                  balance >= 0 ? Colors.blue : Colors.orange,
                                  Icons.account_balance_wallet,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            // Graphique en secteurs des dépenses par catégorie
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Répartition des Dépenses',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: StreamBuilder<List<Expense>>(
                        stream: firestoreService.getExpenses(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text('Aucune dépense à afficher'),
                            );
                          }

                          final expenses = snapshot.data!;
                          final expenseByCategory = <String, double>{};
                          
                          for (final expense in expenses) {
                            expenseByCategory[expense.label] = 
                                (expenseByCategory[expense.label] ?? 0) + expense.amount;
                          }

                          final sections = expenseByCategory.entries.map((entry) {
                            final color = _getRandomColor(entry.key.hashCode);
                            return PieChartSectionData(
                              value: entry.value,
                              title: '${entry.value.toStringAsFixed(0)}€',
                              color: color,
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList();

                          return PieChart(
                            PieChartData(
                              sections: sections,
                              centerSpaceRadius: 40,
                              sectionsSpace: 2,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Légende
                    StreamBuilder<List<Expense>>(
                      stream: firestoreService.getExpenses(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        final expenses = snapshot.data!;
                        final expenseByCategory = <String, double>{};
                        
                        for (final expense in expenses) {
                          expenseByCategory[expense.label] = 
                              (expenseByCategory[expense.label] ?? 0) + expense.amount;
                        }

                        return Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: expenseByCategory.entries.map((entry) {
                            final color = _getRandomColor(entry.key.hashCode);
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  color: color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${entry.key} (${currencyFormat.format(entry.value)})',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Graphique en barres de l'évolution mensuelle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Évolution Mensuelle',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: StreamBuilder<List<Income>>(
                        stream: firestoreService.getIncomes(),
                        builder: (context, incomeSnapshot) {
                          return StreamBuilder<List<Expense>>(
                            stream: firestoreService.getExpenses(),
                            builder: (context, expenseSnapshot) {
                              if (!incomeSnapshot.hasData || !expenseSnapshot.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              final incomes = incomeSnapshot.data!;
                              final expenses = expenseSnapshot.data!;
                              
                              // Grouper par mois
                              final monthlyData = <String, Map<String, double>>{};
                              
                              for (final income in incomes) {
                                final monthKey = DateFormat('yyyy-MM').format(income.incomeDate);
                                monthlyData.putIfAbsent(monthKey, () => {'income': 0, 'expense': 0});
                                monthlyData[monthKey]!['income'] = 
                                    (monthlyData[monthKey]!['income'] ?? 0) + income.amount;
                              }
                              
                              for (final expense in expenses) {
                                final monthKey = DateFormat('yyyy-MM').format(expense.expenseDate);
                                monthlyData.putIfAbsent(monthKey, () => {'income': 0, 'expense': 0});
                                monthlyData[monthKey]!['expense'] = 
                                    (monthlyData[monthKey]!['expense'] ?? 0) + expense.amount;
                              }

                              final sortedMonths = monthlyData.keys.toList()..sort();
                              if (sortedMonths.isEmpty) {
                                return const Center(
                                  child: Text('Aucune donnée à afficher'),
                                );
                              }

                              return BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: monthlyData.values.fold(0.0, (max, data) => 
                                      (data['income'] ?? 0) > max ? (data['income'] ?? 0) : max) * 1.2,
                                  barTouchData: BarTouchData(enabled: false),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          if (value.toInt() >= 0 && value.toInt() < sortedMonths.length) {
                                            final month = sortedMonths[value.toInt()];
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                DateFormat('MMM yyyy').format(DateFormat('yyyy-MM').parse(month)),
                                                style: const TextStyle(fontSize: 10),
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            currencyFormat.format(value),
                                            style: const TextStyle(fontSize: 10),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: List.generate(sortedMonths.length, (index) {
                                    final month = sortedMonths[index];
                                    final data = monthlyData[month]!;
                                    return BarChartGroupData(
                                      x: index,
                                      barRods: [
                                        BarChartRodData(
                                          toY: data['income'] ?? 0,
                                          color: Colors.green,
                                          width: 8,
                                        ),
                                        BarChartRodData(
                                          toY: data['expense'] ?? 0,
                                          color: Colors.red,
                                          width: 8,
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(width: 12, height: 12, color: Colors.green),
                            const SizedBox(width: 4),
                            const Text('Revenus'),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Row(
                          children: [
                            Container(width: 12, height: 12, color: Colors.red),
                            const SizedBox(width: 4),
                            const Text('Dépenses'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Color _getRandomColor(int seed) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];
    return colors[seed % colors.length];
  }
} 