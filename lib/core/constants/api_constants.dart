class ApiConstants {
  // Deployed backend. REST calls hit `${baseUrl}<path>`; the firewall-log
  // WebSocket derives `wss://api.sentri-security.cloud/ws/logs?token=` from
  // this (see FirewallLogWsService._wsUri). Note the WS path is `/ws/logs`
  // (registered globally via flask-sock `@sock.route`), NOT under the
  // `/firewall-logs` REST blueprint prefix.
  //
  // For local development against the Flask dev server, swap this for the LAN
  // IP of the dev machine, e.g. `https://192.168.10.92:8000/` (must be reachable
  // from the device; the self-signed cert is accepted in debug via
  // badCertificateCallback in DioConsumer / the WS service).
  static const String baseUrl = 'https://api.sentri-security.cloud/';
}
