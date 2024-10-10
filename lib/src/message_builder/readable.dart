import 'package:mlog/src/common/colors.dart';
import 'package:mlog/src/message_builder/message_builder.dart';
import 'package:mlog/src/mlog_base.dart';
import 'package:mlog/src/nested_error.dart';
import 'package:mlog/src/common/utils.dart';

final _etbChar = String.fromCharCode(23);

class ReadableMessageBuilder implements MessageBuilder {
  	@override
  	String? messageBuilder(LgLvl level, String? msg, Object? extra, {
		Object? type,
		Object? e,
		StackTrace? st,
		int extraTraceLineOffset = 0,
  	}) {
		msg ??= "";
		if (e is NestedError) {
			st = e.originalStackTrace;
		}
		StringBuffer messageBuilder = StringBuffer('');
		final color = level.color;
		String header = "$level";

		if (type != null) {
			header += ' $type';
		}

		header += ' ${DateTime.now()}';
		messageBuilder.write(color.paint(header));
		if (LogOptions.instance.trace) {
			try {
				var trace = parseTrace(StackTrace.current, extraTraceLineOffset: extraTraceLineOffset);
				messageBuilder.write(Color.grey.paint(" - ${trace.$1} ${trace.$2}:${trace.$3}"));
			} catch (_) {
				messageBuilder.write(Color.grey.paint(" - TRACE ERROR"));
			}
		}
		messageBuilder.write("\n$msg");
		if (e != null) {
			messageBuilder.write(color.paint("\nError: $e"));
		}
		if (st != null) {
			messageBuilder.write("\nStackTrace:\n$st");
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
