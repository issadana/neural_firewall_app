import '../entities/acl_entry.dart';
import '../repositories/acl_repository.dart';

class GetAclUseCase {
  final AclRepository _repository;
  const GetAclUseCase(this._repository);

  Future<List<AclEntry>> call() => _repository.getAll();
}
