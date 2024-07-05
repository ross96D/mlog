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
    map["type"] = "$type";
    
    map["data"] = <String, dynamic>{};
    final data = map["data"] as Map<String, dynamic>;

    if (LogOptions.instance.trace) {
      try {
        final (function, file, line) = parseTrace(StackTrace.current, extraTraceLineOffset: extraTraceLineOffset);
        data["trace"] = {
          "function": function,
          "file": file,
          "line": line,
        };
      } catch (e) {
        data["trace"] = "parse trace error $e";
      }
    }

    if (msg != null) {
      if (msg is JsonMessage) {
        map["message"] = msg.toString();
        data.addAll(msg.toMap());
      } else if (msg is Map<String, dynamic>) {
        map["message"] = _logfmt(msg);
        data.addAll(msg);
      } else if (msg is String) {
        map["message"] = msg;
      }
      else {
        map["message"] = "$msg";
      }
    }

    if (e != null) {
      data["error"] = "$e";
    }

    if (st != null) {
      data["stacktrace"] = "$st";
    }

    return json.encode(map);
  }
}

String _logfmt(Map<String, dynamic> data) {
  final builder = StringBuffer();

  for (var entry in data.entries) {
    builder.write("${entry.key}=${entry.value.toString()}");
    builder.write(" ");
  }

  final result = builder.toString();
  return result.substring(0, result.length - 1);
}

abstract class JsonMessage {

  factory JsonMessage({required String message, required Map<String,dynamic> map}) => _ImplJsonMessage(message, map);

  @override
  String toString();

  Map<String, dynamic> toMap();
}

class _ImplJsonMessage implements JsonMessage {
  final String message;
  final Map<String, dynamic> map;
  
  _ImplJsonMessage(this.message, this.map);
  
  @override
  Map<String, dynamic> toMap() {
    return map;
  }

  @override
  String toString() {
    return message;
  }
}
