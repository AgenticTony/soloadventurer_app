import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/services/viator_service.dart';

/// Booking flow screen for Viator activities.
///
/// Walks the user through: select date → check availability →
/// fill traveler details → hold → confirm booking.
class ViatorBookingScreen extends ConsumerStatefulWidget {
  const ViatorBookingScreen({
    super.key,
    required this.productCode,
    required this.productTitle,
    required this.price,
  });

  final String productCode;
  final String productTitle;
  final double price;

  @override
  ConsumerState<ViatorBookingScreen> createState() =>
      _ViatorBookingScreenState();
}

class _ViatorBookingScreenState extends ConsumerState<ViatorBookingScreen> {
  int _currentStep = 0;
  DateTime? _selectedDate;
  List<ViatorAvailability> _availableSlots = [];
  ViatorAvailability? _selectedSlot;
  int _travelerCount = 1;
  final List<_TravelerFormControllers> _travelerForms = [];
  bool _isLoading = false;
  String? _error;
  ViatorBooking? _confirmedBooking;

  @override
  void initState() {
    super.initState();
    _addTravelerForm();
  }

  @override
  void dispose() {
    for (final form in _travelerForms) {
      form.dispose();
    }
    super.dispose();
  }

  void _addTravelerForm() {
    _travelerForms.add(_TravelerFormControllers());
  }

  Future<void> _checkAvailability() async {
    if (_selectedDate == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = ref.read(viatorServiceProvider);
      final slots = await service.checkAvailability(
        productCode: widget.productCode,
        date: _selectedDate!,
      );

      setState(() {
        _availableSlots = slots.where((s) => s.bookable).toList();
        _isLoading = false;
        if (_availableSlots.isEmpty) {
          _error = 'No availability for this date. Try another date.';
        } else {
          _currentStep = 1;
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to check availability. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _holdAndBook() async {
    if (_selectedSlot == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = ref.read(viatorServiceProvider);

      // Step 1: Hold
      final hold = await service.holdBooking(
        productCode: widget.productCode,
        availability: _selectedSlot!,
        travelerCount: _travelerCount,
      );

      if (hold == null) {
        setState(() {
          _error = 'Failed to hold availability. It may have sold out.';
          _isLoading = false;
        });
        return;
      }

      // Step 2: Book
      final travelers = _travelerForms
          .take(_travelerCount)
          .map((f) => ViatorTravelerDetail(
                firstName: f.firstName.text.trim(),
                lastName: f.lastName.text.trim(),
                email: f.email.text.trim(),
                phone: f.phone.text.trim().isNotEmpty ? f.phone.text.trim() : null,
              ))
          .toList();

      final booking = await service.bookBooking(
        holdToken: hold.holdToken,
        travelerDetails: travelers,
      );

      setState(() {
        _isLoading = false;
        if (booking != null) {
          _confirmedBooking = booking;
          _currentStep = 3;
        } else {
          _error = 'Booking failed. Your hold may have expired.';
        }
      });
    } catch (e) {
      setState(() {
        _error = 'An error occurred during booking. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Activity'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _currentStep > 0 ? () => setState(() => _currentStep--) : null,
        controlsBuilder: (context, details) {
          if (_isLoading) {
            return const Padding(
              padding: EdgeInsets.only(top: 16),
              child: CircularProgressIndicator(),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(details.stepIndex == 2 ? 'Confirm Booking' : 'Continue'),
                ),
                if (details.onStepCancel != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          // Step 0: Select date
          Step(
            title: const Text('Select Date'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                Text(
                  widget.productTitle,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${widget.price.toStringAsFixed(0)} per person',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}'
                        : 'Select a date',
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                ),
                // Traveler count
                Row(
                  children: [
                    const Text('Travelers:'),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: _travelerCount > 1
                          ? () {
                              setState(() => _travelerCount--);
                            }
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$_travelerCount', style: theme.textTheme.titleMedium),
                    IconButton(
                      onPressed: _travelerCount < 10
                          ? () {
                              setState(() {
                                _travelerCount++;
                                if (_travelerForms.length < _travelerCount) {
                                  _addTravelerForm();
                                }
                              });
                            }
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Step 1: Select time slot
          Step(
            title: const Text('Select Time'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: _availableSlots.isEmpty
                ? const Text('No available time slots.')
                : Column(
                    children: _availableSlots.map((slot) {
                      final isSelected = _selectedSlot?.id == slot.id;
                      return ListTile(
                        leading: Radio<ViatorAvailability>(
                          value: slot,
                          groupValue: _selectedSlot,
                          onChanged: (v) => setState(() => _selectedSlot = v),
                        ),
                        title: Text(
                          '${_formatTime(slot.startTime)} - ${_formatTime(slot.endTime)}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$${slot.price.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (slot.spotsRemaining != null)
                              Text('${slot.spotsRemaining} spots left',
                                  style: theme.textTheme.labelSmall),
                          ],
                        ),
                        selected: isSelected,
                        onTap: () => setState(() => _selectedSlot = slot),
                      );
                    }).toList(),
                  ),
          ),

          // Step 2: Traveler details
          Step(
            title: const Text('Traveler Details'),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            content: Column(
              children: List.generate(_travelerCount, (index) {
                final form = _travelerForms[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Traveler ${index + 1}',
                          style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: form.firstName,
                              decoration: const InputDecoration(
                                labelText: 'First Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: form.lastName,
                              decoration: const InputDecoration(
                                labelText: 'Last Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: form.email,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: form.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone (optional)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // Step 3: Confirmation
          Step(
            title: const Text('Confirmation'),
            isActive: _currentStep >= 3,
            content: _confirmedBooking != null
                ? Column(
                    children: [
                      Icon(Icons.check_circle, size: 64, color: Colors.green.shade600),
                      const SizedBox(height: 16),
                      Text('Booking Confirmed!',
                          style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text('Reference: ${_confirmedBooking!.bookingRef}'),
                      const SizedBox(height: 4),
                      Text('Total: \$${_confirmedBooking!.totalPrice.toStringAsFixed(0)} ${_confirmedBooking!.currency}'),
                      if (_confirmedBooking!.cancellationDeadline != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Free cancellation until ${_formatDate(_confirmedBooking!.cancellationDeadline!)}',
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                      ],
                    ],
                  )
                : const Text('Processing...'),
          ),
        ],
      ),
      bottomNavigationBar: _error != null
          ? Container(
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.errorContainer,
              child: Text(
                _error!,
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            )
          : null,
    );
  }

  void _onStepContinue() {
    switch (_currentStep) {
      case 0:
        if (_selectedDate == null) {
          setState(() => _error = 'Please select a date.');
          return;
        }
        _checkAvailability();
      case 1:
        if (_selectedSlot == null) {
          setState(() => _error = 'Please select a time slot.');
          return;
        }
        setState(() => _currentStep = 2);
      case 2:
        // Validate forms
        for (var i = 0; i < _travelerCount; i++) {
          final form = _travelerForms[i];
          if (form.firstName.text.trim().isEmpty ||
              form.lastName.text.trim().isEmpty ||
              form.email.text.trim().isEmpty) {
            setState(() => _error = 'Please fill in all required fields for traveler ${i + 1}.');
            return;
          }
        }
        _holdAndBook();
    }
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime dt) =>
      '${dt.month}/${dt.day}/${dt.year}';
}

class _TravelerFormControllers {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();

  void dispose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    phone.dispose();
  }
}
