import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imgly_sdk/imgly_sdk.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:photo_editor_sdk/photo_editor_sdk.dart';

/// The example application of the photo_editor_sdk plugin.
class PhotoEditor extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<PhotoEditor> {
  Configuration createConfiguration() {
    final flutterSticker = Sticker(
        "example_sticker_logos_flutter", "Flutter", "assets/Flutter-logo.png");
    final imglySticker = Sticker(
        "example_sticker_logos_imgly", "img.ly", "assets/IgorSticker.png");

    /// A completely custom category.
    final logos = StickerCategory(
        "example_sticker_category_logos", "Logos", "assets/Flutter-logo.png",
        items: [flutterSticker, imglySticker]);

    /// A predefined category.
    final emoticons =
        StickerCategory.existing("imgly_sticker_category_emoticons");

    /// A customized predefined category.
    final shapes =
        StickerCategory.existing("imgly_sticker_category_shapes", items: [
      Sticker.existing("imgly_sticker_shapes_badge_01"),
      Sticker.existing("imgly_sticker_shapes_arrow_02")
    ]);
    final categories = <StickerCategory>[logos, emoticons, shapes];
    final configuration = Configuration(
        sticker:
            StickerOptions(personalStickers: true, categories: categories));
    return configuration;
  }

  @override
  void initState() {
    super.initState();
  }

  void presentEditor(image) async {
    final result = await PESDK.openEditor(
        image: image.path, configuration: createConfiguration());
    print(result?.toJson());
  }

  File? _image;

  Future getImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imageFile = await saveFile(image.path);

      setState(() {
        this._image = imageFile;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<File> saveFile(String imagePath) async {
    final directory = await getApplicationSupportDirectory();
    final name = basename(imagePath);
    final image = File('${directory.path}/$name');

    return File(imagePath).copy(image.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактор фото'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40)),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await getImage(ImageSource.gallery);
                  if (_image != null)
                    presentEditor(_image);
                  else
                    return;
                },
                child: Text('Выбрать из галереи'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await getImage(ImageSource.camera);
                  presentEditor(_image);
                },
                child: Text('Сделать новое фото'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
