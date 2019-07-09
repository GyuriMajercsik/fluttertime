import 'package:equatable/equatable.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ImageAnalyzerState extends Equatable {
  ImageAnalyzerState({List<dynamic> args}) : super([args]);
}

class InitialState extends ImageAnalyzerState {}

class Texts extends ImageAnalyzerState {
  final VisionText visionText;

  Texts(this.visionText) : super(args: visionText.blocks);
}

class Labels extends ImageAnalyzerState {
  final List<ImageLabel> labels;

  Labels(this.labels) : super(args: labels);
}

class Faces extends ImageAnalyzerState {
  final List<Face> faces;

  Faces(this.faces) : super(args: faces);
}

class CloudLabels extends ImageAnalyzerState {
  final List<ImageLabel> cloudLabels;

  CloudLabels(this.cloudLabels) : super(args: cloudLabels);
}

class Barcodes extends ImageAnalyzerState {
  final List<Barcode> barcodes;

  Barcodes(this.barcodes) : super(args: barcodes);
}
