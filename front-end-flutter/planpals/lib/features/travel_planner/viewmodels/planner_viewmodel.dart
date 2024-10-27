import 'package:flutter/material.dart';
import 'package:planpals/features/travel_planner/models/accommodation_model.dart';
import 'package:planpals/features/travel_planner/models/planner_model.dart';
import 'package:planpals/features/travel_planner/models/destination_model.dart';
import 'package:planpals/features/travel_planner/models/activity_model.dart';
import 'package:planpals/features/travel_planner/models/transport_model.dart';
import 'package:planpals/features/travel_planner/services/planner_service.dart';

class PlannerViewModel extends ChangeNotifier {
  final PlannerService _plannerService = PlannerService();

  // State variables for the UI
  List<Planner> _planners = [];
  List<Destination> _destinations = [];
  List<Activity> _activities = [];
  List<Transport> _transports = [];
  List<Accommodation> _accommodations = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Planner> get planners => _planners;
  List<Destination> get destinations => _destinations;
  List<Activity> get activities => _activities;
  List<Transport> get transports => _transports;
  List<Accommodation> get accommodations => _accommodations;
  bool get isLoading => _isLoading; // Get loading state
  String? get errorMessage => _errorMessage; // Get error message


  // ----------------------------------------
  // FETCHERS
  // ----------------------------------------

  // Fetch all planners by user ID
  Future<void> fetchAllPlanners() async {
    _isLoading = true;
    _planners = [];
    notifyListeners(); // Notify listeners about the loading state

    print('PLANNERVIEWMODEL: FETCHING ALL PLANNERS');

    try {
      _planners = await _plannerService.fetchAllPlanners();
      _errorMessage = null; // Clear any previous error message
    } catch (e) {
      _errorMessage = e.toString(); // Store error message
    } finally {
      _isLoading = false; // Set loading to false
      notifyListeners(); // Notify listeners about the loading state change
    }
  }

  // Fetch all planners by user ID
  Future<void> fetchPlannersByUserId(String userId) async {
    _isLoading = true;
    _planners = [];
    notifyListeners(); // Notify listeners about the loading state

    print('Fetching Planners by userid:$userId)');

    try {
      _planners = await _plannerService.fetchPlannersByUserId(userId);
      print('PLANNERS: $_planners');
      _errorMessage = null; // Clear any previous error message
    } catch (e) {
      _errorMessage = e.toString(); // Store error message
    } finally {
      _isLoading = false; // Set loading to false
      notifyListeners(); // Notify listeners about the loading state change
    }
  }

