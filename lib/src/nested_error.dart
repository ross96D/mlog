

class NestedError extends Error {
	final String msg;
	final Object previousError;
	final StackTrace previousStackTrace;

	NestedError(this.previousError, this.previousStackTrace, this.msg);

	@override toString() {
		return '$msg\n$previousError';
	}

	StackTrace get originalStackTrace {
		final previousError = this.previousError;
		if (previousError is NestedError) {
			return previousError.originalStackTrace;
		} else {
			return previousStackTrace;
		}
	}

}


extension OriginalError on Object {

	Object get originalError {
		final currentError = this;
		if (currentError is NestedError) {
			return currentError.previousError.originalError;
		} else {
			return currentError;
		}
	}

}