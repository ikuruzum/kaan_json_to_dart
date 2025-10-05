import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

Clipboard get cl {
  if (Platform.isWindows) {
    return _WindowsClipboard();
  } else if (Platform.isMacOS) {
    return _MacClipboard();
  } else {
    return _LinuxClipboard();
  }
}

class _MacClipboard implements Clipboard {
  @override
  Future<bool> write(covariant String input) async {
    final process = await Process.start('pbcopy', [], runInShell: true);
    process.stderr.transform(utf8.decoder).listen(print);
    process.stdin.write(input);

    try {
      await process.stdin.close();
    } catch (e) {
      return false;
    }

    return await process.exitCode == 0;
  }

  @override
  Future<String> read() async {
    final process = await Process.start('pbpaste', [], runInShell: true);
    process.stderr.transform(utf8.decoder).listen(print);

    final stdout = process.stdout.transform(utf8.decoder);

    try {
      return await stdout.first;
    } catch (_) {
      return '';
    }
  }
}

class _LinuxClipboard implements Clipboard {
  Future<bool> _isWayland() async {
    // Check if running under Wayland
    return Platform.environment['WAYLAND_DISPLAY'] != null ||
        Platform.environment['XDG_SESSION_TYPE'] == 'wayland';
  }

  Future<bool> _commandExists(String command) async {
    try {
      final result = await Process.run('which', [command]);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> write(covariant String input) async {
    final isWayland = await _isWayland();
    
    // Try Wayland first if running under Wayland
    if (isWayland && await _commandExists('wl-copy')) {
      try {
        final process = await Process.start('wl-copy', [], runInShell: true);
        process.stderr.transform(utf8.decoder).listen(print);
        process.stdin.write(input);
        
        await process.stdin.close();
        return await process.exitCode == 0;
      } catch (e) {
        print('wl-copy failed, trying fallback...');
      }
    }
    
    // Fallback to xsel for X11 or if wl-copy failed
    if (await _commandExists('xsel')) {
      try {
        final process = await Process.start('xsel', ['--clipboard', '--input'],
            runInShell: true);
        process.stderr.transform(utf8.decoder).listen(print);
        process.stdin.write(input);
        
        await process.stdin.close();
        return await process.exitCode == 0;
      } catch (e) {
        print('xsel failed: $e');
      }
    }
    
    print(
        'Clipboard needs [wl-copy] for Wayland or [xsel] for X11. Nothing was written to clipboard');
    return false;
  }

  @override
  Future<String> read() async {
    final isWayland = await _isWayland();
    
    // Try Wayland first if running under Wayland
    if (isWayland && await _commandExists('wl-paste')) {
      try {
        final process = await Process.start('wl-paste', [], runInShell: true);
        process.stderr.transform(utf8.decoder).listen(print);
        
        final stdout = process.stdout.transform(utf8.decoder);
        return await stdout.first;
      } catch (e) {
        print('wl-paste failed, trying fallback...');
      }
    }
    
    // Fallback to xsel for X11 or if wl-paste failed
    if (await _commandExists('xsel')) {
      try {
        final process = await Process.start('xsel', ['--clipboard', '--output'],
            runInShell: true);
        process.stderr.transform(utf8.decoder).listen(print);
        
        final stdout = process.stdout.transform(utf8.decoder);
        return await stdout.first;
      } catch (_) {
        return '';
      }
    }
    
    return '';
  }
}

final winCopyPath = path
    .normalize(path.join(path.current, 'lib/src/backends/windows/copy.exe'));
final winPastePath = path
    .normalize(path.join(path.current, 'lib/src/backends/windows/paste.exe'));

class _WindowsClipboard implements Clipboard {
  @override
  Future<bool> write(covariant String input) async {
    final process = await Process.start(winCopyPath, [], runInShell: true);
    process.stderr.transform(utf8.decoder).listen(print);
    process.stdin.write(input);

    try {
      await process.stdin.close();
    } catch (e) {
      return false;
    }

    return await process.exitCode == 0;
  }

  @override
  Future<String> read() async {
    final process = await Process.start(winPastePath, [], runInShell: true);
    process.stderr.transform(utf8.decoder).listen(print);

    final stdout = process.stdout.transform(utf8.decoder);

    try {
      return await stdout.first;
    } catch (_) {
      return '';
    }
  }
}

abstract class Clipboard {
  Future<bool> write(input);
  Future<String> read();
}
