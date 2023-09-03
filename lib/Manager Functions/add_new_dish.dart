import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurant_mangement/utility/toast.dart';
import '../utility/fire_storage.dart';
import 'package:restaurant_mangement/utility/realtime_database.dart'
    as realtimedatabase;

class AddNewDish extends StatefulWidget {
  const AddNewDish({Key? key}) : super(key: key);

  @override
  State<AddNewDish> createState() => _AddNewDishState();
}

class _AddNewDishState extends State<AddNewDish> {
  XFile? _imageFile;

  void _pickImage() async {
    XFile? imageFile = await pickImage();
    setState(() {
      _imageFile = imageFile;
    });
  }

  double? _uploadProgress;
  String? _downloadURL;

  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      return;
    }

    String? downloadURL = await uploadImageToStorage(
      _imageFile!,
      (progress) {
        setState(() {
          _uploadProgress = progress;
        });
      },
    );

    setState(() {
      _uploadProgress = null;
      _downloadURL = downloadURL;
    });

    if (downloadURL != null) {
      showToast('Image uploaded.');
    } else {
      showToast('Image upload failed.');
    }
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  bool _isUploading = false;

  void _addNewDishData() {
    realtimedatabase.addData("Menu/${_nameController.text.trim()}", {
      "Created Time": DateTime.now().toString(),
      "Description": _descController.text.trim(),
      "price": double.parse(_priceController.text),
      "image": _downloadURL,
    });
  }

  void _resetFormFields() {
    _nameController.clear();
    _descController.clear();
    _priceController.clear();
    _imageFile = null;
    _downloadURL = null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !_isUploading;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add New Dish"),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_imageFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      height: 200,
                      File(_imageFile!.path),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _isUploading ? null : _pickImage,
                  child: const Text("Choose Image From Gallery!"),
                ),
                _TextField(
                  controller: _nameController,
                  label: 'Dish Name',
                  numbersOnly: false,
                  enabled: !_isUploading,
                ),
                _TextField(
                  controller: _descController,
                  label: 'Description',
                  numbersOnly: false,
                  enabled: !_isUploading,
                ),
                _TextField(
                  controller: _priceController,
                  label: 'Price',
                  numbersOnly: true,
                  enabled: !_isUploading,
                ),
                ElevatedButton(
                  onPressed: _isUploading
                      ? null
                      : () async {
                          if (_nameController.text.isNotEmpty &&
                              _descController.text.isNotEmpty &&
                              _priceController.text.isNotEmpty) {
                            setState(() {
                              _isUploading = true;
                            });

                            await _uploadImage();
                            if (_downloadURL != null) {
                              _addNewDishData();
                              _resetFormFields();
                            }

                            setState(() {
                              _isUploading = false;
                            });
                          }
                        },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.upload_file),
                            SizedBox(
                              width: 8,
                            ),
                            Text("Upload!", style: TextStyle(fontSize: 15)),
                          ],
                        ),
                      ),
                      if (_uploadProgress != null)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: SizedBox(
                            width: 100,
                            child: LinearProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    required this.numbersOnly,
    required this.enabled,
  });

  final TextEditingController controller;
  final String label;
  final bool numbersOnly;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: TextFormField(
        inputFormatters: numbersOnly
            ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
            : null,
        keyboardType: numbersOnly
            ? const TextInputType.numberWithOptions(decimal: true)
            : null,
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          label: Text(label),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(7)),
          ),
        ),
      ),
    );
  }
}
