import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcService {
  /// Check if the physical device has an NFC chip and is turned on.
  static Future<bool> isAvailable() async {
    try {
      return await NfcManager.instance.isAvailable();
    } catch (_) {
      return false;
    }
  }

  /// Write the Smart Card NDEF URI directly to the physical NFC tag/card.
  static Future<void> writeCardUri({
    required String uri,
    required Function() onSuccess,
    required Function(String error) onError,
  }) async {
    final available = await isAvailable();
    if (!available) {
      onError('ميزة الـ NFC غير مفعلة أو غير متوفرة على هذا الهاتف');
      return;
    }

    try {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          final ndef = Ndef.from(tag);
          if (ndef == null) {
            onError('هذه الشريحة لا تدعم معيار NDEF القياسي');
            NfcManager.instance.stopSession(errorMessage: 'الشريحة غير متوافقة');
            return;
          }

          if (!ndef.isWritable) {
            onError('هذه الشريحة مقفلة للقراءة فقط وغير قابلة للكتابة');
            NfcManager.instance.stopSession(errorMessage: 'الشريحة مقفلة');
            return;
          }

          try {
            // Create standard NDEF URI record (Type 'U')
            // Prefix 0x04 corresponds to 'https://' in NDEF standard
            final trimmed = uri.trim();
            final NdefRecord uriRecord;
            
            if (trimmed.startsWith('https://')) {
              final payload = [0x04, ...utf8.encode(trimmed.substring(8))];
              uriRecord = NdefRecord(
                typeNameFormat: NdefTypeNameFormat.nfcWellknown,
                type: Uint8List.fromList([0x55]), // 'U'
                identifier: Uint8List(0),
                payload: Uint8List.fromList(payload),
              );
            } else {
              final payload = [0x00, ...utf8.encode(trimmed)];
              uriRecord = NdefRecord(
                typeNameFormat: NdefTypeNameFormat.nfcWellknown,
                type: Uint8List.fromList([0x55]),
                identifier: Uint8List(0),
                payload: Uint8List.fromList(payload),
              );
            }

            final message = NdefMessage([uriRecord]);
            await ndef.write(message);

            NfcManager.instance.stopSession();
            onSuccess();
          } catch (e) {
            NfcManager.instance.stopSession(errorMessage: 'فشلت الكتابة');
            onError('حدث خطأ أثناء كتابة البيانات للشريحة: $e');
          }
        },
      );
    } catch (e) {
      onError('تعذر بدء جلسة الـ NFC: $e');
    }
  }

  /// Cancel any active NFC discovery session
  static Future<void> stopSession() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (_) {}
  }
}
