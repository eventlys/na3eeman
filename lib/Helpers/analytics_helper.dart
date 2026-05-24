import '../Services/analytics_service.dart';
import 'logger.dart';

class AnalyticsHelper {
  static final AnalyticsHelper _instance = AnalyticsHelper._internal();

  factory AnalyticsHelper() => _instance;

  AnalyticsHelper._internal();

  final AnalyticsService _analyticsService = AnalyticsService();

  // Track screen views
  static void trackScreenView(
    String screenName, {
    Map<String, Object?>? parameters,
  }) {
    _instance._analyticsService.logScreenView(
      screenName,
      parameters: parameters,
    );

    AppLogger.analytics('Screen View: $screenName', parameters: parameters);
  }

  // Track user actions
  static void trackButtonTap(
    String buttonName, {
    String? screen,
    Map<String, Object?>? parameters,
  }) {
    final eventParameters = {
      'button_name': buttonName,
      'screen': screen,
      ...?parameters,
    };

    _instance._analyticsService.logCustomEvent(
      name: 'button_tap',
      parameters: eventParameters,
    );

    AppLogger.analytics('Button Tap: $buttonName', parameters: eventParameters);
  }

  // Track form interactions
  static void trackFormSubmission(
    String formName, {
    bool success = true,
    String? error,
    Map<String, Object?>? parameters,
  }) {
    final eventParameters = {
      'form_name': formName,
      'success': success,
      'error': error,
      ...?parameters,
    };

    _instance._analyticsService.logCustomEvent(
      name: 'form_submission',
      parameters: eventParameters,
    );

    AppLogger.analytics(
      'Form Submission: $formName',
      parameters: eventParameters,
    );
  }

  // Track search events
  static void trackSearch(
    String query, {
    String? category,
    int? resultCount,
    Map<String, Object?>? parameters,
  }) {
    final eventParameters = {
      'search_query': query,
      'category': category,
      'result_count': resultCount,
      ...?parameters,
    };

    _instance._analyticsService.logSearch(
      searchTerm: query,
      resultCount: resultCount,
    );

    AppLogger.analytics('Search: $query', parameters: eventParameters);
  }

  // Track appointment events
  static void trackAppointmentEvent(
    String action, {
    String? appointmentId,
    String? status,
    Map<String, Object?>? parameters,
  }) {
    final eventParameters = {
      'action': action,
      'appointment_id': appointmentId,
      'status': status,
      ...?parameters,
    };

    _instance._analyticsService.logCustomEvent(
      name: 'appointment_$action',
      parameters: eventParameters,
    );

    AppLogger.analytics('Appointment $action', parameters: eventParameters);
  }

  // Track payment events
  static void trackPaymentEvent(
    String action, {
    double? amount,
    String? method,
    String? status,
    Map<String, Object?>? parameters,
  }) {
    final eventParameters = {
      'action': action,
      'amount': amount,
      'payment_method': method,
      'status': status,
      ...?parameters,
    };

    _instance._analyticsService.logCustomEvent(
      name: 'payment_$action',
      parameters: eventParameters,
    );

    AppLogger.analytics('Payment $action', parameters: eventParameters);
  }

  // Track loyalty events
  static void trackLoyaltyEvent(
    String action, {
    int? points,
    String? source,
    Map<String, Object?>? parameters,
  }) {
    final eventParameters = {
      'action': action,
      'points': points,
      'source': source,
      ...?parameters,
    };

    _instance._analyticsService.logCustomEvent(
      name: 'loyalty_$action',
      parameters: eventParameters,
    );

    AppLogger.analytics('Loyalty $action', parameters: eventParameters);
  }

  // Track error events
  static void trackError(
    String error,
    StackTrace stackTrace, {
    String? context,
    Map<String, Object?>? parameters,
  }) {
    final eventParameters = {
      'error': error,
      'context': context,
      ...?parameters,
    };

    _instance._analyticsService.logError(error, stackTrace, context: context);

    AppLogger.analytics('Error: $error', parameters: eventParameters);
  }

  // Track performance events
  static void trackPerformance(
    String action,
    int durationMs, {
    Map<String, Object?>? parameters,
  }) {
    final eventParameters = {
      'action': action,
      'duration_ms': durationMs,
      ...?parameters,
    };

    _instance._analyticsService.logPerformance(
      action,
      durationMs,
      parameters: parameters,
    );

    AppLogger.performance(action, durationMs);
  }

  // Set user properties
  static void setUserProperties({
    int? userId,
    String? userRole,
    String? email,
    String? name,
  }) {
    _instance._analyticsService.setUserProperties(
      userId: userId,
      userRole: userRole,
      email: email,
      name: name,
    );

    AppLogger.analytics(
      'User Properties Set',
      parameters: {
        'user_id': userId,
        'user_role': userRole,
        'has_email': email != null,
        'has_name': name != null,
      },
    );
  }

