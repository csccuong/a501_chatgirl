import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert' as convert;
import 'dart:typed_data';
import 'dart:math';

class Aes256 {
  static String encrypt(String text, String passphrase) {
    final random = Random.secure();
    List<int> pass = passphrase.split('').map((ch) => ch.codeUnitAt(0)).toList();
    List<int> salt = List<int>.generate(8, (i) => random.nextInt(255));
    List<int> salted = [];
    List<int> dx = [];

    while (salted.length < 48) {
      List<int> data = [...dx, ...pass, ...salt];
      dx = md5.convert(data).bytes;
      salted = [...salted, ...dx];
    }

    final key = Key(Uint8List.fromList(salted.sublist(0, 32)));
    final iv = IV(Uint8List.fromList(salted.sublist(32, 48)));

    final encryptor = Encrypter(AES(key, mode: AESMode.cbc));
    List<int> encrypted = encryptor.encrypt(text, iv: iv).bytes.toList();

    salted = 'Salted__'.split('').map((ch) => ch.codeUnitAt(0)).toList();
    List<int> bytes = [...salted, ...salt, ...encrypted];
    return convert.base64.encode(bytes).toString();
  }

  // static String decrypt(String encoded, String passphrase) {
  //   String output = '';
  //   List<int> enc = convert.base64.decode(encoded.trim()).toList();
  //   final saltedStr = String.fromCharCodes(enc.sublist(0, 8).toList());
  //   if (saltedStr != 'Salted__') return output;
  //
  //   List<int> pass = passphrase.split('').map((ch) => ch.codeUnitAt(0)).toList();
  //   List<int> salt = enc.sublist(8, 16).toList();
  //   List<int> text = enc.sublist(16).toList();
  //   List<int> salted = [];
  //   List<int> dx = [];
  //
  //   while (salted.length < 48) {
  //     List<int> data = [...dx, ...pass, ...salt];
  //     dx = md5.convert(data).bytes;
  //     salted = [...salted, ...dx];
  //   }
  //
  //   final key = Key(Uint8List.fromList(salted.sublist(0, 32)));
  //   final iv = IV(Uint8List.fromList(salted.sublist(32, 48)));
  //   final encryptor = Encrypter(AES(key, mode: AESMode.cbc));
  //   final encrypted = Encrypted(Uint8List.fromList(text));
  //   return encryptor.decrypt(encrypted, iv: iv);
  // }
  static String? decrypt(String encoded, String passphrase) {
    final enc = base64.decode(encoded);
    final saltedPrefix = utf8.decode(enc.sublist(0, 8));

    if (saltedPrefix != 'Salted__') return null;

    final salt = enc.sublist(8, 16);
    final text = enc.sublist(16);
    final salted = _generateSaltedKeyAndIv(passphrase, salt);

    final key = Key(Uint8List.fromList(salted.sublist(0, 32)));
    final iv = IV(Uint8List.fromList(salted.sublist(32, 48)));
    final encryptor = Encrypter(AES(key, mode: AESMode.cbc));

    return encryptor.decrypt(Encrypted(Uint8List.fromList(text)), iv: iv);
  }
  static List<int> _generateSaltedKeyAndIv(String passphrase, List<int> salt) {
    final pass = utf8.encode(passphrase);
    var dx = <int>[];
    var salted = <int>[];

    while (salted.length < 48) {
      final data = dx + pass + salt;
      dx = md5.convert(data).bytes;
      salted.addAll(dx);
    }

    return salted;
  }
}
