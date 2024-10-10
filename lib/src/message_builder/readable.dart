import 'package:mlog/src/common/colors.dart';
import 'package:mlog/src/message_builder/message_builder.dart';
import 'package:mlog/src/mlog_base.dart';
import 'package:mlog/src/common/utils.dart';

final _etbChar = String.fromCharCode(23);

class ReadableMessageBuilder implements MessageBuilder {
  	@override
  	String messageBuilder(LgLvl level, DateTime time, LoggingFields data, [
		int extraTraceLineOffset = 0,
	]) {
		StringBuffer messageBuilder = StringBuffer('');
		final color = level.color;
		String header = "$level";

		final type = data.type();
		if (type != null) {
			header += ' $type';
		}

		header += ' $time';
		messageBuilder.write(color.paint(header));
		if (LogOptions.instance.trace) {
			try {
				final (function, file, line) = parseTrace(StackTrace.current, extraTraceLineOffset: extraTraceLineOffset);
				messageBuilder.write(Color.grey.paint(" - $function $file:$line"));
			} catch (_) {
				messageBuilder.write(Color.grey.paint(" - TRACE ERROR"));
			}
		}
		messageBuilder.write("\n${data.message() ?? ""}");
		final e = data.error();
		if (e != null) {
			messageBuilder.write(color.paint(e));
		}
		String message = messageBuilder.toString();
		bool isFirstLine = true;
		message = message.splitMapJoin('\n',
			onNonMatch: (e) {
				if (isFirstLine) {
					isFirstLine = false;
					return e;
				} else {
					return '    $e';
				}
			},
		);
		message += '$_etbChar\n';
		return message;
 	}
}
