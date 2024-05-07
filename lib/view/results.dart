import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:omvoting/component/partes.dart';
import 'package:omvoting/model/candList_app2_model.dart';
import 'package:omvoting/model/partieslist_app2_model.dart';
import 'package:omvoting/viewModel/candListApp2_viewModel.dart';
import 'package:omvoting/viewModel/partilistApp2_viewModel.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MyWidgetRes extends StatefulWidget {
  const MyWidgetRes({super.key});

  @override
  State<MyWidgetRes> createState() => _MyWidgetResState();
}

class _MyWidgetResState extends State<MyWidgetRes> {
  final CandView_Model _candViewModel = CandView_Model();
  final PartyViewModel _partyViewModel = PartyViewModel();
  @override
  void initState() {
    _candViewModel.onInit();
    _partyViewModel.onInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 243, 160, 160),
                      Color.fromARGB(255, 238, 226, 226),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.center,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 77, 75, 75)
                          .withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: const Text(
                  'Candidate Votes',
                  style: TextStyle(fontFamily: 'georgia'),
                ),
              ),
            ),
            SizedBox(
              height: 400,
              child: StreamBuilder<List<CandListApp2_Model>>(
                stream: _candViewModel.allCandList.stream,
                builder: (context, snapshot) {
                  if (_candViewModel.isLoading.value &&
                      snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final List<ChartData> chartData =
                      snapshot.data!.map((candidate) {
                    return ChartData(candidate.candName, candidate.candVotes);
                  }).toList();
                  return Container(
                    margin: const EdgeInsets.only(left: 22, right: 22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 228, 225, 225),
                          Color.fromARGB(255, 255, 255, 255),
                        ],
                        begin: Alignment.center,
                        end: Alignment.centerLeft,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 77, 75, 75)
                              .withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: SfCartesianChart(
                      zoomPanBehavior: ZoomPanBehavior(
                        enablePanning: true,
                      ),
                      primaryXAxis: const CategoryAxis(
                        majorGridLines: MajorGridLines(width: 0),
                        plotOffset: 10,
                        autoScrollingDelta: 8,
                        borderColor: Color.fromARGB(31, 192, 17, 17),
                        labelStyle: TextStyle(fontFamily: 'georgia'),
                        autoScrollingMode: AutoScrollingMode.end,
                      ),
                      series: <CartesianSeries>[
                        BarSeries<ChartData, String>(
                          dataSource: chartData,
                          xValueMapper: (ChartData data, _) => data.a,
                          yValueMapper: (ChartData data, _) => data.b,
                          color: const Color.fromARGB(150, 220, 66, 66),
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                            textStyle: TextStyle(
                              fontFamily: 'georgia',
                              fontSize: 16,
                              color: Color.fromARGB(255, 21, 1, 48),
                            ),
                          ),
                          enableTooltip: true,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
              child: StreamBuilder<List<PartiesListApp2Model>>(
                stream: _partyViewModel.allPartyList.stream,
                builder: (context, snapshot) {
                  if (_partyViewModel.isLoading.value &&
                      snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final List<PartiesListApp2Model>? parties = snapshot.data;

                  if (parties == null || parties.isEmpty) {
                    return const Center(child: Text('No parties available'));
                  }

                  return ListView.builder(
                    itemCount: parties.length,
                    itemBuilder: (context, index) {
                      final cn = parties[index];
                      return MyWidgetParties(
                        partiName: cn.partyName,
                        partiVotes: cn.partyVotes.toString(),
                        partiPercent: '61%',
                        colorChoose: Colors.yellow,
                        img: cn.image,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String a;
  final int b;

  ChartData(
    this.a,
    this.b,
  );
}
