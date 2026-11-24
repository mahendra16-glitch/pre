import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/model/local/bill_layout_config.dart';

class LocalPrintConfigService {
  static const _key = 'bill_layout_config_v1';

  static LocalPrintConfigService? _instance;
  static LocalPrintConfigService get instance =>
      _instance ??= LocalPrintConfigService._();
  LocalPrintConfigService._();

  BillLayoutConfig? _cache;

  Future<BillLayoutConfig> load() async {
    if (_cache != null) return _cache!;
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    _cache = json != null
        ? BillLayoutConfig.fromJsonString(json)
        : BillLayoutConfig.defaults();
    return _cache!;
  }

  Future<void> save(BillLayoutConfig config) async {
    _cache = config;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, config.toJsonString());
  }

  void invalidateCache() => _cache = null;

  // Returns a PosStyles built from a BillSectionConfig.
  // Falls back to the server-config string when the section has no local override.
  static PosStyles stylesFromSection(
    BillSectionConfig section, {
    bool isPaperSize80 = true,
    bool isUnderline = false,
  }) {
    final align = _posAlign(section.align);
    final sz = _posSize(section.size);
    return PosStyles(
      align: align,
      underline: isUnderline,
      fontType: isPaperSize80 ? PosFontType.fontA : PosFontType.fontB,
      bold: section.bold,
      height: sz,
      width: sz,
    );
  }

  // For label-value rows: label always left, value always right; size+bold from section.
  static PosStyles labelStyleFromSection(BillSectionConfig section, {bool isPaperSize80 = true}) {
    final sz = _posSize(section.size);
    return PosStyles(align: PosAlign.left, fontType: isPaperSize80 ? PosFontType.fontA : PosFontType.fontB, bold: section.bold, height: sz, width: sz);
  }

  static PosStyles valueStyleFromSection(BillSectionConfig section, {bool isPaperSize80 = true}) {
    final sz = _posSize(section.size);
    return PosStyles(align: PosAlign.right, fontType: isPaperSize80 ? PosFontType.fontA : PosFontType.fontB, bold: section.bold, height: sz, width: sz);
  }

  static PosAlign _posAlign(String a) {
    switch (a) {
      case 'L':
        return PosAlign.left;
      case 'R':
        return PosAlign.right;
      default:
        return PosAlign.center;
    }
  }

  static PosTextSize _posSize(int s) {
    switch (s) {
      case 2:
        return PosTextSize.size2;
      case 3:
        return PosTextSize.size3;
      case 4:
        return PosTextSize.size4;
      default:
        return PosTextSize.size1;
    }
  }
}
