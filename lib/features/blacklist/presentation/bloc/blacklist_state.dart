import 'package:equatable/equatable.dart';

import 'package:Sentri/features/blacklist/domain/entities/blacklist_entry.dart';

class BlacklistState extends Equatable {
  final List<BlacklistEntry> entries;

  const BlacklistState({this.entries = const []});

  @override
  List<Object?> get props => [entries];
}
