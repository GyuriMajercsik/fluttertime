import 'package:equatable/equatable.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ImageAnalyzerEvent extends Equatable {
  ImageAnalyzerEvent([List arguments]) : super(arguments);
}

@immutable
class Clear extends ImageAnalyzerEvent {
  @override
  String toString() => 'Clear';
}

@immutable
class TextRecognized extends ImageAnalyzerEvent {
  final VisionText visionText;

  TextRecognized(this.visionText) : super([visionText.text, visionText.blocks]);

  String toString() => 'TextRecognized';
}

@immutable
class LabelsRecognized extends ImageAnalyzerEvent {
  final List<ImageLabel> labels;

  LabelsRecognized(this.labels) : super([labels]);

  String toString() => 'LabelsRecognized';
}

@immutable
class FacesRecognized extends ImageAnalyzerEvent {
  final List<Face> faces;

  FacesRecognized(this.faces) : super([faces]);

  String toString() => 'FacesRecognized';
}

@immutable
class CloudLabelsRecognized extends ImageAnalyzerEvent {
  final List<ImageLabel> cloudLabels;

  CloudLabelsRecognized(this.cloudLabels) : super([cloudLabels]);

  String toString() => 'CloudLabelsRecognized';
}

@immutable
class BarcodesRecognized extends ImageAnalyzerEvent {
  final List<Barcode> barcodes;

  BarcodesRecognized(this.barcodes) : super([barcodes]);

  String toString() => 'BarcodesRecognized';
}
