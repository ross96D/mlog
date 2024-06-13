import 'dart:collection';
import 'dart:convert';

import 'package:mlog/src/common/utils.dart';
import 'package:mlog/src/message_builder/message_builder.dart';
import 'package:mlog/src/mlog_base.dart';

class JsonMessageBuilder implements MessageBuilder {
  @override
  String? messageBuilder(LgLvl level, Object? msg, {
    Object? type,
    Object? e,
    StackTrace? st,
    int extraTraceLineOffset = 0,
  }) {
    // ignore: prefer_collection_literals
    final map = LinkedHashMap<String, dynamic>();
    
    map["level"] = level.name;
    map["time"] = DateTime.now().toString();

    if (LogOptions.instance.trace) {
      try {
        final trace = parseTrace(StackTrace.current, extraTraceLineOffset: extraTraceLineOffset);
        map["trace"] = {
          "function": trace.$1,
          "file": trace.$2,
          "line": trace.$3,
        };
      } catch (_) {
        map["trace"] = "TRACE ERROR";
      }
    }

    if (msg != null) {
      if (msg is Map<String, dynamic>) {
        map.addAll(msg);
      } else if (msg is String) {
        map["message"] = msg;
      } else {
        map["message"] = "$msg";
      }
    }

    if (e != null) {
      map["error"] = "$e";
    }

    if (st != null) {
      map["stacktrace"] = "$st";
    }

    return json.encode(map);
  }
}
