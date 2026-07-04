import '../../domain/repositories/chatbot_repository.dart';
import '../datasources/chatbot_remote_datasource.dart';

class ChatbotRepositoryImpl implements ChatbotRepository {
  final ChatbotRemoteDataSource _dataSource;
  ChatbotRepositoryImpl(this._dataSource);

  @override
  Stream<String> sendMessage(String message) => _dataSource.streamMessage(message);
}
