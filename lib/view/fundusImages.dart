import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

class FundusImages extends StatefulWidget {
  final String Name;
  final String Orginal;
  final String Date;
  final String Result;
  final String Pic;

  const FundusImages({
    super.key,
    required this.Name,
    required this.Orginal,
    required this.Date,
    required this.Result,
    required this.Pic,
  });

  @override
  State<FundusImages> createState() => _FundusImagesState();
}

class _FundusImagesState extends State<FundusImages> {
  String _fileSize = '';
  String _dimensions = '';

  @override
  void initState() {
    super.initState();
    _loadImageInfo(widget.Pic);
  }

  Future<void> _loadImageInfo(String url) async {
    try {
      // Load image dimensions
      final image = NetworkImage(url);
      final completer = Completer<ui.Image>();
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

      // Load image size
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes.length;
        if (mounted) {
          setState(() {
            _fileSize = "${(bytes / 1024 / 1024).toStringAsFixed(1)} MB";
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
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(170, 228, 225, 225),
            Color.fromARGB(200, 255, 255, 255),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 77, 75, 75).withOpacity(0.5),
            spreadRadius: 0.5,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      widget.Date,
                      style:
                          const TextStyle(fontFamily: 'georgia', fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: Color.fromARGB(255, 109, 110, 0),
                  ),
                  const SizedBox(width: 5),
                  Text("($_fileSize | $_dimensions)",
                      style: const TextStyle(
                          fontFamily: 'georgia',
                          fontSize: 14,
                          fontWeight: FontWeight.normal)),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Image.asset(
                    'assets/images/label.png',
                    width: 24,
                    height: 24,
                    color: const Color.fromARGB(255, 45, 138, 48),
                  ),
                  const SizedBox(width: 5),
                  Text(widget.Orginal,
                      style: const TextStyle(
                          fontFamily: 'georgia',
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                width: 220,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                margin: const EdgeInsets.only(top: 30),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.orange,
                      Color.fromARGB(100, 241, 205, 151),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 77, 75, 75)
                          .withOpacity(0.1),
                      spreadRadius: 0.5,
                      blurRadius: 5,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/classification.png',
                      width: 24,
                      height: 24,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      _abbreviateResult(widget.Result),
                      style: const TextStyle(
                        fontFamily: 'georgia',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    border: const GradientBoxBorder(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 221, 108, 108),
                          Color.fromRGBO(126, 119, 20, 0.004)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      width: 1,
                    ),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: widget.Pic.isNotEmpty
                          ? NetworkImage(widget.Pic)
                          : const NetworkImage(
                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSwWl4ngiL0w69Hjqe9Pm5jYcmOCEBG0TQ9z__FTcE3ed3Cx1kWO32Ue-UExwj0BXYzn9Y&usqp=CAU")
                              as ImageProvider,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 100, // same as image width
                  child: Text(
                    widget.Name,
                    style: const TextStyle(fontFamily: 'georgia', fontSize: 12),
                    textAlign: TextAlign.center,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ]),
        ],
      ),
    );
  }

  String _abbreviateResult(String result) {
    final abbreviations = {
      "Diabetic Retinopathy": "DR",
      "Glaucoma": "Glaucoma",
      "Cataract": "Cataract",
      "Normal": "Normal", // No change needed
    };

    for (var entry in abbreviations.entries) {
      if (result.contains(entry.key)) {
        return result.replaceFirst(entry.key, entry.value);
      }
    }
    return result; // fallback
  }
}
