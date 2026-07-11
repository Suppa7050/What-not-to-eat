import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../domain/scan_result.dart';

class ResultScreen extends StatelessWidget {
  final ScanResult result;

  const ResultScreen({super.key, required this.result});

  Color _getIndicatorColor() {
    switch (result.overallIndicator) {
      case 'GREEN': return Colors.green;
      case 'YELLOW': return Colors.orange;
      case 'RED': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analysis Result')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildScoreSection(context),
            const SizedBox(height: 24),
            _buildSummaryCard(context),
            const SizedBox(height: 24),
            if (result.warnings.isNotEmpty) _buildWarningsSection(context),
            const SizedBox(height: 16),
            _buildIngredientList(context, 'Ingredients to Avoid', result.badIngredients),
            const SizedBox(height: 16),
            _buildListSection(context, 'Good Ingredients', result.goodIngredients, Colors.green),
            const SizedBox(height: 16),
            _buildListSection(context, 'Neutral Ingredients', result.neutralIngredients, Colors.grey),
            const SizedBox(height: 24),
            _buildListSection(context, 'Health Benefits', result.healthBenefits, Colors.blue),
            const SizedBox(height: 16),
            _buildListSection(context, 'Health Risks', result.healthRisks, Colors.orange),
            const SizedBox(height: 24),
            Text(
              result.disclaimer,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSection(BuildContext context) {
    return Column(
      children: [
        Text(result.productName, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        CircularPercentIndicator(
          radius: 80.0,
          lineWidth: 16.0,
          animation: true,
          animationDuration: 1200,
          percent: result.overallHealthScore / 100,
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                result.overallHealthScore.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 36.0),
              ),
              Text(
                '/ 100',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: _getIndicatorColor(),
          backgroundColor: Colors.grey.withOpacity(0.2),
        ),
        const SizedBox(height: 16),
        Chip(
          label: Text(
            result.overallIndicator,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: _getIndicatorColor(),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(result.summary, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningsSection(BuildContext context) {
    return Card(
      color: Colors.red.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                Text('Warnings', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.red)),
              ],
            ),
            const SizedBox(height: 8),
            ...result.warnings.map((w) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  Expanded(child: Text(w)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildListSection(BuildContext context, String title, List<String> items, Color iconColor) {
    if (items.isEmpty) return const SizedBox.shrink();
    
    return Card(
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: Icon(Icons.list_alt, color: iconColor),
        children: items.map((item) => ListTile(
          leading: Icon(Icons.check_circle, size: 16, color: iconColor),
          title: Text(item),
        )).toList(),
      ),
    );
  }

  Widget _buildIngredientList(BuildContext context, String title, List<IngredientDetail> ingredients) {
    if (ingredients.isEmpty) return const SizedBox.shrink();

    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        leading: const Icon(Icons.dangerous, color: Colors.red),
        children: ingredients.map((ing) {
          return ExpansionTile(
            title: Text(ing.ingredient, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(ing.category),
            leading: CircleAvatar(
              backgroundColor: ing.indicator == 'RED' ? Colors.red : Colors.orange,
              child: Text(ing.healthScore.toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (ing.avoid) 
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text('AVOID', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    Text('Reason: ${ing.reason}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(ing.details),
                  ],
                ),
              )
            ],
          );
        }).toList(),
      ),
    );
  }
}
