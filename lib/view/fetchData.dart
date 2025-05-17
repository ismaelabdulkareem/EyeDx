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

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _viewModel.fetchAllFundus();
  }

  // Method to display the actual and predicted values
  Widget displayOriginalAndResult(List<fundus_Model> fundusList) {
    return ListView.builder(
      itemCount: fundusList.length,
      itemBuilder: (context, index) {
        final fundus = fundusList[index];
        final original = fundus.orginal;
        final result = fundus.result;
        return ListTile(
          title: Text("Original: $original, Result: $result"),
        );
      },
    );
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

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: displayOriginalAndResult(fundusList),
          );
        },
      ),
    );
  }
}
