import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/domain/models/registration_models.dart';

/// Defensive enum parsers mapping PostgreSQL enum strings to Dart domain enums.
abstract final class EnumParsers {
  static String _normalize(Object? raw) {
    return (raw ?? '')
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\s\-&]+'), '_');
  }

  static EventCategory parseEventCategory(Object? raw) {
    final norm = _normalize(raw);
    return switch (norm) {
      'tech_ai' || 'tech' || 'technical' || 'ai' || 'techai' =>
        EventCategory.techAi,
      'hackathon' || 'hackathons' => EventCategory.hackathons,
      'cultural' || 'arts' || 'music' => EventCategory.cultural,
      'workshop' || 'workshops' || 'seminar' => EventCategory.workshops,
      'sport' || 'sports' => EventCategory.sports,
      'entrepreneurship' || 'startup' || 'startups' || 'ecell' =>
        EventCategory.entrepreneurship,
      'design' || 'ui_ux' || 'media' => EventCategory.design,
      _ => EventCategory.workshops,
    };
  }

  static RegistrationMode parseRegistrationMode(Object? raw) {
    final norm = _normalize(raw);
    return switch (norm) {
      'advanced' || 'custom' || 'form' || 'custom_form' =>
        RegistrationMode.advanced,
      _ => RegistrationMode.basic,
    };
  }

  static RegistrationStatus parseRegistrationStatus(Object? raw) {
    final norm = _normalize(raw);
    return switch (norm) {
      'cancelled' || 'canceled' => RegistrationStatus.cancelled,
      'completed' || 'attended' => RegistrationStatus.completed,
      _ => RegistrationStatus.confirmed,
    };
  }

  static MediaKind parseMediaKind(Object? raw) {
    final norm = _normalize(raw);
    return switch (norm) {
      'video' || 'promo_video' || 'recap_video' => MediaKind.video,
      _ => MediaKind.photo,
    };
  }

  static NotificationType parseNotificationType(Object? raw) {
    final norm = _normalize(raw);
    return switch (norm) {
      'new_event' || 'new_event_published' || 'event_published' =>
        NotificationType.newEventPublished,
      'registration_confirmed' ||
      'registration_confirmation' ||
      'registration' => NotificationType.registrationConfirmation,
      'event_reminder' || 'reminder' => NotificationType.eventReminder,
      'event_updated' || 'event_changes' || 'event_update' =>
        NotificationType.eventChanges,
      'deadline_reminder' || 'deadline' => NotificationType.deadlineReminder,
      _ => NotificationType.clubAnnouncement,
    };
  }

  static QuestionFieldType parseQuestionFieldType(Object? raw) {
    final norm = _normalize(raw);
    return switch (norm) {
      'long_text' || 'textarea' || 'paragraph' => QuestionFieldType.longText,
      'single_choice' || 'radio' => QuestionFieldType.singleChoice,
      'multiple_choice' || 'multi_select' || 'checkboxes' =>
        QuestionFieldType.multipleChoice,
      'dropdown' || 'select' => QuestionFieldType.dropdown,
      'checkbox' || 'boolean' => QuestionFieldType.checkbox,
      'number' || 'integer' || 'numeric' => QuestionFieldType.number,
      'file_upload' || 'file' => QuestionFieldType.fileUpload,
      _ => QuestionFieldType.shortText,
    };
  }
}
