import '../repositories/acl_repository.dart';

class RemoveAclUseCase {
  final AclRepository _repository;
  const RemoveAclUseCase(this._repository);

  Future<void> call(String ip) => _repository.remove(ip);
}
