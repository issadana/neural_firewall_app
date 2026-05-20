import 'package:equatable/equatable.dart';

import 'package:Sentri/core/enums.dart';

class VpnState extends Equatable {
  final VpnStatus status;
  final String? errorMessage;

  const VpnState({
    required this.status,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, errorMessage];
}
