import 'package:gql/language.dart' as gql_lang;
import 'package:gql_exec/gql_exec.dart';
import 'package:taskflow/core/config/graphql_client.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/data/models/notification.dart';

class NotificationRemoteDataSource {
  NotificationRemoteDataSource();

  Future<NotificationList> getMyNotifications({
    bool? isRead,
    AppNotificationType? type,
    int offset = 0,
    int limit = 30,
  }) async {
    const query = r'''
      query GetMyNotifications($input: ListNotificationsInput) {
        myNotifications(input: $input) {
          items {
            id
            title
            message
            type
            isRead
            relatedEntityType
            relatedEntityId
            createdAt
          }
          total
        }
      }
    ''';

    final input = <String, dynamic>{
      'offset': offset,
      'limit': limit,
      if (isRead != null) 'isRead': isRead,
      if (type != null) 'type': type.value,
    };

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(query),
          operationName: 'GetMyNotifications',
        ),
        variables: {'input': input},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final data = response.data?['myNotifications'];
      if (data == null) {
        throw const ServerException(message: 'Failed to fetch notifications');
      }

      final items = (data['items'] as List<dynamic>)
          .map((item) => AppNotification(
                id: item['id'],
                title: item['title'],
                message: item['message'],
                type: AppNotificationType.fromString(item['type']),
                isRead: item['isRead'],
                relatedEntityType: item['relatedEntityType'],
                relatedEntityId: item['relatedEntityId'],
                createdAt: DateTime.parse(item['createdAt']),
              ))
          .toList();

      return NotificationList(
        items: items,
        total: (data['total'] as num).toInt(),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<void> markNotificationsRead(List<String> ids) async {
    const mutation = r'''
      mutation MarkNotificationsRead($input: MarkNotificationsReadInput!) {
        markNotificationsRead(input: $input)
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutation),
          operationName: 'MarkNotificationsRead',
        ),
        variables: {
          'input': {'notificationIds': ids},
        },
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<void> markAllNotificationsRead() async {
    const mutation = r'''
      mutation MarkAllNotificationsRead {
        markAllNotificationsRead
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutation),
          operationName: 'MarkAllNotificationsRead',
        ),
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  void _handleGraphQLErrors(List<dynamic> errors) {
    final message = errors.map((e) => e.message).join(', ');
    if (message.toLowerCase().contains('unauthorized') ||
        message.toLowerCase().contains('unauthenticated')) {
      throw AuthException(message: message);
    }
    throw ServerException(message: message);
  }
}
