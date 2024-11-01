import 'package:flutter/material.dart';
import 'package:planpals/features/profile/models/user_model.dart';
import 'package:planpals/features/profile/viewmodels/user_viewmodel.dart';
import 'package:planpals/features/travel_planner/models/accommodation_model.dart';
import 'package:planpals/features/travel_planner/models/destination_model.dart';
import 'package:planpals/features/travel_planner/validators/accommodation_validator.dart';
import 'package:planpals/features/travel_planner/viewmodels/planner_viewmodel.dart';
import 'package:planpals/shared/components/date_time_form.dart';
import 'package:provider/provider.dart';

class CreateAccommodationForm extends StatefulWidget {
  final Destination destination;

  const CreateAccommodationForm({super.key, required this.destination});

  @override
  _CreateAccommodationFormState createState() => _CreateAccommodationFormState();
}

class _CreateAccommodationFormState extends State<CreateAccommodationForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  DateTime? _checkIn;
  DateTime? _checkOut;

  @override
  Widget build(BuildContext context) {
    final PlannerViewModel plannerViewModel =
        Provider.of<PlannerViewModel>(context, listen: false);
    final User? user = Provider.of<UserViewModel>(context).currentUser;

    final Destination destination = widget.destination;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Accommodation Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Accommodation Name Field
              TextFormField(
                controller: _nameController,
                decoration:
                    const InputDecoration(labelText: 'Accommodation Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the accommodation name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20), // margin

              // Address Field
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20), // margin

              // Check-In Date field
              DateTimeForm(
                initialDate: _checkIn,
                labelText: 'Check-In Date and Time',
                placeholder: 'Set Check-In Date and Time',
                dateTimeSelected: (selectedDateTime) {
                  setState(() {
                    _checkIn = selectedDateTime;
                  });
                },
              ),

              const SizedBox(height: 15), // Space between date fields

              // Check-Out Date field
              DateTimeForm(
                initialDate: _checkOut,
                labelText: 'Check-Out Date and Time',
                placeholder: 'Set Check-Out Date and Time',
                dateTimeSelected: (selectedDateTime) {
                  setState(() {
                    _checkOut = selectedDateTime;
                  });
                },
              ),

              const SizedBox(height: 20), // margin

              // Submit Button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() == true) {
                    // Validate custom date logic
                    final dateError = AccommodationValidator.validateDates(
                        _checkIn, _checkOut);
                    if (dateError != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(dateError)),
                      );
                      return;
                    }

                    Accommodation? newAccommodation;

                    newAccommodation = await plannerViewModel.addAccommodation(
                      Accommodation(
                        name: _nameController.text,
                        address: _addressController.text,
                        checkInDate: _checkIn!,
                        checkOutDate: _checkOut!,
                        destinationId: destination.destinationId, 
                        accommodationId: '',
                        createdBy: user!.id
                      ),
                      destination.plannerId,
                      user.id
                    );

                    
                    if (newAccommodation == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to add Accommodation')),
                      );
                    }
                    else {
                      // Add the new Accommodation ID to the destination
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Accommodation added successfully!')),
                      );
                      destination.accommodations.add(newAccommodation.accommodationId); // Add the new Accommodation ID to the destination
                      destination.accommodationList.add(newAccommodation);
                    }


                    // Close the form screen
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Accommodation'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
