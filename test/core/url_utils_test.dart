import 'package:flutter_test/flutter_test.dart';
import 'package:personal_learning_os/core/utils/url_utils.dart';

void main() {
  group('UrlUtils.normalize', () {
    test('adds https when the scheme is missing', () {
      expect(UrlUtils.normalize('flutter.dev'), 'https://flutter.dev');
      expect(
        UrlUtils.normalize('  docs.flutter.dev/ui  '),
        'https://docs.flutter.dev/ui',
      );
    });

    test('keeps valid http and https URLs', () {
      expect(
        UrlUtils.normalize('http://example.com/a?b=1'),
        'http://example.com/a?b=1',
      );
      expect(
        UrlUtils.normalize('https://localhost:8080'),
        'https://localhost:8080',
      );
    });

    test('returns empty for empty input', () {
      expect(UrlUtils.normalize('   '), '');
    });

    test('rejects invalid input', () {
      expect(UrlUtils.normalize('not a url'), isNull);
      expect(UrlUtils.normalize('javascript:alert(1)'), isNull);
      expect(UrlUtils.normalize('ftp://example.com'), isNull);
      expect(UrlUtils.normalize('https://nodot'), isNull);
      expect(UrlUtils.normalize('https://${'a' * 2100}.com'), isNull);
    });
  });

  test('displayHost strips www and path', () {
    expect(
      UrlUtils.displayHost('https://www.youtube.com/watch?v=1'),
      'youtube.com',
    );
    expect(
      UrlUtils.displayHost('https://docs.flutter.dev/ui'),
      'docs.flutter.dev',
    );
    expect(UrlUtils.displayHost(''), '');
  });
}
