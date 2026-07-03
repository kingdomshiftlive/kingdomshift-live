import 'dart:developer';

import 'package:flutter/foundation.dart';

logger(dynamic v, {String? name}) {
  if (kDebugMode) {
    log("$v", name: name ?? "");
  }
}

mixin LoggerMixin {
  logs(dynamic v) {
    logger("$v", name: runtimeType.toString());
  }
}
