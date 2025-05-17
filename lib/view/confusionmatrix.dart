import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:omvoting/Model/fundusModel.dart';
import 'package:omvoting/ViewModel/fundusViewModel.dart';

class ConfusionMatrixPage extends StatefulWidget {
  const ConfusionMatrixPage({super.key});

  @override
  State<ConfusionMatrixPage> createState() => _ConfusionMatrixPageState();
}

class _ConfusionMatrixPageState extends State<ConfusionMatrixPage> {
  final fundusViewModel _viewModel = fundusViewModel();
  // Class labels
  final List<String> classLabels = ['NL', 'CA', 'GL', 'DR'];

  late Map<String, int> labelIndex;
  late List<List<int>> confusionMatrix;

  @override
  void initState() {
    super.initState();
    _viewModel.fetchAllFundus();
    labelIndex = {
      for (int i = 0; i < classLabels.length; i++) classLabels[i]: i
    };
    confusionMatrix = List.generate(
        classLabels.length, (_) => List.filled(classLabels.length, 0));
  }

  Widget buildConfusionMatrixTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Table(
            border: TableBorder.all(color: Colors.grey),
            defaultColumnWidth: const FixedColumnWidth(50),
            children: [
              // Header row
              TableRow(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'AL / PL',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ...classLabels.map((label) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            label,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )),
                ],
              ),
              // Data rows
              for (int i = 0; i < classLabels.length; i++)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        classLabels[i],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    for (int j = 0; j < classLabels.length; j++)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                            child: Text(confusionMatrix[i][j].toString())),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String normalizeLabel(String rawLabel) {
    rawLabel = rawLabel.toLowerCase();

    if (rawLabel.contains('normal')) return 'NL';
    if (rawLabel.contains('cataract')) return 'CA';
    if (rawLabel.contains('glaucoma')) return 'GL';
    if (rawLabel.contains('diabetic') || rawLabel.contains('dr')) return 'DR';

    return rawLabel; // fallback to original if unmatched
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confusion Matrix'),
      ),
      body: StreamBuilder<List<fundus_Model>>(
        stream: _viewModel.allFundusList.stream,
        builder: (context, snapshot) {
          if (_viewModel.isLoading.value &&
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final List<fundus_Model>? fundusList = snapshot.data;

          if (fundusList == null || fundusList.isEmpty) {
            return const Center(child: Text('No fundus data available!'));
          }

          // Reset confusion matrix on each data update
          confusionMatrix = List.generate(
              classLabels.length, (_) => List.filled(classLabels.length, 0));

          // Process fundus data to update the confusion matrix
          for (var fu in fundusList) {
            final actual = normalizeLabel(fu.orginal);
            final predicted = normalizeLabel(fu.result);

            if (labelIndex.containsKey(actual) &&
                labelIndex.containsKey(predicted)) {
              final i = labelIndex[actual]!;
              final j = labelIndex[predicted]!;

              confusionMatrix[i][j]++;
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: buildConfusionMatrixTable(),
          );
        },
      ),
    );
  }
}
