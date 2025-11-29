import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/popups/admin_loaders.dart';
import '../../../../data/repositories/event/event_repository.dart';
import '../../../../data/repositories/event/event_registration_repository.dart';
import '../../../../data/repositories/event/reminder_repository.dart';
import '../../../../data/repositories/user/user_repository.dart';
import '../../../../features/authentication/models/user_model.dart';
import '../../../../features/event/models/event_model.dart';
import '../../screens/event_management/edit_event/edit_event.dart';

class AdminEventDetailController extends GetxController {
  static AdminEventDetailController get instance => Get.find();

  // Dependencies
  final EventRepository _eventRepository = Get.put(EventRepository());
  final EventRegistrationRepository _registrationRepository = Get.put(EventRegistrationRepository());
  final UserRepository _userRepository = Get.put(UserRepository());
  final ReminderRepository _reminderRepository = Get.put(ReminderRepository());

  // Observables
  final Rx<Event> event = Event.empty().obs;
  final RxList<EventRegistrationWithUser> eventRegistrations = <EventRegistrationWithUser>[].obs;
  final RxList<EventRegistrationWithUser> filteredRegistrations = <EventRegistrationWithUser>[].obs;
  final RxBool isLoading = false.obs;
  final RxString sortBy = 'newest'.obs;
  final RxString filterBy = 'all'.obs;

  // Statistics
  final RxInt totalRegistrations = 0.obs;
  final RxInt activeRegistrations = 0.obs;
  final RxInt cancelledRegistrations = 0.obs;

  @override
  void onInit() {
    super.onInit();
    ever(sortBy, (_) => applySortAndFilter());
    ever(filterBy, (_) => applySortAndFilter());
  }

  void loadEventDetails(String eventId) {
    isLoading.value = true;

    // Listen to event stream
    _eventRepository.getEventById(eventId).listen((loadedEvent) {
      event.value = loadedEvent;
      _loadRegistrations(eventId);
    }, onError: (error) {
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load event: $error',
      );
      print('$error');
      isLoading.value = false;
    });
  }

  void _loadRegistrations(String eventId) {
    // Listen to registrations stream
    _registrationRepository.getEventRegistrations(eventId).listen((registrationDocs) async {
      if (registrationDocs.isEmpty) {
        eventRegistrations.clear();
        _calculateStatistics();
        applySortAndFilter();
        isLoading.value = false;
        return;
      }

      // Get all user IDs
      final userIds = registrationDocs.map((doc) {
        // 修复类型错误：使用 as Map<String, dynamic> 进行类型转换
        final data = doc.data() as Map<String, dynamic>;
        return data['userId'] as String;
      }).toSet();

      // Fetch users data
      final usersData = await _userRepository.getUsersProfileData(userIds);

      // Combine registrations with user data
      final List<EventRegistrationWithUser> regWithUsers = [];
      for (final doc in registrationDocs) {
        // 修复类型错误：将 DocumentSnapshot<Object?> 转换为 DocumentSnapshot<Map<String, dynamic>>
        final registration = _createRegistrationFromDocument(doc);
        final user = usersData[registration.userId] ?? UserModel.empty();

        regWithUsers.add(EventRegistrationWithUser(
          registration: registration,
          user: user,
        ));
      }

      eventRegistrations.value = regWithUsers;
      _calculateStatistics();
      applySortAndFilter();
      isLoading.value = false;
    }, onError: (error) {
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load registrations: $error',
      );
      print('$error');
      isLoading.value = false;
    });
  }

  /// 修复方法：从 DocumentSnapshot<Object?> 创建 EventRegistration
  EventRegistration _createRegistrationFromDocument(DocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return EventRegistration.empty();

    return EventRegistration(
      registrationId: doc.id,
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCancelled: data['isCancelled'] ?? false,
    );
  }

  void _calculateStatistics() {
    totalRegistrations.value = eventRegistrations.length;
    activeRegistrations.value = eventRegistrations.where((reg) => !reg.registration.isCancelled).length;
    cancelledRegistrations.value = eventRegistrations.where((reg) => reg.registration.isCancelled).length;
  }

  void applySortAndFilter() {
    List<EventRegistrationWithUser> result = List.from(eventRegistrations);

    // Apply filter
    switch (filterBy.value) {
      case 'active':
        result = result.where((reg) => !reg.registration.isCancelled).toList();
        break;
      case 'cancelled':
        result = result.where((reg) => reg.registration.isCancelled).toList();
        break;
      case 'all':
      default:
        break;
    }

    // Apply sort
    switch (sortBy.value) {
      case 'newest':
        result.sort((a, b) => b.registration.createdAt.compareTo(a.registration.createdAt));
        break;
      case 'oldest':
        result.sort((a, b) => a.registration.createdAt.compareTo(b.registration.createdAt));
        break;
      case 'name':
        result.sort((a, b) => a.user.username.toLowerCase().compareTo(b.user.username.toLowerCase()));
        break;
    }

    filteredRegistrations.value = result;
  }

  void setSortBy(String newSortBy) {
    sortBy.value = newSortBy;
  }

  void setFilterBy(String newFilterBy) {
    filterBy.value = newFilterBy;
  }

  String getRegistrationStatusText(EventRegistration registration) {
    return registration.isCancelled ? 'Cancelled' : 'Active';
  }

  Color getRegistrationStatusColor(EventRegistration registration, bool dark) {
    if (registration.isCancelled) {
      return dark ? FColors.adminDarkError : FColors.adminLightError;
    }
    return dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
  }

  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Actions
  void editEvent() {
    Get.to(() => EditEventScreen(event: event.value));
  }

  Future<void> cancelEvent() async {
    try {
      final confirmed = await Get.dialog<bool>(
        _ConfirmCancelEventDialog(event: event.value),
      );

      if (confirmed != true) return;

      // Update event status
      final updatedEvent = event.value.copyWith(
        status: 'cancelled',
        isPublish: false,
      );
      await _eventRepository.updateEvent(updatedEvent);

      // Delete all reminders for this event
      for (final regWithUser in eventRegistrations) {
        final reminder = await _reminderRepository.getReminderByRegistration(
          regWithUser.registration.registrationId,
        );
        if (reminder != null) {
          await _reminderRepository.deleteReminder(reminder.reminderId);
        }
      }

      FAdminLoaders.successSnackBar(
        title: 'Event Cancelled',
        message: 'Event has been cancelled successfully',
      );

      Get.back(); // Go back to event management
    } catch (e) {
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to cancel event: $e',
      );
      print('$e');
    }
  }

  Future<void> deleteEvent() async {
    try {
      final confirmed = await Get.dialog<bool>(
        _ConfirmDeleteEventDialog(event: event.value),
      );

      if (confirmed != true) return;

      final updatedEvent = event.value.copyWith(
        status: 'deleted',
        isPublish: false,
      );
      await _eventRepository.updateEvent(updatedEvent);

      FAdminLoaders.successSnackBar(
        title: 'Event Deleted',
        message: 'Event has been deleted successfully',
      );

      Get.back(); // Go back to event management
    } catch (e) {
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to delete event: $e',
      );
      print('$e');
    }
  }
}

