import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omvoting/ViewModel/fundusViewModel.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class FetchFundusDitail extends StatefulWidget {
  final String documentId;
  final String Name;
  final String Orginal;
  final String Date;
  final String Result;
  final String Pic;

  const FetchFundusDitail({
    super.key,
    required this.documentId,
    required this.Name,
    required this.Orginal,
    required this.Date,
    required this.Result,
    required this.Pic,
  });
  @override
  State<FetchFundusDitail> createState() => _FetchFundusDitailState();
}

class _FetchFundusDitailState extends State<FetchFundusDitail> {
  final fundusViewModel _viewModel = fundusViewModel();
  String _fileSize = '';
  String _dimensions = '';

  @override
  void initState() {
    super.initState();
    _loadImageInfo(widget.Pic);
  }

  Future<void> _loadImageInfo(String url) async {
    try {
      final image = NetworkImage(url);
      image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          final uiImage = info.image;
          if (mounted) {
            setState(() {
              _dimensions = "${uiImage.width}×${uiImage.height}";
            });
          }
        }),
      );

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes.length;
        if (mounted) {
          setState(() {
            _fileSize = "${(bytes / 1024).toStringAsFixed(1)} KB";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _fileSize = "N/A";
          _dimensions = "N/A";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // my style
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
      margin: const EdgeInsets.only(left: 10, right: 10, top: 15),

      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _imageContainer(widget.Pic),
            _tableFundusProperty(widget.documentId, widget.Name, widget.Orginal,
                widget.Date, widget.Result, widget.Pic),
            const SizedBox(
              height: 15,
            ),
            // Positioned button at the bottom with an icon inside
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 238, 94, 75),
                foregroundColor: const Color.fromARGB(255, 212, 121, 121),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'georgia',
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ],
              ),
              onPressed: () async {
                HapticFeedback.vibrate();
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    contentPadding: EdgeInsets.zero, // Remove default padding
                    content: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 243, 175, 72),
                            Color.fromARGB(255, 255, 223, 154),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 25),
                            child: Text(
                              'Are you sure that you want to delete this record from database?',
                              textAlign: TextAlign.justify,
                              style: TextStyle(fontFamily: 'georgia'),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(fontFamily: 'georgia'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(fontFamily: 'georgia'),
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                );
                if (confirm == true) {
                  _viewModel.deleteFundus(widget.documentId, widget.Pic);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                        'Record deleted successfully',
                        style: TextStyle(
                          color: Color.fromARGB(255, 141, 212, 58),
                          fontFamily: 'georgia',
                        ),
                      )),
                    );
                    Navigator.of(context)
                        .pop(); // Optional: Close the detail view
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                      'Record deletion canceled',
                      style: TextStyle(
                        color: Colors.orange,
                        fontFamily: 'georgia',
                      ),
                    )),
                  );
                }
              },
            ),
          ]),
    );
  }

  Widget _imageContainer(String image) {
    return Container(
      width: 350, // Adjust size here
      height: 250,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Colors.orange,
              Color.fromARGB(100, 235, 224, 191),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(3), // Border thickness
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black, // Or use Colors.transparent if needed
            ),
            child: Image.network(
              image.isNotEmpty
                  ? image
                  : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSwWl4ngiL0w69Hjqe9Pm5jYcmOCEBG0TQ9z__FTcE3ed3Cx1kWO32Ue-UExwj0BXYzn9Y&usqp=CAU',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _tableFundusProperty(String documentId, String name, String orginal,
      String date, String result, String pic) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(3),
        },
        children: [
          // Header row with only top and bottom borders
          const TableRow(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                    color: Color.fromARGB(255, 119, 119, 119),
                    width: 1), // Top border
                bottom: BorderSide(
                    color: Color.fromARGB(255, 119, 119, 119),
                    width: 1), // Bottom border
              ),
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Image Property',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'georgia',
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Value",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'georgia',
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          // Thin line below the header
          TableRow(
            children: [
              TableCell(
                child: Container(
                  height: 0.5,
                  color: const Color.fromARGB(66, 61, 61, 61),
                ),
              ),
              const SizedBox.shrink(), // empty cell to match column count
            ],
          ),

          // Other rows without borders
          _tableRow('True Label', orginal),
          _tableRow('Prediction:', result),
          _tableRow('Date created:', date),
          _tableRow('Image name:', name),
          _tableRow('Resolution',
              _dimensions), // Replace `name` with actual resolution
          _tableRow(
              'File size', _fileSize), // Replace `name` with actual file size

          // Add another thin line below the last row
          TableRow(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                    color: Color.fromARGB(255, 94, 93, 93),
                    width: 1), // Top border
              ),
            ),
            children: [
              TableCell(
                child: Container(),
              ),
              const SizedBox.shrink(), // empty cell to match column count
            ],
          ),
        ],
      ),
    );
  }

  /// Helper function for reusable table rows
  TableRow _tableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              fontFamily: 'georgia',
              color: Colors.white,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'georgia',
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
