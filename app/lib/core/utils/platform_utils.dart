import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:saver_gallery/saver_gallery.dart';

enum RecordMode { audio, video }

Future<void> saveRecording(String filePath, RecordMode mode) async {
  if (kIsWeb) {
    return;
  }
  await SaverGallery.saveFile(
    filePath: filePath,
    fileName: filePath.split('/').last,
    androidRelativePath: mode == RecordMode.audio ? 'Music/60Seconds' : 'Movies/60Seconds',
    skipIfExists: false,
  );
}

String recordingFileName(String topic, RecordMode mode) {
  final slug = topic.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  final ext = mode == RecordMode.audio ? 'm4a' : 'mp4';
  return '60s_$slug.$ext';
}

bool get isAndroid => !kIsWeb && Platform.isAndroid;
bool get isIOS => !kIsWeb && Platform.isIOS;
