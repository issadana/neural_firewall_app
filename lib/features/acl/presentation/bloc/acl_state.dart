import 'package:equatable/equatable.dart';

import 'package:Sentri/features/acl/domain/entities/acl_entry.dart';

class AclState extends Equatable {
  final List<AclEntry> entries;

  const AclState({this.entries = const []});

  @override
  List<Object?> get props => [entries];
}
