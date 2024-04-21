import 'dart:convert' show ascii, utf8;
import 'dart:typed_data';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:nfc_manager/nfc_manager.dart';

const defaultControllerTagName = "default";

abstract class Record {
  NdefRecord toNdef();

  static Record fromNdef(NdefRecord record) {
    if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown &&
        record.type.length == 1 &&
        record.type.first == 0x54) return WellknownTextRecord.fromNdef(record);
    if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown &&
        record.type.length == 1 &&
        record.type.first == 0x55) return WellknownUriRecord.fromNdef(record);
    if (record.typeNameFormat == NdefTypeNameFormat.media)
      return MimeRecord.fromNdef(record);
    if (record.typeNameFormat == NdefTypeNameFormat.absoluteUri)
      return AbsoluteUriRecord.fromNdef(record);
    if (record.typeNameFormat == NdefTypeNameFormat.nfcExternal)
      return ExternalRecord.fromNdef(record);
    return UnsupportedRecord(record);
  }
}

class WellknownTextRecord implements Record {
  WellknownTextRecord(
      {this.identifier, required this.languageCode, required this.text});

  final Uint8List? identifier;

  final String languageCode;

  final String text;

  static WellknownTextRecord fromNdef(NdefRecord record) {
    final languageCodeLength = record.payload.first;
    final languageCodeBytes = record.payload.sublist(1, 1 + languageCodeLength);
    final textBytes = record.payload.sublist(1 + languageCodeLength);
    return WellknownTextRecord(
      identifier: record.identifier,
      languageCode: ascii.decode(languageCodeBytes),
      text: utf8.decode(textBytes),
    );
  }

  @override
  NdefRecord toNdef() {
    return NdefRecord(
      typeNameFormat: NdefTypeNameFormat.nfcWellknown,
      type: Uint8List.fromList([0x54]),
      identifier: identifier ?? Uint8List(0),
      payload: Uint8List.fromList([
        languageCode.length,
        ...ascii.encode(languageCode),
        ...utf8.encode(text),
      ]),
    );
  }
}

class WellknownUriRecord implements Record {
  WellknownUriRecord({this.identifier, required this.uri});

  final Uint8List? identifier;

  final Uri uri;

  static WellknownUriRecord fromNdef(NdefRecord record) {
    final prefix = NdefRecord.URI_PREFIX_LIST[record.payload.first];
    final bodyBytes = record.payload.sublist(1);
    return WellknownUriRecord(
      identifier: record.identifier,
      uri: Uri.parse(prefix + utf8.decode(bodyBytes)),
    );
  }

  @override
  NdefRecord toNdef() {
    var prefixIndex = NdefRecord.URI_PREFIX_LIST
        .indexWhere((e) => uri.toString().startsWith(e), 1);
    if (prefixIndex < 0) prefixIndex = 0;
    final prefix = NdefRecord.URI_PREFIX_LIST[prefixIndex];
    return NdefRecord(
      typeNameFormat: NdefTypeNameFormat.nfcWellknown,
      type: Uint8List.fromList([0x55]),
      identifier: Uint8List(0),
      payload: Uint8List.fromList([
        prefixIndex,
        ...utf8.encode(uri.toString().substring(prefix.length)),
      ]),
    );
  }
}

class MimeRecord implements Record {
  MimeRecord({this.identifier, required this.type, required this.data});

  final Uint8List? identifier;

  final String type;

  final Uint8List data;

  String get dataString => utf8.decode(data);

  static MimeRecord fromNdef(NdefRecord record) {
    return MimeRecord(
      identifier: record.identifier,
      type: ascii.decode(record.type),
      data: record.payload,
    );
  }

  @override
  NdefRecord toNdef() {
    return NdefRecord(
      typeNameFormat: NdefTypeNameFormat.media,
      type: Uint8List.fromList(ascii.encode(type)),
      identifier: identifier ?? Uint8List(0),
      payload: data,
    );
  }
}

class AbsoluteUriRecord implements Record {
  AbsoluteUriRecord(
      {this.identifier, required this.uriType, required this.payload});

  final Uint8List? identifier;

  final Uri uriType;

  final Uint8List payload;

  String get payloadString => utf8.decode(payload);

  static AbsoluteUriRecord fromNdef(NdefRecord record) {
    return AbsoluteUriRecord(
      identifier: record.identifier,
      uriType: Uri.parse(utf8.decode(record.type)),
      payload: record.payload,
    );
  }

  @override
  NdefRecord toNdef() {
    return NdefRecord(
      typeNameFormat: NdefTypeNameFormat.absoluteUri,
      type: Uint8List.fromList(utf8.encode(uriType.toString())),
      identifier: identifier ?? Uint8List(0),
      payload: payload,
    );
  }
}

class ExternalRecord implements Record {
  ExternalRecord(
      {this.identifier,
      required this.domain,
      required this.type,
      required this.data});

  final Uint8List? identifier;

  final String domain;

  final String type;

  final Uint8List data;

  String get domainType => domain + (type.isEmpty ? '' : ':$type');

  String get dataString => utf8.decode(data);

  static ExternalRecord fromNdef(NdefRecord record) {
    final domainType = ascii.decode(record.type);
    final colonIndex = domainType.lastIndexOf(':');
    return ExternalRecord(
      identifier: record.identifier,
      domain: colonIndex < 0 ? domainType : domainType.substring(0, colonIndex),
      type: colonIndex < 0 ? '' : domainType.substring(colonIndex + 1),
      data: record.payload,
    );
  }

