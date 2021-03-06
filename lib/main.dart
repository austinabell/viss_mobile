import 'package:cerf_mobile/components/settings/VissOptions.dart';
import 'package:cerf_mobile/constants/themes.dart';
import 'package:cerf_mobile/pages/RootPage.dart';
import 'package:cerf_mobile/services/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;

import 'package:cerf_mobile/services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

const _themeKey = "theme_option";
const _notesChangedKey = "notes_changed_option";

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  VissOptions _options;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void _getOptions() async {
    final SharedPreferences prefs = await _prefs;

    bool _theme = prefs.getBool(_themeKey);
    bool _notesChanged = prefs.getBool(_notesChangedKey);

    VissOptions _savedOptions = VissOptions(
      theme: kLightVissTheme,
      platform: defaultTargetPlatform,
      updateNotes: false,
    );
    
    if (_theme != null) {
      _savedOptions = _savedOptions.copyWith(
          theme: _theme ? kDarkVissTheme : kLightVissTheme);
    }
    if (_notesChanged != null) {
      _savedOptions = _savedOptions.copyWith(updateNotes: _notesChanged);
    }

    setState(() {
      _options = _savedOptions;
    });
  }

  void _setOptions(VissOptions options) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setBool(_themeKey, options.theme == kDarkVissTheme);
    prefs.setBool(_notesChangedKey, options.updateNotes);
  }

  @override
  void initState() {
    super.initState();
    _options = VissOptions(
      theme: null,
      platform: defaultTargetPlatform,
      updateNotes: false,
    );
    _getOptions();
  }

  void _handleOptionsChanged(VissOptions newOptions) {
    setState(() {
      _options = newOptions;
    });
    _setOptions(newOptions);
  }

  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      auth: Auth(),
      child: MaterialApp(
        title: 'Viss',
        debugShowCheckedModeBanner: false,
        // Look into why flashing white screen when network instantly fails
        theme: _options.theme != null
            ? _options.theme.data.copyWith(platform: _options.platform)
            : kLightVissTheme.data,
        home: RootPage(
          options: _options,
          onOptionsChanged: _handleOptionsChanged,
        ),
      ),
    );
  }
}