  // Fetch all transports by planner ID
  Future<void> fetchTransportsByPlannerId(String plannerId, String userId) async {
    _isLoading = true;
    _transports = [];
    notifyListeners();

    try {
      print('PLANNERVIEWMODEL: FETCHING ALL TRANSPORTS by plannerId: $plannerId');
      _transports = await _plannerService.fetchAllTransportsByUserId(plannerId, userId);
      print('PLANNERVIEWMODEL: FETCHED ALL TRANSPORTS by plannerId: $plannerId');
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch all destinations by planner ID and User ID
  Future<void> fetchDestinationsByPlannerId(String plannerId, String userId) async {
    _isLoading = true;
    _destinations = [];
    notifyListeners();

    try {
      _destinations = await _plannerService.fetchAllDestinationsByUserId(plannerId, userId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch all activities by planner ID and destination ID
  Future<void> fetchActivitiesByDestinationId(
      String plannerId, String destinationId, String userId) async {
    _isLoading = true;
    _activities = [];
    notifyListeners();

    try {
      _activities =
          await _plannerService.fetchActivitiesByDestinationId(plannerId, destinationId, userId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch all accommodations by planner ID and destination ID
  Future<void> fetchAccommodationsByDestinationId(
      String plannerId, String destinationId, String userId) async {
    _isLoading = true;
    _accommodations = [];
    notifyListeners();

    try {
      _accommodations =
          await _plannerService.fetchAccommodationsByDestinationId(plannerId, destinationId, userId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  // ----------------------------------------
  // ADDERS
  // ----------------------------------------

  // Add a new destination to the planner
  Future<Planner> addPlanner(Planner planner) async {
    _isLoading = true;
    _errorMessage = null; // Reset error message
    notifyListeners();

    Planner newPlanner = planner;
    try {
      newPlanner = await _plannerService.addPlanner(newPlanner);
      _planners.add(newPlanner); // Add to local state if successful
    } catch (e) {
      _errorMessage = 'Failed to add planner: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners whether success or failure
    }
    return newPlanner;
  }

  // Add a new destination to the planner
  Future<Destination> addDestination(Destination destination) async {
    _isLoading = true;
    _errorMessage = null; // Reset error message
    notifyListeners();

    Destination newDestination = destination;
    try {
      print("PLANNERVIEWMODEL: ADDING DESTINATION: $newDestination");
      newDestination =
          await _plannerService.addDestination(newDestination);
      _destinations.add(newDestination); // Add to local state if successful
            print("PLANNERVIEWMODEL: ADDED DESTINATION: $newDestination");

      notifyListeners(); // Notify listeners about the change
    } catch (e) {
      _errorMessage = 'Failed to add destination: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners whether success or failure
    }
    return newDestination;
  }

  // Add a new transporation to the planner
  Future<Transport> addTransport(Transport transport) async {
    _isLoading = true;
    _errorMessage = null; // Reset error message
    notifyListeners();

    Transport newTransport = transport;
    try {
      print("PLANNERVIEWMODEL: ADDING TRANSPORT: $newTransport");
      newTransport =
          await _plannerService.addTransport(newTransport);

      print('PLANNERVIEWMODEL: ADDED TRANSPORT: $newTransport');
      _transports.add(newTransport); // Add to local state if successful
      notifyListeners(); // Notify listeners about the change
    } catch (e) {
      _errorMessage = 'Failed to add transportation: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners whether success or failure
    }
    return newTransport;
  }

  Future<Accommodation> addAccommodation(Accommodation accommodation, String plannerId, String userId) async {
    _isLoading = true;
    _errorMessage = null; // Reset error message
    notifyListeners();

    Accommodation newAccommodation = accommodation;
    try {
      newAccommodation = await _plannerService.addAccommodation(newAccommodation, plannerId, userId);
      _accommodations.add(newAccommodation); // Add to local state if successful
      notifyListeners(); // Notify listeners about the change
    } catch (e) {
      _errorMessage = 'Failed to add activity: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return newAccommodation;
  }

  Future<Activity> addActivity(Activity activity, String plannerId, String userId) async {
    _isLoading = true;
    _errorMessage = null; // Reset error message
    notifyListeners();

    Activity newActivity = activity;
    try {
      newActivity = await _plannerService.addActivity(newActivity, plannerId, userId);
      _activities.add(newActivity); // Add to local state if successful
      notifyListeners(); // Notify listeners about the change
    } catch (e) {
      _errorMessage = 'Failed to add activity: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return newActivity;
  }


  // ----------------------------------------
  // UPDATERS
  // ----------------------------------------

  Future<Planner> updatePlanner(Planner planner, String userId) async {
    _isLoading = true;
    _errorMessage = null; // Reset error message
    notifyListeners();

    Planner updatedPlanner = planner;
    try {
      updatedPlanner = await _plannerService.updatePlanner(updatedPlanner, userId);
      _planners
          .firstWhere((planner) => planner.plannerId == updatedPlanner.plannerId)
          .update(updatedPlanner); // Update local state if successful
    } catch (e) {
      _errorMessage = 'Failed to update planner: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners whether success or failure
    }
    return updatedPlanner;
  }

  Future<Destination> updateDestination(Destination destination, String userId) async {
    _isLoading = true;
    _errorMessage = null; // Reset error message
    notifyListeners();

    Destination updatedDestination = destination;
    try {
      updatedDestination =
          await _plannerService.updateDestination(updatedDestination, userId);
      _destinations
          .firstWhere((destination) =>
              destination.destinationId == updatedDestination.destinationId)
          .update(updatedDestination); // Update local state if successful
    } catch (e) {
      _errorMessage = 'Failed to update destination: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners whether success or failure
    }
    return updatedDestination;
  }

  Future<Transport> updateTransport(Transport transport, String userId) async {
    _isLoading = true;
    _errorMessage = null; // Reset error message
    notifyListeners();

    Transport updatedTransport = transport;
    try {
      updatedTransport =
          await _plannerService.updateTransport(updatedTransport, userId);
      _transports
          .firstWhere((transport) =>
              transport.id == updatedTransport.id)  
          .update(updatedTransport); // Update local state if successful
    } catch (e) {
      _errorMessage = 'Failed to update transportation: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners whether success or failure
    }
    return updatedTransport;
  }

  Future<Accommodation> updateAccommodation(Accommodation accommodation, String plannerId, String userId) async {
    _isLoading = true;
    _errorMessage = null; // Reset error message
    notifyListeners();

    Accommodation updatedAccommodation = accommodation;
    try {
      updatedAccommodation = await _plannerService.updateAccommodation(updatedAccommodation, plannerId, userId);
      _accommodations
          .firstWhere((accommodation) =>
              accommodation.accommodationId == updatedAccommodation.accommodationId)
          .update(updatedAccommodation); // Update local state if successful
    } catch (e) {
      _errorMessage = 'Failed to update accommodation: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners whether success or failure
    }
    return updatedAccommodation;
  }

  Future<Activity> updateActivity(Activity activity, String plannerId, String userId) async {
    _isLoading = true;
    _errorMessage = null; // Reset error message
    notifyListeners();

    Activity updatedActivity = activity;
    try {
      updatedActivity = await _plannerService.updateActivity(updatedActivity, plannerId, userId);
      _activities
          .firstWhere((activity) =>
              activity.activityId == updatedActivity.activityId)
          .update(updatedActivity); // Update local state if successful
    } catch (e) {
      _errorMessage = 'Failed to update activity: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners whether success or failure
    }
    return updatedActivity;
  }


  // ----------------------------------------
  // DELETERS
  // ----------------------------------------


  Future<void> deletePlanner(Planner planner, String userId) async {
    _isLoading = true;
    _errorMessage = null; // Reset error message
    notifyListeners();

    try {
      await _plannerService.deletePlanner(planner, userId);
      _planners.remove(planner); // Remove from local state if successful
    } catch (e) {
      _errorMessage = 'Failed to delete planner: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners whether success or failure
    }
  }

  Future<void> deleteDestination(Destination destination, String userId) async {
    _isLoading = true;
    _errorMessage = null; // Reset error message
    notifyListeners();

    try {
      await _plannerService.deleteDestination(destination, userId);
      _destinations.remove(destination); // Remove from local state if successful
    } catch (e) {
      _errorMessage = 'Failed to delete destination: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners whether success or failure
    }
  }

  Future<void> deleteTransport(Transport transport, String userId) async {
    _isLoading = true;
    _errorMessage = null; // Reset error message
    notifyListeners();

    try {
      await _plannerService.deleteTransport(transport, userId);
      _transports.remove(transport); // Remove from local state if successful
    } catch (e) {
      _errorMessage = 'Failed to delete transportation: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners whether success or failure
    }
  }



  void logout() {
    _planners = [];
    _destinations = [];
    _activities = [];
    _transports = [];
    _accommodations = [];
    _errorMessage = null;
    notifyListeners();
  }
}