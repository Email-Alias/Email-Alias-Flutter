import 'package:browser_cli/browser_cli.dart' as browser_cli;
import 'dart:convert';
import 'dart:io';

int _littleEndianUint32(List<int> bytes) {
  if (bytes.length != 4) throw ArgumentError('Expected 4 bytes');
  return bytes[0] |
         (bytes[1] << 8) |
         (bytes[2] << 16) |
         (bytes[3] << 24);
}

List<int> _bytesFromLittleEndian(int value) {
  return [
    value & 0xFF,
    (value >> 8) & 0xFF,
    (value >> 16) & 0xFF,
    (value >> 24) & 0xFF,
  ];
}

Future<Map<String, String>?> _readMessageData() async {
  final stdinBytes = await stdin.first;

  final lengthBytes = stdinBytes.sublist(0, 4);
  if (lengthBytes.length != 4) return null;

  final length = _littleEndianUint32(lengthBytes);

  final dataBytes = stdinBytes.sublist(4, 4 + length);
  if (dataBytes.length != length) return null;

  final jsonString = utf8.decode(dataBytes);
  final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
  return jsonMap.map((key, value) => MapEntry(key, value.toString()));
}

Future<void> _sendMessageData(Map<String, dynamic> data) async {
  final jsonData = utf8.encode(jsonEncode(data));
  final lengthBytes = _bytesFromLittleEndian(jsonData.length);

  stdout.add(lengthBytes);
  stdout.add(jsonData);
  await stdout.flush();
}

Future<void> main() async {
  final messageData = await _readMessageData();
  switch (messageData?["type"]) {
    case "getAliases":
      final aliases = await browser_cli.getEmails();
      await _sendMessageData(aliases);
  }
}
