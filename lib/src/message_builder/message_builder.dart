import 'package:mlog/mlog.dart';

abstract class MessageBuilder {
  String messageBuilder(LgLvl level, Object? msg, {
    Object? type,
    Object? e,
    StackTrace? st,
    int extraTraceLineOffset = 0,
  });
}