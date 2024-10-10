import 'package:mlog/mlog.dart';

class LoggingFields {
	final Map<String, String> _data;
	LoggingFields(this._data);
	
	String? error() {
		return _data["error"];
	}
	String? type() {
		return _data["type"];
	}
	String? message() {
		return _data["message"];
	}
	Iterable<(String key, String value)> extra() sync* {
		for (var e in _data.entries) {
			if (e.key != "error" && e.key != "message" && e.key != "type") {
				yield (e.key, e.value);
			}
		}
	}
}

abstract class MessageBuilder {
  	String messageBuilder(LgLvl level, DateTime time, LoggingFields data, [
		int extraTraceLineOffset = 0]);
}