import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import './mutations/auth_mutations.dart' as mutations;
import './queries/auth_queries.dart' as queries;
import 'package:cerf_mobile/model/User.dart';

abstract class BaseAuth {
  Future<String> loginWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<String> currentUser();
  Future<void> logout();
}

class Auth implements BaseAuth {
  Auth({
    String cookie,
  }) {
    this._client = http.Client();
  }

  String cookie;
  String storageCookieKey = "graphql_cookie";
  http.Client _client;
  String _url = "https://viss-mobile.herokuapp.com/graphql";

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<String> _getMobileCookie() async {
    final SharedPreferences prefs = await _prefs;
    String _cookieString = prefs.getString(storageCookieKey);
    cookie = _cookieString;
    return _cookieString ?? '';
  }

  Future<bool> _setMobileCookie(String token) async {
    final SharedPreferences prefs = await _prefs;

    return prefs.setString(storageCookieKey, token);
  }

  Future<String> loginWithEmailAndPassword(
      String email, String password) async {
    Map<String, dynamic> variables = {
      'email': email,
      'password': password,
    };
    User user;
    try {
      final http.Response response =
          await _runQuery(mutations.login, variables: variables);
      final Map<String, dynamic> parsedRes = _parseGQLResponse(response);

      user = User.fromJson(parsedRes['login']);
    } catch (e) {
      print(e);
    }

    return user?.id;
  }

  Future<String> createUserWithEmailAndPassword(
      String email, String password) async {
    return "user?.uid";
  }

  Future<String> currentUser() async {
    User user;
    await _getMobileCookie();
    try {
      final http.Response response = await _runQuery(queries.currentUser);
      final Map<String, dynamic> parsedRes = _parseGQLResponse(response);

      user = User.fromJson(parsedRes['me']);
    } catch (e) {
      return null;
    }
    return user?.id;
  }

  Future<void> logout() async {
    try {
      final http.Response response = await _runQuery(mutations.logout);
      if (response.statusCode != 200) {
        // TODO: Change exception to custom and handle response
        throw Exception("error in logging out");
      }
      final Map<String, dynamic> parsedRes = _parseGQLResponse(response);
      if (parsedRes['logout'] == true) {
        // Successfully logged out from graphQL
      }
      _setMobileCookie(null);
      // clear cookie from header even if not successfully logged out of gQL
      cookie = null;
      return;
    } catch (e) {
      print(e);
    }
  }

  Map<String, dynamic> _parseGQLResponse(http.Response response) {
    final int statusCode = response.statusCode;
    final String reasonPhrase = response.reasonPhrase;

    try {
      String cookieString = response.headers['set-cookie'];
      if (cookieString != null) {
        cookie = cookieString.split(';')[0];
        _setMobileCookie(cookie);
      }
    } catch (e) {
      print("error in setting cookie $e");
    }

    if (statusCode < 200 || statusCode >= 400) {
      throw http.ClientException(
        'Network Error: $statusCode $reasonPhrase',
      );
    }

    final Map<String, dynamic> jsonResponse = json.decode(response.body);

    if (jsonResponse['errors'] != null && jsonResponse['errors'].length > 0) {
      throw Exception(
        'Error returned by the GQL server in the query: \n${jsonResponse['errors'][0]}',
      );
    }

    return jsonResponse['data'];
  }

  Future<http.Response> _runQuery(String query,
      {Map<String, dynamic> variables}) {
    final String body = json.encode({
      'query': query,
      'variables': variables,
    });

    // TODO: change this to not set token here
    _getMobileCookie().then((res) {
      cookie = res;
    });

    Map<String, String> headers = {
      'Cookie': '$cookie',
      'Content-Type': 'application/json',
    };
    // print("running ${query.substring(0,15)}");
    // print("cookie: $cookie");
    return _client.post(
      _url,
      headers: headers,
      body: body,
    );
  }
}