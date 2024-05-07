import 'dart:convert';

import 'package:mlog/mlog.dart';
import 'package:mlog/src/message_builder/json.dart';
import 'package:test/test.dart';

void main() {
  test('json message builder', () {
    final msg = JsonMessageBuilder().messageBuilder(LgLvl.info, null);
    assert(msg != null);
    final data = json.decode(msg!);
    assert(data["level"] == LgLvl.info.name);
    assert(data["message"] == null);

    try {
      throw Exception("prueba");
    } catch(e, st) {
      final expmsg = JsonMessageBuilder().messageBuilder(LgLvl.error, null, e: e, st: st);
      assert(expmsg != null);
      final data = json.decode(expmsg!);
      assert(data["level"] == LgLvl.error.name);
      assert(data["message"] == null);
      assert(data["error"] == "$e");
    }
  });
}
