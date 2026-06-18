class ApiConstants {
  // Replace with your actual backend URL before deploying.
  //
  // Running on a PHYSICAL device: it must reach the dev machine over the LAN by
  // IP — `localhost`/`10.0.2.2` won't work. `192.168.0.189` is this machine's
  // current LAN IP; update it if the network changes (run `ipconfig getifaddr
  // en0`). The Flask server must also be bound to 0.0.0.0, not 127.0.0.1.
  //
  // The local Flask dev server runs over HTTPS (adhoc/self-signed cert), so the
  // scheme must be `https`. The self-signed certificate is accepted in debug
  // mode via badCertificateCallback in DioConsumer.
  static const String baseUrl = 'https://192.168.0.189:8000/';

  static const String metricsEndpoint = '/api/metrics/device';
}
