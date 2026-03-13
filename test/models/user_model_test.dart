import 'package:flutter_test/flutter_test.dart';
import 'package:atiora/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromJson should correctly parse JSON', () {
      final json = {'id': 'user-123', 'email': 'test@example.com'};
      final user = UserModel.fromJson(json);

      expect(user.id, 'user-123');
      expect(user.email, 'test@example.com');
    });

    test('toJson should correctly serialize model', () {
      const user = UserModel(id: 'user-123', email: 'test@example.com');
      final json = user.toJson();

      expect(json['id'], 'user-123');
      expect(json['email'], 'test@example.com');
    });

    test('props should return all fields', () {
      const user = UserModel(id: 'user-123', email: 'test@example.com');

      expect(user.props, ['user-123', 'test@example.com']);
    });

    test('two users with same data should be equal', () {
      const user1 = UserModel(id: 'user-123', email: 'test@example.com');
      const user2 = UserModel(id: 'user-123', email: 'test@example.com');

      expect(user1, equals(user2));
    });

    test('two users with different data should not be equal', () {
      const user1 = UserModel(id: 'user-123', email: 'test@example.com');
      const user2 = UserModel(id: 'user-456', email: 'other@example.com');

      expect(user1, isNot(equals(user2)));
    });
  });
}
