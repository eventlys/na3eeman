abstract class DomainEvent {}

class UserLoggedInEvent extends DomainEvent {
  final String userId;
  final String email;

  UserLoggedInEvent(this.userId, this.email);
}

class UserLoggedOutEvent extends DomainEvent {}

class SalonFavoritedEvent extends DomainEvent {
  final String salonId;
  final String salonName;

  SalonFavoritedEvent(this.salonId, this.salonName);
}

class AppointmentBookedEvent extends DomainEvent {
  final String appointmentId;
  final String salonId;
  final double amount;

  AppointmentBookedEvent(this.appointmentId, this.salonId, this.amount);
}

class PointsEarnedEvent extends DomainEvent {
  final int points;
  final String reason;
  final String userId;

  PointsEarnedEvent(this.points, this.reason, this.userId);
}

class EventBus {
  static final EventBus _instance = EventBus._internal();
  final Map<Type, List<Function>> _listeners = {};

  factory EventBus() => _instance;

  EventBus._internal();

  void subscribe<T extends DomainEvent>(Function(T) listener) {
    _listeners[T] ??= [];
    _listeners[T]!.add(listener);
  }

  void publish<T extends DomainEvent>(T event) {
    final listeners = _listeners[T];
    if (listeners != null) {
      for (final listener in listeners) {
        listener(event);
      }
    }
  }

  void unsubscribe<T extends DomainEvent>(Function(T) listener) {
    _listeners[T]?.remove(listener);
  }
}
