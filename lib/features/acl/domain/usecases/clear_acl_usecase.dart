import '../repositories/acl_repository.dart';

class ClearAclUseCase {
  final AclRepository _repository;
  const ClearAclUseCase(this._repository);

  Future<void> call() => _repository.clearAll();
}
