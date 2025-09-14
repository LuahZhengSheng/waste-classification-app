import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../event/models/event_model.dart';
import '../../../event/models/location_model.dart';
import '../../../event/screens/event_detail/event_detail.dart';
import '../../screens/event_management/event_detail/event_detail.dart';
import '../../screens/event_management/event_management.dart';

class EventManagementController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  // Observables
  final RxList<Event> allEvents = <Event>[].obs;
  final RxList<Event> filteredEvents = <Event>[].obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 25.obs;
  final RxInt sortColumnIndex = 0.obs;
  final RxBool sortAscending = true.obs;
  final RxMap<String, dynamic> activeFilters = <String, dynamic>{
    'status': null,
    'isPublished': null,
    'registrationStatus': null,
    'dateRange': null,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    loadEvents();

    // Listen to search changes
    debounce(searchQuery, (_) => applyFiltersAndSearch(), time: const Duration(milliseconds: 500));

    // Listen to filter changes
    ever(activeFilters, (_) => applyFiltersAndSearch());
  }

  void loadEvents() {
    // Mock data - replace with actual API call
    allEvents.value = _generateMockEvents();
    filteredEvents.value = List.from(allEvents);
  }

  List<Event> _generateMockEvents() {
    final now = DateTime.now();
    return [
      Event(
        eventId: '1',
        title: 'Beach Cleanup Drive',
        description: 'Join us for a community beach cleanup to protect marine life.',
        contactEmail: 'contact@beachcleanup.com',
        contactPhoneNo: '123-456-7890',
        location: Location.empty(),
        poster: 'https://example.com/poster1.jpg',
        startDateTime: now.add(const Duration(days: 15)),
        endDateTime: now.add(const Duration(days: 15, hours: 4)),
        registrationDeadline: now.add(const Duration(days: 10)),
        maxParticipants: 100,
        registeredCount: 45,
        createdAt: now.subtract(const Duration(days: 30)),
        isPublish: true,
        status: 'active',
      ),
      Event(
        eventId: '2',
        title: 'Recycling Workshop',
        description: 'Learn about proper recycling techniques and waste management.',
        contactEmail: 'info@recyclingworkshop.org',
        contactPhoneNo: '098-765-4321',
        location: Location.empty(),
        poster: 'https://example.com/poster2.jpg',
        startDateTime: now.subtract(const Duration(days: 2)),
        endDateTime: now.add(const Duration(hours: 2)),
        registrationDeadline: now.subtract(const Duration(days: 5)),
        maxParticipants: 50,
        registeredCount: 50,
        createdAt: now.subtract(const Duration(days: 45)),
        isPublish: true,
        status: 'active',
      ),
      Event(
        eventId: '3',
        title: 'Green Energy Summit',
        description: 'Annual summit on sustainable energy solutions.',
        contactEmail: 'summit@greenenergy.com',
        contactPhoneNo: '555-123-4567',
        location: Location.empty(),
        poster: 'https://example.com/poster3.jpg',
        startDateTime: now.subtract(const Duration(days: 30)),
        endDateTime: now.subtract(const Duration(days: 30, hours: -8)),
        registrationDeadline: now.subtract(const Duration(days: 35)),
        maxParticipants: 200,
        registeredCount: 180,
        createdAt: now.subtract(const Duration(days: 60)),
        isPublish: true,
        status: 'active',
      ),
      Event(
        eventId: '4',
        title: 'Tree Planting Initiative',
        description: 'Community tree planting to combat climate change.',
        contactEmail: 'trees@greenworld.org',
        contactPhoneNo: '444-987-6543',
        location: Location.empty(),
        poster: 'https://example.com/poster4.jpg',
        startDateTime: now.add(const Duration(days: 7)),
        endDateTime: now.add(const Duration(days: 7, hours: 6)),
        registrationDeadline: now.add(const Duration(days: 3)),
        maxParticipants: 75,
        registeredCount: 12,
        createdAt: now.subtract(const Duration(days: 15)),
        isPublish: false,
        status: 'active',
      ),
      Event(
        eventId: '5',
        title: 'Waste Management Seminar',
        description: 'Educational seminar on modern waste management practices.',
        contactEmail: 'seminar@wastemanagement.com',
        contactPhoneNo: '777-111-2222',
        location: Location.empty(),
        poster: 'https://example.com/poster5.jpg',
        startDateTime: now.subtract(const Duration(days: 60)),
        endDateTime: now.subtract(const Duration(days: 60, hours: -4)),
        registrationDeadline: now.subtract(const Duration(days: 65)),
        maxParticipants: 120,
        registeredCount: 95,
        createdAt: now.subtract(const Duration(days: 90)),
        isPublish: true,
        status: 'cancelled',
      ),
    ];
  }

  // Get computed event status based on dates
  String getEventComputedStatus(Event event) {
    final now = DateTime.now();

    if (event.status == 'cancelled' || event.status == 'deleted') {
      return event.status;
    }

    if (now.isBefore(event.startDateTime)) {
      return 'upcoming';
    } else if (now.isAfter(event.startDateTime) && now.isBefore(event.endDateTime)) {
      return 'ongoing';
    } else if (now.isAfter(event.endDateTime)) {
      return 'completed';
    }

    return 'upcoming';
  }

  // Search functionality
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void applyFiltersAndSearch() {
    List<Event> result = List.from(allEvents);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      result = result.where((event) {
        return event.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            event.description.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            event.contactEmail.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    // Apply filters
    if (activeFilters['status'] != null) {
      result = result.where((event) => getEventComputedStatus(event) == activeFilters['status']).toList();
    }

    if (activeFilters['isPublished'] != null) {
      result = result.where((event) => event.isPublish == activeFilters['isPublished']).toList();
    }

    if (activeFilters['registrationStatus'] != null) {
      result = result.where((event) {
        switch (activeFilters['registrationStatus']) {
          case 'open':
            return event.isRegistrationOpen;
          case 'closed':
            return event.isRegistrationClosed;
          case 'full':
            return event.isFullyBooked;
          default:
            return true;
        }
      }).toList();
    }

    if (activeFilters['dateRange'] != null) {
      final now = DateTime.now();
      DateTime? startDate;

      switch (activeFilters['dateRange']) {
        case 'next7days':
          startDate = now;
          result = result.where((event) =>
          event.startDateTime.isAfter(now) &&
              event.startDateTime.isBefore(now.add(const Duration(days: 7)))
          ).toList();
          break;
        case 'next30days':
          startDate = now;
          result = result.where((event) =>
          event.startDateTime.isAfter(now) &&
              event.startDateTime.isBefore(now.add(const Duration(days: 30)))
          ).toList();
          break;
        case 'thisMonth':
          final startOfMonth = DateTime(now.year, now.month, 1);
          final endOfMonth = DateTime(now.year, now.month + 1, 0);
          result = result.where((event) =>
          event.startDateTime.isAfter(startOfMonth) &&
              event.startDateTime.isBefore(endOfMonth)
          ).toList();
          break;
      }
    }

    filteredEvents.value = result;
    currentPage.value = 1; // Reset to first page after filtering
  }

  // Check if any filters are active
  bool get hasActiveFilters {
    return activeFilters['status'] != null ||
        activeFilters['isPublished'] != null ||
        activeFilters['registrationStatus'] != null ||
        activeFilters['dateRange'] != null;
  }

  // Sorting functionality
  void sortEvents(int columnIndex, bool ascending) {
    sortColumnIndex.value = columnIndex;
    sortAscending.value = ascending;

    filteredEvents.sort((a, b) {
      dynamic aValue, bValue;

      switch (columnIndex) {
        case 0: // Title
          aValue = a.title;
          bValue = b.title;
          break;
        case 1: // Status
          aValue = getEventComputedStatus(a);
          bValue = getEventComputedStatus(b);
          break;
        case 2: // Start Date
          aValue = a.startDateTime;
          bValue = b.startDateTime;
          break;
        case 3: // End Date
          aValue = a.endDateTime;
          bValue = b.endDateTime;
          break;
        case 4: // Registration Deadline
          aValue = a.registrationDeadline;
          bValue = b.registrationDeadline;
          break;
        case 5: // Max Participants
          aValue = a.maxParticipants;
          bValue = b.maxParticipants;
          break;
        case 6: // Registered Count
          aValue = a.registeredCount;
          bValue = b.registeredCount;
          break;
        case 7: // Published
          aValue = a.isPublish ? 1 : 0;
          bValue = b.isPublish ? 1 : 0;
          break;
        default:
          return 0;
      }

      int result;
      if (aValue is String && bValue is String) {
        result = aValue.toLowerCase().compareTo(bValue.toLowerCase());
      } else if (aValue is DateTime && bValue is DateTime) {
        result = aValue.compareTo(bValue);
      } else if (aValue is num && bValue is num) {
        result = aValue.compareTo(bValue);
      } else {
        result = aValue.toString().compareTo(bValue.toString());
      }

      return ascending ? result : -result;
    });
  }

  // Event actions
  void togglePublishStatus(Event event) {
    final eventIndex = allEvents.indexWhere((e) => e.eventId == event.eventId);
    if (eventIndex != -1) {
      allEvents[eventIndex] = event.copyWith(isPublish: !event.isPublish);
      applyFiltersAndSearch();
    }
  }

  void cancelEvent(Event event) {
    final eventIndex = allEvents.indexWhere((e) => e.eventId == event.eventId);
    if (eventIndex != -1) {
      allEvents[eventIndex] = event.copyWith(status: 'cancelled');
      applyFiltersAndSearch();
    }
  }

  void deleteEvent(Event event) {
    final eventIndex = allEvents.indexWhere((e) => e.eventId == event.eventId);
    if (eventIndex != -1) {
      allEvents[eventIndex] = event.copyWith(status: 'deleted');
      applyFiltersAndSearch();
    }
  }

  void addEvent() {
    // Navigate to add event screen
    print('Navigate to add event screen');
  }

  void viewEvent(String eventId) {
    // Navigate to view event screen
    Get.to(() => AdminEventDetailsScreen(eventId: eventId));
  }

  void editEvent(Event event) {
    // Navigate to edit event screen
    print('Edit event: ${event.title}');
  }

  // Pagination functionality
  List<Event> get paginatedEvents {
    final startIndex = (currentPage.value - 1) * itemsPerPage.value;
    final endIndex = (startIndex + itemsPerPage.value).clamp(0, filteredEvents.length);

    if (startIndex >= filteredEvents.length) {
      return [];
    }

    return filteredEvents.sublist(startIndex, endIndex);
  }

  int get totalEvents => filteredEvents.length;
  int get totalPages => (totalEvents / itemsPerPage.value).ceil();
  int get startIndex => (currentPage.value - 1) * itemsPerPage.value;
  int get endIndex => (startIndex + itemsPerPage.value).clamp(0, totalEvents);

  bool get canGoPreviousPage => currentPage.value > 1;
  bool get canGoNextPage => currentPage.value < totalPages;

  void previousPage() {
    if (canGoPreviousPage) {
      currentPage.value--;
    }
  }

  void nextPage() {
    if (canGoNextPage) {
      currentPage.value++;
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  void changeItemsPerPage(int? newValue) {
    if (newValue != null) {
      itemsPerPage.value = newValue;
      currentPage.value = 1; // Reset to first page
    }
  }

  void showFilters() {
    final dark = FHelperFunctions.isDarkMode(Get.context!);

    Get.dialog(
      EventFilterDialog(
        dark: dark,
        currentFilters: Map.from(activeFilters),
        onApplyFilters: (newFilters) {
          activeFilters.assignAll(newFilters);
        },
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}