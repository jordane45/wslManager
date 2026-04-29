import 'dart:io';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class UacService {
  static UacService? _instance;
  static UacService get instance => _instance ??= UacService._();
  UacService._();

  bool isElevated() {
    if (!Platform.isWindows) return true;
    try {
      final hToken = calloc<HANDLE>();
      final elevated = calloc<TOKEN_ELEVATION>();
      final returnLength = calloc<DWORD>();

      OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, hToken);
      GetTokenInformation(
        hToken.value,
        TOKEN_INFORMATION_CLASS.TokenElevation,
        elevated,
        sizeOf<TOKEN_ELEVATION>(),
        returnLength,
      );
      final result = elevated.ref.TokenIsElevated != 0;

      calloc.free(hToken);
      calloc.free(elevated);
      calloc.free(returnLength);
      return result;
    } catch (_) {
      return false;
    }
  }

  Future<void> relaunchAsAdmin() async {
    final exe = Platform.resolvedExecutable;
    await Process.run(
      'powershell',
      ['-Command', 'Start-Process -FilePath "$exe" -Verb RunAs'],
      runInShell: true,
    );
    exit(0);
  }
}
