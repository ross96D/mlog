import 'package:mlog/src/colors.dart' as dcli;


void mlog(LgLvl level, Object? msg, {
  Object? type,
  Object? e,
  StackTrace? st,
  int extraTraceLineOffset = 0,
}) {
  final message = mlogGetMessage(level, msg,
    type: type,
    e: e,
    st: st,
    extraTraceLineOffset: extraTraceLineOffset + 1,
  );
  if (message!=null) {
    print(message); // ignore: avoid_print
  }
}

String? mlogGetMessage(LgLvl level, Object? msg, {
  Object? type,
  Object? e,
  StackTrace? st,
  int extraTraceLineOffset = 0,
}) {
  if (level.value>LogOptions.instance.getLvlForType(type).value) {
    return null;
  }
  msg ??= "";
  StringBuffer messageBuilder = StringBuffer('');
  String header = "$level ${DateTime.now()}";
  if (type!=null) {
    header += ' $type';
  }
  messageBuilder.write(switch (level) {
    LgLvl.error => _Color.red.paint(header),
    LgLvl.warning => _Color.orange.paint(header),
    LgLvl.info => _Color.green.paint(header),
    LgLvl.fine => _Color.blue.paint(header),
    LgLvl.finer => _Color.blue.paint(header),
    LgLvl.no => throw Exception('LgLvl.no is never meant to be painted'),
  },);
  if (LogOptions.instance.trace) {
    try {
      var trace = _parseTrace(StackTrace.current, extraTraceLineOffset: extraTraceLineOffset);
      messageBuilder.write(_Color.grey.paint(" - ${trace.$1} ${trace.$2}:${trace.$3}"));
    } catch(_) {
      messageBuilder.write(_Color.grey.paint(" - TRACE ERROR"));
    }
  }
  messageBuilder.write("\n$msg");
  if (e != null) {
    messageBuilder.write(_Color.red.paint("\nError: $e"));
  }
  if (st != null) {
    messageBuilder.write("\nStackTrace:\n$st");
  }
  messageBuilder.write('$_etbChar\n');
  String message = messageBuilder.toString();
  bool isFirstLine = true;
  message = message.splitMapJoin('\n', onNonMatch: (e) {
    if (isFirstLine) {
      isFirstLine = false;
      return e;
    } else {
      return '    $e';
    }
  },);
  return message;
}

enum _Color {
  red,
  green,
  blue,
  orange,
  grey;

  String paint(String text) {
    if (LogOptions.instance.paint) {
      return switch (this) {
        _Color.red => dcli.red(text, bold: false),
        _Color.green => dcli.green(text, bold: false),
        _Color.blue => dcli.blue(text, bold: false),
        _Color.orange => dcli.orange(text, bold: false),
        _Color.grey => dcli.grey(text, bold: false),
      };
    } else {
      return text;
    }
  }
}


enum LgLvl {
  error   (0, 'error',    '[E]'),
  warning (1, 'warning',  '[W]'),
  info    (2, 'info',     '[I]'),
  fine    (3, 'fine',     '[F]'),
  finer   (4, 'finer',    '[f]'),
  no      (-1, 'no',      '[N]');

  final int value;
  final String name;
  final String print;
  const LgLvl(this.value, this.name, this.print);

  @override
  String toString() => print;

  /// Dado un string [s] devuelve un [LgLvl] opcional
  static LgLvl fromString(String s) {
    for (final lvl in LgLvl.values) {
      if (s == lvl.name) {
        return lvl;
      }
    }
    throw ArgumentError("String not matching", "s");
  }
}


class LogOptions {

  static LogOptions? _instance;
  static LogOptions get instance {
    _instance ??= LogOptions._internal();
    return _instance!;
  }

  LogOptions._internal();
  static void setInstance(LogOptions instance) {
    if (_instance!=null) throw Exception('Trying to set LogOptions instance twice in the same Isolate');
    _instance = instance;
  }

  LgLvl _level = LgLvl.finer;
  LgLvl get level => _level;

  Map<Object, LgLvl?> _types = Map.unmodifiable({});
  /// each type can specify its own level; if null, same lvl as global is assumed
  /// to disable a specific type, call set its level to LgLvl.no
  Map<Object, LgLvl?> get types => _types;

  bool paint = true;
  bool trace = true;
  int relevantStackTraceLineOffset = 0;

  bool get isAddLevelSafe => !_calledLevel;
  bool _calledLevel = false;
  void setLevel(LgLvl level) {
    if (_calledLevel) throw Exception('Trying to add options twice to the same LogOptions instance');
    if (level==LgLvl.no) throw ArgumentError('LgLvl.no cannot be set as the expected level output, it is only ment to turn off a specific type');
    _calledLevel = true;
    _level = level;
  }

  bool get isAddTypesSafe => !_calledTypes;
  bool _calledTypes = false;
  void addTypes(Map<Object, LgLvl?> types) {
    if (_calledTypes) throw Exception('Trying to add options twice to the same LogOptions instance');
    _calledTypes = true;
    _types = Map.unmodifiable({
      ..._types,
      ...types,
    });
  }

  LgLvl getLvlForType(Object? type) {
    return types[type] ?? level;
  }

}

/// regex to locate file name
final _rgx = RegExp(r'[\w,_,-,\.]+.dart');
/// end of block char to denote the end of the log message
final _etbChar = String.fromCharCode(23);

(String fn, String file, int line) _parseTrace(StackTrace st, {
  int extraTraceLineOffset = 0,
}) {
  var frames = st.toString().split("\n");
  final frameIndex = 1 + LogOptions.instance.relevantStackTraceLineOffset + extraTraceLineOffset;
  if (frames.length <= frameIndex) {
    return ("", "", 0);
  }
  String functionName = _getFunctionNameFromFrame(frames[frameIndex]);
  var traceString = frames[frameIndex];
  var indexOfFileName = traceString.indexOf(_rgx);
  var fileInfo = traceString.substring(indexOfFileName);
  var listOfInfos = fileInfo.split(":");
  String fileName = listOfInfos[0];
  int lineNumber = int.tryParse(listOfInfos[1]) ?? -1;
  return (functionName, fileName, lineNumber);
}

String _getFunctionNameFromFrame(String frame) {
  var currentTrace = frame;
  var indexOfWhiteSpace = currentTrace.indexOf(' ');
  var subStr = currentTrace.substring(indexOfWhiteSpace);
  var indexOfFunction = subStr.indexOf(RegExp(r'[A-Za-z0-9]'));
  subStr = subStr.substring(indexOfFunction);
  indexOfWhiteSpace = subStr.indexOf(' ');
  subStr = subStr.substring(0, indexOfWhiteSpace);
  return subStr;
}