// Model class
class EventRegistrationWithUser {
  final EventRegistration registration;
  final UserModel user;

  EventRegistrationWithUser({
    required this.registration,
    required this.user,
  });
}

// Confirmation Dialogs
class _ConfirmCancelEventDialog extends StatelessWidget {
  final Event event;

  const _ConfirmCancelEventDialog({required this.event});

  @override
  Widget build(BuildContext context) {
    final dark = Get.isDarkMode;

    return AlertDialog(
      backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Cancel Event',
        style: TextStyle(
          color: dark ? FColors.adminDarkText : FColors.adminLightText,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to cancel "${event.title}"?',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This will:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• Send cancellation notifications to all registered users',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              fontSize: 13,
            ),
          ),
          Text(
            '• Delete all event reminders',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              fontSize: 13,
            ),
          ),
          Text(
            '• Hide the event from users',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This action cannot be undone.',
            style: TextStyle(
              color: dark ? FColors.adminDarkError : FColors.adminLightError,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(
            'No, Keep Event',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(
            backgroundColor: dark ? FColors.adminDarkError : FColors.adminLightError,
          ),
          child: const Text(
            'Yes, Cancel Event',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _ConfirmDeleteEventDialog extends StatelessWidget {
  final Event event;

  const _ConfirmDeleteEventDialog({required this.event});

  @override
  Widget build(BuildContext context) {
    final dark = Get.isDarkMode;

    return AlertDialog(
      backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Delete Event',
        style: TextStyle(
          color: dark ? FColors.adminDarkText : FColors.adminLightText,
        ),
      ),
      content: Text(
        'Are you sure you want to delete "${event.title}"? This action cannot be undone.',
        style: TextStyle(
          color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(
            backgroundColor: dark ? FColors.adminDarkError : FColors.adminLightError,
          ),
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// Model representing an event registration
class EventRegistration {
  final String registrationId;
  final String userId;
  final DateTime createdAt;
  final bool isCancelled;

  const EventRegistration({
    required this.registrationId,
    required this.userId,
    required this.createdAt,
    this.isCancelled = false,
  });

  /// Creates an empty EventRegistration instance
  static EventRegistration empty() => EventRegistration(
    registrationId: '',
    userId: '',
    createdAt: DateTime.now(),
    isCancelled: false,
  );

  /// Creates EventRegistration instance from JSON map
  factory EventRegistration.fromJson(Map<String, dynamic> json) {
    return EventRegistration(
      registrationId: json['registrationId'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isCancelled: json['isCancelled'] ?? false,
    );
  }

  /// Creates EventRegistration instance from Firebase DocumentSnapshot
  factory EventRegistration.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) return EventRegistration.empty();

    return EventRegistration(
      registrationId: snapshot.id,
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCancelled: data['isCancelled'] ?? false,
    );
  }

  /// Converts EventRegistration instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'registrationId': registrationId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'isCancelled': isCancelled,
    };
  }

  /// Converts EventRegistration instance to Firestore map (with Timestamp)
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isCancelled': isCancelled,
    };
  }

  /// Returns formatted creation date
  String get formattedCreatedAt {
    // You'll need to implement or import your date formatting function
    // For now, using basic formatting
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// Returns registration status text
  String get statusText {
    return isCancelled ? 'Cancelled' : 'Active';
  }

  /// Checks if registration is active
  bool get isActive => !isCancelled;

  /// Creates a copy of EventRegistration with updated fields
  EventRegistration copyWith({
    String? registrationId,
    String? userId,
    DateTime? createdAt,
    bool? isCancelled,
  }) {
    return EventRegistration(
      registrationId: registrationId ?? this.registrationId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isCancelled: isCancelled ?? this.isCancelled,
    );
  }

  @override
  String toString() {
    return 'EventRegistration(registrationId: $registrationId, userId: $userId, createdAt: $createdAt, isCancelled: $isCancelled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EventRegistration &&
        other.registrationId == registrationId &&
        other.userId == userId &&
        other.createdAt == createdAt &&
        other.isCancelled == isCancelled;
  }

  @override
  int get hashCode {
    return registrationId.hashCode ^
    userId.hashCode ^
    createdAt.hashCode ^
    isCancelled.hashCode;
  }
}