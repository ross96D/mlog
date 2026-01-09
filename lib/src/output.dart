import 'dart:io';

abstract interface class MLogOutput {
  void output(String message);
}

class PrintOutput implements MLogOutput {
  @override
  void output(String message) => print(message);
}

class FileOutput implements MLogOutput {
  final RandomAccessFile file;

  FileOutput(this.file);

  @override
  void output(String message) {
    file.writeStringSync(message);
  }
}
