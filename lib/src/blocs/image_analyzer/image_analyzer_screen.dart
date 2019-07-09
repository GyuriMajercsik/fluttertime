import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_time/main.dart';
import 'package:flutter_time/src/blocs/image_analyzer/image_analyzer_type.dart';
import 'package:flutter_time/src/blocs/image_analyzer/image_analyzer_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'bloc.dart';

class ImageAnalyzerScreen extends StatefulWidget {
  @override
  _ImageAnalyzerScreenState createState() => _ImageAnalyzerScreenState();
}

class _ImageAnalyzerScreenState extends State<ImageAnalyzerScreen> {
  File _image;
  int _selectedIndex;
  ImageAnalyzerBloc _imageAnalyzerBloc;

  Future getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      _imageAnalyzerBloc.dispatch(Clear());

      setState(() {
        _image = image;
        print('selected image: ${_image.path}');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    _imageAnalyzerBloc = getIt<ImageAnalyzerBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image analyzer'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () => getImage(ImageSource.camera),
          ),
          IconButton(
            icon: Icon(Icons.photo_library),
            onPressed: () => getImage(ImageSource.gallery),
          ),
        ],
      ),
      body: Center(
        child: (_image != null)
            ? ImageAnalyzerWidget(
                imageFile: _image,
                imageAnalyzerBloc: _imageAnalyzerBloc,
                imageAnalyzerType: _indexToImageAnalyzerType(),
              )
            : Text('No image selected.'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _imageAnalyzerBloc.dispatch(Clear());
            _selectedIndex = index;
          });
        },
        currentIndex: _selectedIndex,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Colors.blue,
            title: Text('Texts'),
            icon: Icon(Icons.text_fields),
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.green,
            title: Text('Labels'),
            icon: Icon(Icons.label_important),
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.red,
            title: Text('Faces'),
            icon: Icon(Icons.tag_faces),
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.orange,
            title: Text('Barcodes'),
            icon: Icon(FontAwesomeIcons.barcode),
          ),
          // todo enable billing on firebase account to make this work
//            BottomNavigationBarItem(
//              backgroundColor: Colors.purple,
//              title: Text('Cloud Labels'),
//              icon: Icon(Icons.cloud_circle),
//            ),
        ],
      ),
    );
  }

  ImageAnalyzerType _indexToImageAnalyzerType() {
    if (_selectedIndex == 0) {
      return ImageAnalyzerType.texts;
    }
    if (_selectedIndex == 1) {
      return ImageAnalyzerType.labels;
    }
    if (_selectedIndex == 2) {
      return ImageAnalyzerType.faces;
    }
    if (_selectedIndex == 3) {
      return ImageAnalyzerType.barcodes;
    }

    return null;
  }
}
