import 'package:mlog/mlog.dart';

abstract class MessageBuilder {
  	String? messageBuilder(LgLvl level, String? msg,  Object? extra, {
		Object? type,
		Object? e,
		StackTrace? st,
		int extraTraceLineOffset = 0,
  	});
}