/// Resolves a human-readable service label for a connection.
///
/// Prefers the DNS-derived [serviceName] (e.g. "YouTube", "Google"); when that
/// is unavailable it falls back to a well-known destination port name, and
/// finally to the raw port so a row is never left blank.
class ServiceResolver {
  ServiceResolver._();

  static const Map<int, String> _wellKnownPorts = {
    80: 'HTTP',
    443: 'HTTPS',
    8080: 'HTTP (Alt)',
    8443: 'HTTPS (Alt)',
    53: 'DNS',
    22: 'SSH',
    21: 'FTP',
    25: 'Email (SMTP)',
    465: 'Email (SMTP)',
    587: 'Email (SMTP)',
    110: 'Email (POP3)',
    995: 'Email (POP3)',
    143: 'Email (IMAP)',
    993: 'Email (IMAP)',
    3389: 'Remote Desktop',
    123: 'Time Sync (NTP)',
    67: 'DHCP',
    68: 'DHCP',
    5228: 'Google Services',
    5353: 'Local Network (mDNS)',
    1900: 'Device Discovery',
    3478: 'Voice / Video',
    5060: 'Voice / Video',
    5061: 'Voice / Video',
  };

  /// Best display label for a connection. Never returns an empty string.
  static String label({
    required String serviceName,
    required int dstPort,
  }) {
    final name = serviceName.trim();
    if (name.isNotEmpty) return name;

    final known = _wellKnownPorts[dstPort];
    if (known != null) return known;

    if (dstPort > 0) return 'Port $dstPort';
    return 'Unknown service';
  }
}
