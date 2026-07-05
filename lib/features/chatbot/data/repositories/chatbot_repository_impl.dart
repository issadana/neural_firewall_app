import 'package:injectable/injectable.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../datasources/chatbot_remote_datasource.dart';

@LazySingleton(as: ChatbotRepository)
class ChatbotRepositoryImpl implements ChatbotRepository {
  final ChatbotRemoteDataSource _dataSource;
  ChatbotRepositoryImpl(this._dataSource);

  @override
  Stream<String> sendMessage(String message) => _dataSource.streamMessage(message);
}
