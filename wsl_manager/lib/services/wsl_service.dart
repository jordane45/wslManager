import 'dart:io';
import '../models/wsl_instance.dart';
import '../utils/wsl_parser.dart';

class WslService {
  static WslService? _instance;
  static WslService get instance => _instance ??= WslService._();
  WslService._();

  Future<ProcessResult> _runWsl(List<String> arguments) async {
    final result = await Process.run(
      'wsl',
      arguments,
      runInShell: true,
      stdoutEncoding: null,
      stderrEncoding: null,
    );
    if (result.exitCode != 0) {
      throw WslCommandException(
          arguments, result.exitCode, _resultOutput(result));
    }
    return result;
  }

  String _resultOutput(ProcessResult result) {
    final stderr = _decodeProcessOutput(result.stderr).trim();
    if (stderr.isNotEmpty) return stderr;
    return _decodeProcessOutput(result.stdout).trim();
  }

  String _decodeProcessOutput(Object? output) {
    if (output is List<int>) return WslParser.decodeWslOutput(output);
    if (output is String) return output;
    return '';
  }

  Future<List<WslInstance>> listInstances() async {
    final result = await _runWsl(['--list', '--verbose']);
    final bytes = result.stdout as List<int>;
    final decoded = WslParser.decodeWslOutput(bytes);
    return WslParser.parseVerboseList(decoded);
  }

  Future<void> startInstance(String name) async {
    await _runWsl(['-d', name, '--', 'exit']);
  }

  Future<void> stopInstance(String name) async {
    await _runWsl(['--terminate', name]);
  }

  Future<void> deleteInstance(String name) async {
    await stopInstance(name);
    await Process.run('wsl', ['--unregister', name], runInShell: true);
  }

  Future<void> exportInstance(
    String name,
    String tarPath, {
    void Function(double)? onProgress,
  }) async {
    if (onProgress != null) {
      _pollExportProgress(tarPath, onProgress);
    }
    await _runWsl(['--export', name, tarPath]);
  }

  void _pollExportProgress(String tarPath, void Function(double) onProgress) {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      final file = File(tarPath);
      if (!file.existsSync()) return true;
      final size = file.lengthSync();
      onProgress(size / (1024 * 1024 * 1024)); // rough GB progress
      return true;
    });
  }

  Future<void> importInstance(
    String name,
    String installDir,
    String tarPath,
  ) async {
    final dir = Directory(installDir);
    if (!dir.existsSync()) await dir.create(recursive: true);
    await _runWsl(['--import', name, installDir, tarPath, '--version', '2']);
  }

  Future<void> renameInstance(
    String oldName,
    String newName,
    String installDir,
  ) async {
    final tmp = '${Directory.systemTemp.path}\\wsl_rename_$oldName.tar';
    await stopInstance(oldName);
    await exportInstance(oldName, tmp);
    await importInstance(newName, installDir, tmp);
    await deleteInstance(oldName);
    await File(tmp).delete();
  }

  Future<void> duplicateInstance(
    String sourceName,
    String newName,
    String installDir,
  ) async {
    final tmp = '${Directory.systemTemp.path}\\wsl_dup_$sourceName.tar';
    await stopInstance(sourceName);
    await exportInstance(sourceName, tmp);
    await importInstance(newName, installDir, tmp);
    await File(tmp).delete();
  }

  Future<void> setDefaultDistro(String name) async {
    await _runWsl(['--set-default', name]);
  }

  Future<void> setVersion(String name, int version) async {
    await _runWsl(['--set-version', name, version.toString()]);
  }

  Future<void> setupUser(
    String instanceName,
    String username,
    String password,
  ) async {
    await _runWsl(
      [
        '-d',
        instanceName,
        '-u',
        'root',
        '--',
        'useradd',
        '-m',
        '-s',
        '/bin/bash',
        username
      ],
    );
    await _runWsl(
      [
        '-d',
        instanceName,
        '-u',
        'root',
        '--',
        'usermod',
        '-aG',
        'sudo',
        username
      ],
    );
    await _runWsl(
      [
        '-d',
        instanceName,
        '-u',
        'root',
        '--',
        'bash',
        '-c',
        'echo "$username:$password" | chpasswd'
      ],
    );
    final wslConf = '[user]\\ndefault=$username\\n';
    await _runWsl(
      [
        '-d',
        instanceName,
        '-u',
        'root',
        '--',
        'bash',
        '-c',
        'printf "$wslConf" > /etc/wsl.conf'
      ],
    );
    await stopInstance(instanceName);
    password = ''; // clear from memory
  }

  Future<String> readWslConf(String instanceName) async {
    final result = await _runWsl(
      ['-d', instanceName, '-u', 'root', '--', 'cat', '/etc/wsl.conf'],
    );
    return _decodeProcessOutput(result.stdout);
  }

  Future<void> writeWslConf(String instanceName, String content) async {
    final escaped = content.replaceAll("'", "'\\''");
    await _runWsl(
      [
        '-d',
        instanceName,
        '-u',
        'root',
        '--',
        'bash',
        '-c',
        "printf '%s' '$escaped' > /etc/wsl.conf"
      ],
    );
  }

  Future<void> resetPassword(
    String instanceName,
    String username,
    String newPassword,
  ) async {
    await _runWsl(
      [
        '-d',
        instanceName,
        '-u',
        'root',
        '--',
        'bash',
        '-c',
        'echo "$username:$newPassword" | chpasswd'
      ],
    );
    newPassword = '';
  }

  Future<void> openInVsCode(String name) async {
    await Process.run('code', ['--remote', 'wsl+$name'], runInShell: true);
  }

  Future<void> openInExplorer(String name) async {
    await Process.run('explorer.exe', [r'\\wsl.localhost\' + name],
        runInShell: true);
  }

  Future<void> openInTerminal(String name) async {
    await Process.run('wt', ['wsl', '-d', name], runInShell: true);
  }
}

class WslCommandException implements Exception {
  final List<String> arguments;
  final int exitCode;
  final String output;

  const WslCommandException(this.arguments, this.exitCode, this.output);

  @override
  String toString() {
    final command = ['wsl', ...arguments].join(' ');
    final details = output.isEmpty ? '' : ' : $output';
    return '$command a échoué (code $exitCode)$details';
  }
}
