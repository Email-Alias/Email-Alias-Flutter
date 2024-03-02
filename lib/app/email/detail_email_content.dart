import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

@immutable
final class DetailEmailContent extends StatelessWidget {
  const DetailEmailContent({required this.comment, required this.address, super.key});

  final String comment;
  final String address;

  @override
  Widget build(final BuildContext context) =>
    Scaffold(
      appBar: AppBar(
        title: Text(comment),
      ),
      body: Center(
        child: QrImageView(
          data: 'mailto:$address',
        ),
      ),
    );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('comment', comment))
      ..add(StringProperty('address', address));
  }
}
