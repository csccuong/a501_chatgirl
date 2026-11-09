import 'lang_de.dart';
import 'lang_it.dart';
import 'lang_ja.dart';
import 'lang_ko.dart';

import 'lang_hi.dart';
import 'lang_bn.dart';
import 'lang_id.dart';
import 'lang_en.dart';
import 'lang_fil.dart';
import 'lang_es.dart';
import 'lang_tr.dart';
import 'lang_pt.dart';
import 'lang_ar.dart';
import 'lang_ru.dart';
import 'lang_fr.dart';
import 'lang_vi.dart';

abstract class AppTranslation {
  static Map<String, Map<String, String>> translationsKeys = {
    "de": deDE,
    "it": itIT,
    "ja": jaJP,
    "ko": koKR,
    "hi": hiIN,
    "bn": bnBD,
    "id": idID,
    "en": enUS,
    "fil": filPH,
    "es": esES,
    "tr": trTR,
    "pt": ptBR,
    "ar": arSA,
    "ru": ruRU,
    "fr": frFR,
    "vi": viVN,
  };
}
