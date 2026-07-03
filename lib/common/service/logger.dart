import 'dart:developer';

import 'package:flutter/foundation.dart';

void logger(dynamic v, {String? name}) {
  if (kDebugMode) {
    log("$v", name: name ?? "");
  }
}

mixin LoggerMixin {
  void logs(dynamic v) {
    logger("$v", name: runtimeType.toString());
  }
}
