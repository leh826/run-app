import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final supabase = Supabase.instance.client;

  void listenNotifications(String userId, Function(Map) onNotification) {

    supabase
        .channel('notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {

            final data = payload.newRecord;

            onNotification(data);
          },
        )
        .subscribe();
  }
}