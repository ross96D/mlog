import 'dart:collection';
import 'dart:convert';

import 'package:mlog/mlog.dart';
import 'package:mlog/src/common/utils.dart';
import 'package:mlog/src/mlog_base.dart';

class JsonMessageBuilder implements MessageBuilder {

	@override
	String buildMessage(LogBuilder builder) => json.encode(buildMap(builder));

	LinkedHashMap<String, dynamic> buildMap(LogBuilder builder) {
		// ignore: prefer_collection_literals
		final map = LinkedHashMap<String, dynamic>();

		map["level"] = builder.level.name;
		map["time"] = (builder.time ?? DateTime.now()).toString();
		final type = builder.type;
		if (type != null) {
			map["type"] = type.toString();
		}
		final msg = builder.message;
		if (msg != null) {
			map["message"] = msg;
		}
		final e = builder.error;
		if (e != null) {
			map["error"] = _errorToGrafanaStandardString(e, builder.stackTrace);
		}

		if (LogOptions.instance.trace) {
			try {
				final (function, file, line) = parseTrace(StackTrace.current,
					extraTraceLineOffset: builder.extraTraceLineOffset,
				);
				map["trace"] = "$function $file:$line";
			} catch (e) {
				map["trace"] = "parse trace error $e";
			}
		}

		if (builder.extra!=null) {
			for (final entry in builder.extra!.entries) {
				if (entry.value is num) {
					map[entry.key] = entry.value;
				} else {
					map[entry.key] = entry.value.toString();
				}
			}
		}

		return map;
	}

	static String _errorToGrafanaStandardString(Object error, [StackTrace? st]) {
		var result = "Error: $error";
		if (error is NestedError) {
			st = error.originalStackTrace;
		}
		if (st!=null) {
			result += "\nStacktrace:\n$st";
		}
		return result;
	}

}
