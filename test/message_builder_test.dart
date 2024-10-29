import 'dart:convert';

import 'package:mlog/mlog.dart';
import 'package:test/test.dart' as testing;

void main() {
	testing.group("json message builder", () {
		testing.test('build', () {
			final builder = JsonMessageBuilder();
			final msg = LogBuilder(
				level: LgLvl.info,
				message: "test",
				messageBuilder: builder,
			).buildMessage();
			final data = json.decode(msg);
			testing.expect(data["level"], testing.equals(LgLvl.info.name));
			testing.expect(data["message"], testing.equals("test"));

			try {
				throw Exception("prueba");
			} catch (e, st) {
				final expmsg = LogBuilder(
					level: LgLvl.error,
					message: "error test",
					error: e,
					stackTrace: st,
					messageBuilder: builder,
				).buildMessage();
				final data = json.decode(expmsg);
				testing.expect(data["level"], testing.equals(LgLvl.error.name));
				testing.expect(data["message"], testing.equals("error test"));
				testing.expect(data["error"], testing.equals("Error: $e\nStacktrace:\n$st"));
			}
		});

		testing.test("print", () {
			final logBuilder = LogBuilder(
				level: LgLvl.info,
				extra: {"key1": "value1", "key2": 2},
			);
			final msgBuilder = JsonMessageBuilder();
			final msg = msgBuilder.buildMessage(logBuilder);
			final data = jsonDecode(msg);
			testing.expect(data["key2"], testing.equals(2));
		});
	});
}
