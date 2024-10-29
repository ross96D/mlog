import 'package:mlog/src/common/colors.dart';
import 'package:mlog/src/mlog_base.dart';
import 'package:mlog/src/common/utils.dart';

final _etbChar = String.fromCharCode(23);

class ReadableMessageBuilder implements MessageBuilder {

	@override
	String buildMessage(LogBuilder builder) {
		StringBuffer messageBuffer = StringBuffer('');
		final color = builder.level.color;
		String header = "${builder.level}";

		final type = builder.type;
		if (type != null) {
			header += ' $type';
		}

		final time = builder.time ?? DateTime.now();
		header += ' $time';
		messageBuffer.write(color.paint(header));
		if (LogOptions.instance.trace) {
			try {
				final (function, file, line) = parseTrace(StackTrace.current,
					extraTraceLineOffset: builder.extraTraceLineOffset,
				);
				messageBuffer.write(Color.grey.paint(" - $function $file:$line"));
			} catch (_) {
				messageBuffer.write(Color.grey.paint(" - TRACE ERROR"));
			}
		}
		if (builder.message!=null) {
			messageBuffer.write("\n${builder.message}");
		}
		final e = builder.error;
		if (e != null) {
			messageBuffer.write(color.paint("\n$e"));
		}
		String message = messageBuffer.toString();
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
