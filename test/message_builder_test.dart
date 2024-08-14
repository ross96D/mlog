import 'dart:convert';

import 'package:mlog/mlog.dart';
import 'package:test/test.dart';

void main() {
  group("json message builder", () {
    test('build', () {
      final msg = JsonMessageBuilder().messageBuilder(LgLvl.info, null);
      final data = json.decode(msg);
      assert(data["level"] == LgLvl.info.name);
      assert(data["message"] == null);

      try {
        throw Exception("prueba");
      } catch (e, st) {
        final expmsg = JsonMessageBuilder().messageBuilder(LgLvl.error, null, e: e, st: st);
        final data = json.decode(expmsg);
        assert(data["level"] == LgLvl.error.name);
        assert(data["message"] == null);
        assert(data["error"] == "$e");
      }
    });

    test("print", () {
      final msg = JsonMessageBuilder().messageBuilder(LgLvl.info, {"key1": "value1", "key2": 2});
      print(msg);
    });
  });
}
