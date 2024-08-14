import 'package:mlog/src/common/colors.dart';
import 'package:mlog/src/message_builder/message_builder.dart';
import 'package:mlog/src/message_builder/readable.dart';


void mlog(LgLvl level, Object? msg, {
  Object? type,
  Object? e,
  StackTrace? st,
  int extraTraceLineOffset = 0,
}) {
  if (level.value > LogOptions.instance.getLvlForType(type).value) {
      return;
  }

  final message = LogOptions.instance.builder.messageBuilder(level, msg,
    type: type,
    e: e,
    st: st,
    extraTraceLineOffset: extraTraceLineOffset + 1,
  );
  print(message); // ignore: avoid_print
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

  Color get color => switch (this) {
    LgLvl.error => Color.red,
    LgLvl.warning => Color.orange,
    LgLvl.info => Color.green,
    LgLvl.fine => Color.blue,
    LgLvl.finer => Color.blue,
    LgLvl.no => throw Exception('LgLvl.no is never meant to be painted'),
  };
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

  MessageBuilder builder = ReadableMessageBuilder();

  LgLvl getLvlForType(Object? type) {
    return types[type] ?? level;
  }
}
