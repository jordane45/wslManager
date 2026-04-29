import 'dart:io';
import '../models/wsl_instance.dart';
import '../utils/wsl_parser.dart';

class WslService {
  static WslService? _instance;
  static WslService get instance => _instance ??= WslService._();
  WslService._();

  Future<List<WslInstance>> listInstances() async {
    final result = await Process.run(
      'wsl',
      ['--list', '--verbose'],
      runInShell: true,
      stdoutEncoding: null, // Get raw bytes
    );
    final bytes = result.stdout as List<int>;
    final decoded = WslParser.decodeWslOutput(bytes);
    return WslParser.parseVerboseList(decoded);
  }

  Future<void> startInstance(String name) async {
    await Process.run('wsl', ['-d', name, '--', 'exit'], runInShell: true);
  }

  Future<void> stopInstance(String name) async {
    await Process.run('wsl', ['--terminate', name], runInShell: true);
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
    await Process.run('wsl', ['--export', name, tarPath], runInShell: true);
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
    await Process.run(
      'wsl',
      ['--import', name, installDir, tarPath, '--version', '2'],
      runInShell: true,
    );
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
    final tmp =
        '${Directory.systemTemp.path}\\wsl_dup_$sourceName.tar';
    await stopInstance(sourceName);
    await exportInstance(sourceName, tmp);
    await importInstance(newName, installDir, tmp);
    await File(tmp).delete();
  }

  Future<void> setDefaultDistro(String name) async {
    await Process.run('wsl', ['--set-default', name], runInShell: true);
  }

  Future<void> setVersion(String name, int version) async {
    await Process.run(
      'wsl',
      ['--set-version', name, version.toString()],
      runInShell: true,
    );
  }

  Future<void> setupUser(
    String instanceName,
    String username,
    String password,
  ) async {
    await Process.run(
      'wsl',
      ['-d', instanceName, '-u', 'root', '--', 'useradd', '-m', '-s', '/bin/bash', username],
      runInShell: true,
    );
    await Process.run(
      'wsl',
      ['-d', instanceName, '-u', 'root', '--', 'usermod', '-aG', 'sudo', username],
      runInShell: true,
    );
    await Process.run(
      'wsl',
      ['-d', instanceName, '-u', 'root', '--', 'bash', '-c', 'echo "$username:$password" | chpasswd'],
      runInShell: true,
    );
    final wslConf = '[user]\\ndefault=$username\\n';
    await Process.run(
      'wsl',
      ['-d', instanceName, '-u', 'root', '--', 'bash', '-c', 'printf "$wslConf" > /etc/wsl.conf'],
      runInShell: true,
    );
    await stopInstance(instanceName);
    password = ''; // clear from memory
  }

  Future<String> readWslConf(String instanceName) async {
    final result = await Process.run(
      'wsl',
      ['-d', instanceName, '-u', 'root', '--', 'cat', '/etc/wsl.conf'],
      runInShell: true,
    );
    return result.stdout as String? ?? '';
  }

  Future<void> writeWslConf(String instanceName, String content) async {
    final escaped = content.replaceAll("'", "'\\''");
    await Process.run(
      'wsl',
      ['-d', instanceName, '-u', 'root', '--', 'bash', '-c', "printf '%s' '$escaped' > /etc/wsl.conf"],
      runInShell: true,
    );
  }

  Future<void> resetPassword(
    String instanceName,
    String username,
    String newPassword,
  ) async {
    await Process.run(
      'wsl',
      ['-d', instanceName, '-u', 'root', '--', 'bash', '-c', 'echo "$username:$newPassword" | chpasswd'],
      runInShell: true,
    );
    newPassword = '';
  }

  Future<void> openInVsCode(String name) async {
    await Process.run('code', ['--remote', 'wsl+$name'], runInShell: true);
  }

  Future<void> openInExplorer(String name) async {
    await Process.run('explorer.exe', [r'\\wsl.localhost\' + name], runInShell: true);
  }

  Future<void> openInTerminal(String name) async {
    await Process.run('wt', ['wsl', '-d', name], runInShell: true);
  }
}
