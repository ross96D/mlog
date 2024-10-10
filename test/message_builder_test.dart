import 'dart:convert';

import 'package:mlog/mlog.dart';
import 'package:test/test.dart' as testing;

void main() {
	testing.group("json message builder", () {
		testing.test('build', () {
			final builder = JsonMessageBuilder();
			final msg = messageBuilder(LogBuilder(LgLvl.info).msg("test"), builder);
			final data = json.decode(msg);
			testing.expect(data["level"], testing.equals(LgLvl.info.name));
			testing.expect(data["message"], testing.equals("test"));

			try {
				throw Exception("prueba");
			} catch (e, st) {
				final expmsg = messageBuilder(
					LogBuilder(LgLvl.error).
						msg("error test").
						error(e, st), 
					builder,
				);
				final data = json.decode(expmsg);
				testing.expect(data["level"], testing.equals(LgLvl.error.name));
				testing.expect(data["message"], testing.equals("error test"));
				testing.expect(data["error"], testing.equals("Error: $e\nStacktrace:\n$st"));
			}
		});

		testing.test("print", () {
			final logBuilder = LogBuilder(LgLvl.info).add({"key1": "value1", "key2": 2});
			final msgBuilder = JsonMessageBuilder();
			print(messageBuilder(logBuilder, msgBuilder));
		});
	});
}
