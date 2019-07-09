import 'package:bloc/bloc.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_time/src/blocs/image_analyzer/image_analyzer_event.dart';
import 'package:flutter_time/src/blocs/image_analyzer/image_analyzer_state.dart';

class ImageAnalyzerBloc extends Bloc<ImageAnalyzerEvent, ImageAnalyzerState> {
  @override
  ImageAnalyzerState get initialState => InitialState();

  @override
  Stream<ImageAnalyzerState> mapEventToState(ImageAnalyzerEvent event) async* {
    if (event is TextRecognized) {
      yield* _mapTextRecognizedToState(event.visionText);
    } else if (event is LabelsRecognized) {
      yield* _mapLabelsRecognizedToState(event.labels);
    } else if (event is FacesRecognized) {
      yield* _mapFacesRecognizedToState(event.faces);
    } else if (event is CloudLabelsRecognized) {
      yield* _mapCloudLabelsRecognizedToState(event.cloudLabels);
    } else if (event is BarcodesRecognized) {
      yield* _mapBarcodesRecognizedToState(event.barcodes);
    } else if (event is Clear) {
      yield* _mapClearToState();
    }
  }

  Stream<ImageAnalyzerState> _mapTextRecognizedToState(
      VisionText visionText) async* {
    yield Texts(visionText);
  }

  Stream<ImageAnalyzerState> _mapLabelsRecognizedToState(
      List<ImageLabel> labels) async* {
    yield Labels(labels);
  }

  Stream<ImageAnalyzerState> _mapFacesRecognizedToState(
      List<Face> faces) async* {
    yield Faces(faces);
  }

  Stream<ImageAnalyzerState> _mapCloudLabelsRecognizedToState(
      List<ImageLabel> cloudLabels) async* {
    yield CloudLabels(cloudLabels);
  }

  Stream<ImageAnalyzerState> _mapBarcodesRecognizedToState(
      List<Barcode> barcodes) async* {
    yield Barcodes(barcodes);
  }

  Stream<ImageAnalyzerState> _mapClearToState() async* {
    yield InitialState();
  }
}
