/// Lifecycle state of the firewall-log WebSocket connection.
///
/// Observe [FirewallLogWsService.statusStream] to drive a connection
/// indicator in the UI (e.g. a dot on the dashboard).
enum WsStatus { connecting, connected, disconnected, error }
