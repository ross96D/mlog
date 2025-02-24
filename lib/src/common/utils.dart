import 'package:mlog/mlog.dart';

final _rgx = RegExp(r'[\w,_,-,\.]+.dart');


(String fn, String file, int line) parseTrace(StackTrace st, {
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

extension RFC3339 on DateTime {
  String toRFC3339() {
    if (isUtc) {
      return toIso8601String();
    }
    final offset = timeZoneOffset;
    var timeOffset = "";

    String pad(int hours) {
      if (hours >= 10) {
        return hours.toString();
      } else {
        return "0$hours";
      }
    }

    if (offset.isNegative) {
      timeOffset = "${pad(offset.inHours)}:00";
    } else {
      timeOffset = "+${pad(offset.inHours)}:00";
    }
    return toIso8601String() + timeOffset;
  }
}
