import 'package:mlog/mlog.dart';
import 'package:test/test.dart';

void main() {
	test('First Test', () {
		mlog(LgLvl.info, "hola");
	});
}
