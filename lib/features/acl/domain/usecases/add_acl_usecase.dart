import '../repositories/acl_repository.dart';

class AddAclUseCase {
  final AclRepository _repository;
  const AddAclUseCase(this._repository);

  Future<void> call(String ip, {String? notes}) => _repository.add(ip, notes: notes);
}
