import 'dart:collection';
import 'dart:convert';

import 'package:mlog/src/common/utils.dart';
import 'package:mlog/src/message_builder/message_builder.dart';
import 'package:mlog/src/mlog_base.dart';

class JsonMessageBuilder implements MessageBuilder {
  	@override
  	String messageBuilder(LgLvl level, DateTime time, LoggingFields data, [
		int extraTraceLineOffset = 0,
	]) {
		// ignore: prefer_collection_literals
		final map = LinkedHashMap<String, Object>();

		map["level"] = level.name;
		map["time"] = DateTime.now().toString();
		final type = data.type();
		if (type != null) {
			map["type"] = type;
		}

		if (LogOptions.instance.trace) {
			try {
				final (function, file, line) = parseTrace(StackTrace.current, extraTraceLineOffset: extraTraceLineOffset);
				map["trace"] = "$function $file:$line";
			} catch (e) {
				map["trace"] = "parse trace error $e";
			}
		}

		final msg = data.message();
		if (msg != null) {	
			map["message"] = msg;
		}

		for (final (key, value) in data.extra()) {
			switch (value.runtimeType) {
				case num:
					map[key] = value;
				default:
					map[key] = "$value";
			}
			if (value is num) {
		  		map[key] = value;
			}
		}
		final e = data.error();
		if (e != null) {
			map["error"] = e;
		}
		return json.encode(map);
	}
}