  @override
  NdefRecord toNdef() {
    return NdefRecord(
      typeNameFormat: NdefTypeNameFormat.nfcExternal,
      type: Uint8List.fromList(ascii.encode(domainType)),
      identifier: identifier ?? Uint8List(0),
      payload: data,
    );
  }
}

class UnsupportedRecord implements Record {
  UnsupportedRecord(this.record);

  final NdefRecord record;

  static UnsupportedRecord fromNdef(NdefRecord record) {
    return UnsupportedRecord(record);
  }

  @override
  NdefRecord toNdef() => record;
}

extension IntExtension on int {
  String toHexString() {
    return '0x' + toRadixString(16).padLeft(2, '0').toUpperCase();
  }
}

String? getSerialNumber(NfcTag tag) {
  Uint8List identifier =
      Uint8List.fromList(tag.data["mifareultralight"]['identifier']);
  return identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join('');
}

class NfcTagInfo {
  final NfcTag nfcTag;
  final String? serial_number;
  final String? manaufaturer;
  final bool isWritable;
  final Ndef? ndef;
  final List<NdefRecordInfo> records;

  NfcTagInfo(
      {required this.records,
      required this.nfcTag,
      this.manaufaturer,
      this.isWritable = false,
      this.ndef,
      this.serial_number});

  static Future<NfcTagInfo> fromTag(NfcTag tag) async {
    var ndef = Ndef.from(tag);
    var chipId = "";
    // dprint(ndef?.additionalData);
    if (ndef != null) {
      try {
        chipId = ndef.additionalData['identifier']
            .map((e) => e.toRadixString(16).padLeft(2, '0'))
            .join('');
      } catch (er) {}
    }
    // dprint(chipId);
    // dprint(tag.data);
    var records = await tag.ndefRecordInfos();
    return NfcTagInfo(
      records: records,
      nfcTag: tag,
      ndef: ndef,
      isWritable: ndef?.isWritable ?? false,
      serial_number: chipId ?? getSerialNumber(tag),
    );
  }
}

extension NfcTagExt on NfcTag {
  Future<List<NdefRecordInfo>> ndefRecordInfos() async {
    try {
      var cachedMessage = data["ndef"]["cachedMessage"];
      if (cachedMessage != null) {
        NdefMessage? message = await Ndef.from(this)?.read();
        if (message?.records.isNotEmpty ?? false) {
          var messageRecords =
              message!.records.map((e) => NdefRecordInfo.fromNdef(e)).toList();
          return messageRecords;
        }
      }
    } catch (er) {
      dprint(er);
    }
    return [];
  }
}

extension Uint8ListExtension on Uint8List {
  String toHexString({String empty = '-', String separator = ' '}) {
    return isEmpty ? empty : map((e) => e.toHexString()).join(separator);
  }
}

class NdefRecordInfo {
  const NdefRecordInfo(
      {required this.record, required this.title, required this.subtitle});

  final Record record;

  final String title;

  final String subtitle;

  static NdefRecordInfo fromNdef(NdefRecord record) {
    final _record = Record.fromNdef(record);
    if (_record is WellknownTextRecord)
      return NdefRecordInfo(
        record: _record,
        title: 'Wellknown Text',
        subtitle: '(${_record.languageCode}) ${_record.text}',
      );
    if (_record is WellknownUriRecord)
      return NdefRecordInfo(
        record: _record,
        title: 'Wellknown Uri',
        subtitle: '${_record.uri}',
      );
    if (_record is MimeRecord)
      return NdefRecordInfo(
        record: _record,
        title: 'Mime',
        subtitle: '(${_record.type}) ${_record.dataString}',
      );
    if (_record is AbsoluteUriRecord)
      return NdefRecordInfo(
        record: _record,
        title: 'Absolute Uri',
        subtitle: '(${_record.uriType}) ${_record.payloadString}',
      );
    if (_record is ExternalRecord)
      return NdefRecordInfo(
        record: _record,
        title: 'External',
        subtitle: '(${_record.domainType}) ${_record.dataString}',
      );
    if (_record is UnsupportedRecord) {
      // more custom info from NdefRecord.
      if (record.typeNameFormat == NdefTypeNameFormat.empty)
        return NdefRecordInfo(
          record: _record,
          title: _typeNameFormatToString(_record.record.typeNameFormat),
          subtitle: '-',
        );
      return NdefRecordInfo(
        record: _record,
        title: _typeNameFormatToString(_record.record.typeNameFormat),
        subtitle:
            '(${_record.record.type.toHexString()}) ${_record.record.payload.toHexString()}',
      );
    }
    throw UnimplementedError();
  }
}

String _typeNameFormatToString(NdefTypeNameFormat format) {
  switch (format) {
    case NdefTypeNameFormat.empty:
      return 'Empty';
    case NdefTypeNameFormat.nfcWellknown:
      return 'NFC Wellknown';
    case NdefTypeNameFormat.media:
      return 'Media';
    case NdefTypeNameFormat.absoluteUri:
      return 'Absolute Uri';
    case NdefTypeNameFormat.nfcExternal:
      return 'NFC External';
    case NdefTypeNameFormat.unknown:
      return 'Unknown';
    case NdefTypeNameFormat.unchanged:
      return 'Unchanged';
  }
}
