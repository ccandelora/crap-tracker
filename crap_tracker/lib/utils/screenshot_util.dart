import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class ScreenshotUtil {
  static final ScreenshotController _screenshotController = ScreenshotController();
  
  // Add this widget as the parent of the screen you want to capture
  static Widget wrapForScreenshot(Widget child, {Key? key}) {
    return Screenshot(
      controller: _screenshotController,
      child: child,
    );
  }
  
  // Call this method to take a screenshot
  static Future<String> takeScreenshot(String name) async {
    final Uint8List? imageBytes = await _screenshotController.capture();
    if (imageBytes == null) {
      throw Exception('Failed to capture screenshot');
    }
    
    final Directory tempDir = await getTemporaryDirectory();
    final String filePath = '${tempDir.path}/$name.png';
    
    final File file = File(filePath);
    await file.writeAsBytes(imageBytes);
    
    print('Screenshot saved to: $filePath');
    return filePath;
  }
  
  // Various preset sizes for App Store screenshots
  static Future<String> takeIPhone65Screenshot(String name) async {
    return await _takeScreenshotWithSize(name, const Size(1284, 2778));
  }
  
  static Future<String> takeIPad129Screenshot(String name) async {
    return await _takeScreenshotWithSize(name, const Size(2048, 2732));
  }
  
  static Future<String> _takeScreenshotWithSize(String name, Size size) async {
    final Uint8List? imageBytes = await _screenshotController.captureFromWidget(
      MediaQuery(
        data: MediaQueryData(size: size),
        child: _screenshotController.widget ?? Container(),
      ),
      pixelRatio: 3.0,
      delay: const Duration(milliseconds: 10),
    );
    
    if (imageBytes == null) {
      throw Exception('Failed to capture screenshot with size $size');
    }
    
    final Directory tempDir = await getTemporaryDirectory();
    final String filePath = '${tempDir.path}/$name.png';
    
    final File file = File(filePath);
    await file.writeAsBytes(imageBytes);
    
    print('Sized screenshot saved to: $filePath');
    return filePath;
  }
}
