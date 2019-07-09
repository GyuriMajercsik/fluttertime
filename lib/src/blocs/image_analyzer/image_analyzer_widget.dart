import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_time/src/blocs/image_analyzer/image_analyzer_bloc.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_time/src/blocs/image_analyzer/image_analyzer_type.dart';

import 'bloc.dart';

class ImageAnalyzerWidget extends StatefulWidget {
  final ImageAnalyzerBloc imageAnalyzerBloc;
  final File imageFile;
  final ImageAnalyzerType imageAnalyzerType;

  ImageAnalyzerWidget(
      {@required this.imageAnalyzerBloc,
      @required this.imageFile,
      @required this.imageAnalyzerType});

  @override
  _ImageAnalyzerWidgetState createState() => _ImageAnalyzerWidgetState();
}

class _ImageAnalyzerWidgetState extends State<ImageAnalyzerWidget> {
  FirebaseVisionImage visionImage;

  BarcodeDetector barcodeDetector;
  ImageLabeler cloudLabeler;
  FaceDetector faceDetector;
  ImageLabeler labeler;
  TextRecognizer textRecognizer;

  ImageAnalyzerState _imageAnalyzerState;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    visionImage = FirebaseVisionImage.fromFile(widget.imageFile);
    barcodeDetector = FirebaseVision.instance.barcodeDetector();
    cloudLabeler = FirebaseVision.instance.cloudImageLabeler();
    faceDetector = FirebaseVision.instance.faceDetector(FaceDetectorOptions());
    labeler = FirebaseVision.instance
        .imageLabeler(ImageLabelerOptions(confidenceThreshold: 0.75));
    textRecognizer = FirebaseVision.instance.textRecognizer();
  }

  @override
  void dispose() {
    super.dispose();

    barcodeDetector.close();
    cloudLabeler.close();
    faceDetector.close();
    labeler.close();
    textRecognizer.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: widget.imageAnalyzerBloc,
      builder: (BuildContext context, ImageAnalyzerState state) {
        this._imageAnalyzerState = state;
        return SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Image.file(widget.imageFile),
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: _imageAnalyzerState is InitialState
                    ? _loading
                        ? CircularProgressIndicator()
                        : _buildStartAnalyzingButton()
                    : _buildAnalyzeResult(),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyzeResult() {
    if (_imageAnalyzerState is Texts) {
      return TextsWidget(
        texts: _imageAnalyzerState,
      );
    }
    if (_imageAnalyzerState is Labels) {
      return LabelsWidget(
        labels: _imageAnalyzerState,
      );
    }
    if (_imageAnalyzerState is Faces) {
      return FacesWidget(
        faces: _imageAnalyzerState,
      );
    }
    if (_imageAnalyzerState is Barcodes) {
      return BarcodesWidget(
        barcodes: _imageAnalyzerState,
      );
    }

    assert(false, "$_imageAnalyzerState didn't handled.");

    return Container();
  }

  Widget _buildStartAnalyzingButton() {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      onPressed: _startAnalyzing,
      child: Text('Start analyzing'),
    );
  }

  Future<void> _startAnalyzing() async {
    setState(() {
      _loading = true;
    });

    switch (widget.imageAnalyzerType) {
      case ImageAnalyzerType.texts:
        await _startTextRecognizer();
        break;
      case ImageAnalyzerType.faces:
        await _startFaceDetecting();
        break;
      case ImageAnalyzerType.labels:
        await _startLabeling();
        break;
      case ImageAnalyzerType.barcodes:
        await _startBarcodeAnalyze();
        break;
      case ImageAnalyzerType.cloudLabels:
        await _startCloudLabeling();
        break;
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _startTextRecognizer() async {
    VisionText texts = await textRecognizer.processImage(visionImage);
    widget.imageAnalyzerBloc.dispatch(TextRecognized(texts));
  }

  Future<void> _startLabeling() async {
    List<ImageLabel> labels = await labeler.processImage(visionImage);
    widget.imageAnalyzerBloc.dispatch(LabelsRecognized(labels));
  }

  Future<void> _startFaceDetecting() async {
    List<Face> faces = await faceDetector.processImage(visionImage);
    widget.imageAnalyzerBloc.dispatch(FacesRecognized(faces));
  }

  Future<void> _startBarcodeAnalyze() async {
    List<Barcode> barcodes = await barcodeDetector.detectInImage(visionImage);
    widget.imageAnalyzerBloc.dispatch(BarcodesRecognized(barcodes));
  }

  Future<void> _startCloudLabeling() async {
    List<ImageLabel> cloudLabels = await cloudLabeler.processImage(visionImage);
    widget.imageAnalyzerBloc.dispatch(CloudLabelsRecognized(cloudLabels));
  }
}

class TextsWidget extends StatelessWidget {
  final Texts texts;

  TextsWidget({Key key, this.texts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (texts.visionText.blocks.isEmpty) {
      return Text('No text was found');
    }

    var map = texts.visionText.blocks.map((textBlock) {
      return Text(textBlock.text);
    }).toList();
    return Column(
      children: map,
    );
  }
}

class LabelsWidget extends StatelessWidget {
  final Labels labels;

  LabelsWidget({Key key, this.labels}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (labels.labels.isEmpty) {
      return Text('No label was found');
    }

    var map = labels.labels.map((textBlock) {
      return Text(textBlock.text);
    }).toList();
    return Column(
      children: map,
    );
  }
}

class FacesWidget extends StatelessWidget {
  final Faces faces;

  FacesWidget({Key key, this.faces}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (faces.faces.isEmpty) {
      return Text('No face was found');
    }

    var map = faces.faces.map((face) {
      return Text('Found: ${face.boundingBox.toString()}');
    }).toList();
    return Column(
      children: map,
    );
  }
}

class BarcodesWidget extends StatelessWidget {
  final Barcodes barcodes;

  BarcodesWidget({Key key, this.barcodes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (barcodes.barcodes.isEmpty) {
      return Text('No barcode was found');
    }

    var map = barcodes.barcodes.map((barcode) {
      return Text(barcode.displayValue);
    }).toList();
    return Column(
      children: map,
    );
  }
}
