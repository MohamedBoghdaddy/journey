/// A placeholder chat service.
///
/// In a production environment you may use Supabase Realtime, Firebase
/// Firestore or another messaging backend to implement chat. This class
/// outlines the API surface but does not perform any network requests.
class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  /// Sends a message to a chat channel.
  Future<void> sendMessage(String channelId, String message) async {
    // TODO: implement chat sending via realtime or other service
    throw UnimplementedError('Chat service not yet implemented');
  }

  /// Returns a stream of messages for a channel.
  Stream<List<String>> subscribeToChannel(String channelId) {
    // TODO: implement chat subscription
    throw UnimplementedError('Chat service not yet implemented');
  }
}