import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:mlog/mlog.dart';
import 'package:test/test.dart';

String loggings = "";


void main() {
	final seed = Random.secure().nextInt(1<<32);
	test('First Test', overridePrint(seed, () {
		final random = Random(seed);

		LogOptions.instance.builder = JsonMessageBuilder();
		for (var i = 0; i < 20000; i++) {
			LgLvl level = LgLvl.fine; 
			switch (random.nextInt(5)) {
				case 0:
					level = LgLvl.fine;
				case 1:
					level = LgLvl.finer;
				case 2:
					level = LgLvl.info;
				case 3:
					level = LgLvl.warning;
				case 5:
					level = LgLvl.error;
			}
			final msg = getRandomString(random, 50);
			final type = getRandomString(random, 12);
			final num = random.nextInt(10000);
			blog(LogBuilder(level).
				msg(msg).
				type(type).
				add({"num": num})
			);
			final logged = jsonDecode(loggings);

			expect(logged["level"], equals(level.name));
			expect(logged["message"], equals(msg));
			expect(logged["type"], equals(type));
			expect(logged["num"], equals(num));
		}
	}));
}

void Function() overridePrint(int seed, void Function() testFn) {
	print("seed $seed");
	return () {
	var spec = ZoneSpecification(
			print: (_, __, ___, String msg) {
				// Add to log instead of printing to stdout
				loggings = msg;
			}
		);
		return Zone.current.fork(specification: spec).run<void>(testFn);
	};
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

String getRandomString(Random rnd, int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(rnd.nextInt(_chars.length))));