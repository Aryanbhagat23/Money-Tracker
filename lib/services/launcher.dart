import 'package:url_launcher/url_launcher.dart';

/// Opens phone calls, text messages and web pages. Wrapped so tests can
/// record what would have been opened.
abstract class Launcher {
  Future<bool> open(Uri uri);
}

class SystemLauncher implements Launcher {
  const SystemLauncher();

  @override
  Future<bool> open(Uri uri) async {
    final external = uri.scheme == 'http' || uri.scheme == 'https';
    try {
      return await launchUrl(
        uri,
        mode: external
            ? LaunchMode.externalApplication
            : LaunchMode.platformDefault,
      );
    } on Exception {
      return false;
    }
  }
}

class RecordingLauncher implements Launcher {
  final List<Uri> opened = [];

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return true;
  }
}
