import 'package:email_alias/app/config/config_controller.dart';
import 'package:email_alias/app/database/database.dart';
import 'package:email_alias/app/database/email.dart';
import 'package:email_alias/app/email/api.dart';
import 'package:email_alias/app/keyboard_listener.dart';
import 'package:email_alias/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:qr_image/qr_image.dart';
import 'package:share_plus/share_plus.dart';

@immutable
final class DetailEmailContent extends StatelessWidget {
  DetailEmailContent({required this.email, required this.emailCreatedCallback, super.key});

  final Email email;
  final void Function(Email?) emailCreatedCallback;
  final _additionalGotoController = TextEditingController();

  @override
  Widget build(final BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final qrCode = _generateQrCode();
    _additionalGotoController.text = email.goto.where((final e) => e != ConfigController.instance.value!.email).join(',');
    return EmailKeyboardListener(
      emailCreatedCallback: emailCreatedCallback,
      child: Scaffold(
        appBar: AppBar(
          title: Text(email.privateComment!),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              children: [
                SizedBox(height: 20),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 400,
                  ),
                  child: Image.memory(qrCode),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    final image = XFile.fromData(
                     qrCode,
                     mimeType: 'image/png',
                    );
                    await Share.shareXFiles([image]);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.share),
                      Text(localizations.shareQrCode),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text(email.address, textAlign: TextAlign.center),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    hintText: localizations.additionalGoto,
                  ),
                  controller: _additionalGotoController,
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    final goto = _additionalGotoController.text.split(',').map((final e) => e.trim()).toSet()
                      ..add(ConfigController.instance.value!.email);
                    email.goto = goto;
                    await emailDatabase.emailDao.updateEmail(email);
                    await updateEmail(id: email.id, goto: goto);
                  },
                  child: Text(localizations.save),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Email>('email', email))
      ..add(ObjectFlagProperty<void Function(Email?)>.has('emailCreatedCallback', emailCreatedCallback));
  }

  Uint8List _generateQrCode() =>
    img.encodePng(
      QRImage(
        'mailto:${email.address}',
        backgroundColor: img.ColorUint8.rgb(255, 255, 255),
        size: 400,
      ).generate(),
    );
}
