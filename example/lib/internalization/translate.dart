import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'hello': 'Hello World',
          'Add': 'Adding',
          'empty_field': "This field must not be empty"
        },
        'swa_KE': {
          'hello': 'Habari Yako',
          'Add': 'Ongeze',
          'Login': 'Ingia',
          'Submit': 'Wasilisha',
          'Contact name': 'Jina la mhusika',
          'Name': 'Jina',
          'Signing in...': 'Naingia...',
          'Teacher Type': 'Cheo cha Mwalimu',
          'Username': 'Kitambulisho',
          'Your password might be wrong': 'Kuna uwezo umekose neno siri lako',
          'Active': 'Inatumika',
          "TSC": "tsc",
          "empty_field": "Linahitajika",
          "Faield..": "Imefeli..",
          'Modified': 'Ilibadilishwa Lini',
          'Password': 'Neno Siri',
          'School emis Code / Phone number': 'Kodi ya Shule / Nambari ya simu',
        },
        'de_DE': {
          'hello': 'Hallo Welt',
        }
      };
}