  // Track onboarding events
  static void trackOnboardingEvent(
    String step, {
    bool completed = false,
    int? timeSpent,
    Map<String, Object?>? parameters,
  }) {
    final eventParameters = {
      'step': step,
      'completed': completed,
      'time_spent_seconds': timeSpent,
      ...?parameters,
    };

    _instance._analyticsService.logCustomEvent(
      name: 'onboarding_$step',
      parameters: eventParameters,
    );

    AppLogger.analytics('Onboarding: $step', parameters: eventParameters);
  }

  // Track feature usage
  static void trackFeatureUsage(
    String feature, {
    int? usageCount,
    Map<String, Object?>? parameters,
  }) {
    final eventParameters = {
      'feature': feature,
      'usage_count': usageCount,
      ...?parameters,
    };

    _instance._analyticsService.logCustomEvent(
      name: 'feature_usage',
      parameters: eventParameters,
    );

    AppLogger.analytics('Feature Usage: $feature', parameters: eventParameters);
  }

  // Track social sharing
  static void trackShareEvent(
    String contentType, {
    String? contentId,
    String? method,
    Map<String, Object?>? parameters,
  }) {
    final eventParameters = {
      'content_type': contentType,
      'content_id': contentId,
      'method': method,
      ...?parameters,
    };

    _instance._analyticsService.logCustomEvent(
      name: 'share',
      parameters: eventParameters,
    );

    AppLogger.analytics('Share: $contentType', parameters: eventParameters);
  }

  // Track deep link opens
  static void trackDeepLinkOpen(
    String url, {
    String? source,
    Map<String, Object?>? parameters,
  }) {
    final eventParameters = {'url': url, 'source': source, ...?parameters};

    _instance._analyticsService.logCustomEvent(
      name: 'deep_link_open',
      parameters: eventParameters,
    );

    AppLogger.analytics('Deep Link Open: $url', parameters: eventParameters);
  }

  // Track notification interactions
  static void trackNotificationInteraction(
    String type, {
    String? action,
    Map<String, Object?>? parameters,
  }) {
    final eventParameters = {
      'notification_type': type,
      'action': action,
      ...?parameters,
    };

    _instance._analyticsService.logCustomEvent(
      name: 'notification_interaction',
      parameters: eventParameters,
    );

    AppLogger.analytics(
      'Notification Interaction: $type',
      parameters: eventParameters,
    );
  }

  // Track app lifecycle events
  static void trackAppLifecycle(
    String state, {
    int? sessionDuration,
    Map<String, Object?>? parameters,
  }) {
    final eventParameters = {
      'state': state,
      'session_duration_seconds': sessionDuration,
      ...?parameters,
    };

    _instance._analyticsService.logCustomEvent(
      name: 'app_lifecycle',
      parameters: eventParameters,
    );

    AppLogger.analytics('App Lifecycle: $state', parameters: eventParameters);
  }

  // Track network requests
  static void trackNetworkRequest(
    String endpoint,
    String method,
    int statusCode,
    int durationMs, {
    Map<String, Object?>? parameters,
  }) {
    final eventParameters = {
      'endpoint': endpoint,
      'method': method,
      'status_code': statusCode,
      'duration_ms': durationMs,
      ...?parameters,
    };

    _instance._analyticsService.logCustomEvent(
      name: 'network_request',
      parameters: eventParameters,
    );

    AppLogger.api(
      method,
      endpoint,
      statusCode: statusCode,
      durationMs: durationMs,
    );
  }

  // Track battery and performance events
  static void trackPerformanceEvent(
    String metric,
    dynamic value, {
    String? context,
    Map<String, Object?>? parameters,
  }) {
    final eventParameters = {
      'metric': metric,
      'value': value,
      'context': context,
      ...?parameters,
    };

    _instance._analyticsService.logCustomEvent(
      name: 'performance_metric',
      parameters: eventParameters,
    );

    AppLogger.analytics(
      'Performance: $metric = $value',
      parameters: eventParameters,
    );
  }

  // Start a timed event
  static _TimedEvent startTimedEvent(
    String name, {
    Map<String, Object?>? parameters,
  }) {
    _instance._analyticsService.logCustomEvent(
      name: '${name}_started',
      parameters: parameters,
    );

    AppLogger.analytics('Timed Event: $name started', parameters: parameters);

    return _TimedEvent(name, parameters: parameters);
  }
}

// Separate class for timed events (can't be nested inside AnalyticsHelper)
class _TimedEvent {
  final String name;
  final Map<String, Object?>? parameters;
  final DateTime startTime;

  _TimedEvent(this.name, {this.parameters}) : startTime = DateTime.now();

  void end({Map<String, Object?>? additionalParameters}) {
    final duration = DateTime.now().difference(startTime).inMilliseconds;
    final eventParameters = {
      'duration_ms': duration,
      ...?parameters,
      ...?additionalParameters,
    };

    AnalyticsHelper()._analyticsService.logCustomEvent(
      name: '${name}_completed',
      parameters: eventParameters,
    );

    AppLogger.analytics(
      'Timed Event: $name completed in ${duration}ms',
      parameters: eventParameters,
    );
  }
}
