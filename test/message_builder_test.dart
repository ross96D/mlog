import 'dart:convert';

import 'package:mlog/mlog.dart';
import 'package:test/test.dart';

void main() {
	group("json message builder", () {
		test('build', () {
			final msg = JsonMessageBuilder().messageBuilder(LgLvl.info, null, null);
			assert(msg != null);
			final data = json.decode(msg!);
			assert(data["level"] == LgLvl.info.name);
			assert(data["message"] == null);

			try {
				throw Exception("prueba");
			} catch (e, st) {
				final expmsg = JsonMessageBuilder().messageBuilder(LgLvl.error, null, null, e: e, st: st);
				assert(expmsg != null);
				final data = json.decode(expmsg!);
				assert(data["level"] == LgLvl.error.name);
				assert(data["message"] == null);
				assert(data["error"] == "$e");
			}
		});

		test("print", () {
			final msg = JsonMessageBuilder().messageBuilder(LgLvl.info, null, {"key1": "value1", "key2": 2});
			print(msg);
		});
	});
}
