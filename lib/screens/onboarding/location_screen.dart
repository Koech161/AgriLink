// lib/screens/onboarding/location_screen.dart
import 'package:agrilink/screens/auth/registration_screen.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/location_service.dart';
import '../../widgets/onboarding/progress_indicator.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_button.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final LocationService _locationService = LocationService();

  String? _selectedCounty;
  String? _selectedSubCounty;
  String? _selectedWard;

  bool _isLoadingLocation = false;

  /// County → Subcounties → Wards
  final Map<String, Map<String, List<String>>> countyData = {
    'Uasin Gishu': {
      'Ainabkoi': [
        'Ainabkoi/Olare',
        'Kapsoya',
        'Kaptagat',
      ],
      'Kapsaret': [
        'Simat/Kapseret',
        'Kipkenyo',
        'Ngeria',
        'Megun',
        'Langas',
      ],
      'Kesses': [
        'Racecourse',
        'Cheptiret/Kipchamo',
        'Tulwet/Chuiyat',
        'Tarakwa',
      ],
      'Moiben': [
        'Kimumu',
        'Moiben',
        'Sergoit',
        'Tembelio',
        'Karuna/Meibeki',
      ],
      'Soy': [
        'Soy',
        'Ziwa',
        'Segero/Barsombe',
        'Kipsomba',
        'Moi\'s Bridge',
        'Kapkures',
        'Kuinet/Kapsomba',
      ],
      'Turbo': [
        'Tapsagoi',
        'Ngenyilel',
        'Kamagut',
        'Kiplombe',
        'Kapsaos',
        'Huruma',
      ],
    },

    'Trans Nzoia': {
      'Cherangany': [
        'Sitatunga',
        'Makutano',
        'Kaplamai',
        'Motosiet',
        'Chepsiro/Kiptoror',
        'Sinyerere',
      ],
      'Kiminini': [
        'Kiminini',
        'Waitaluk',
        'Sirende',
        'Hospital',
        'Sikhendu',
        'Nabiswa',
      ],
      'Saboti': [
        'Saboti',
        'Matisi',
        'Tuwani',
        'Machewa',
        'Kinyoro',
      ],
      'Kwanza': [
        'Kapomboi',
        'Bidii',
        'Keiyo',
        'Kwanza',
      ],
      'Endebess': [
        'Chepchoina',
        'Endebess',
        'Matumbei',
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final UserType? userType = ModalRoute.of(context)?.settings.arguments as UserType?;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Your Location'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            OnboardingProgressIndicator(currentStep: 2, totalSteps: 4),
            SizedBox(height: 32),

            Text(
              'Where are you located?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 8),

            Text(
              'This helps us connect you with nearby services',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),

            SizedBox(height: 32),

            // Auto-detect button
            CustomButton(
              text: _isLoadingLocation ? 'Detecting...' : 'Auto-detect Location',
              onPressed: _detectLocation,
              backgroundColor: AppColors.lightGreen,
              foregroundColor: AppColors.primaryGreen,
              icon: _isLoadingLocation
                  ? CircularProgressIndicator(color: AppColors.primaryGreen, strokeWidth: 2)
                  : Icon(Icons.location_searching),
            ),

            SizedBox(height: 16),
            Text('or select manually', style: TextStyle(color: AppColors.textSecondary)),

            SizedBox(height: 24),

            // Dropdowns scroll area
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // COUNTY
                    _buildDropdown(
                      label: 'County',
                      value: _selectedCounty,
                      items: countyData.keys.toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCounty = value;
                          _selectedSubCounty = null;
                          _selectedWard = null;
                        });
                      },
                    ),

                    SizedBox(height: 16),

                    // SUB-COUNTY
                    if (_selectedCounty != null)
                      _buildDropdown(
                        label: 'Sub-County',
                        value: _selectedSubCounty,
                        items: countyData[_selectedCounty]!.keys.toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSubCounty = value;
                            _selectedWard = null;
                          });
                        },
                      ),

                    SizedBox(height: 16),

                    // WARD
                    if (_selectedSubCounty != null)
                      _buildDropdown(
                        label: 'Ward',
                        value: _selectedWard,
                        items: countyData[_selectedCounty]![_selectedSubCounty]!,
                        onChanged: (value) {
                          setState(() {
                            _selectedWard = value;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),

            // Continue button
            CustomButton(
              text: 'Continue',
              onPressed: _selectedCounty != null && _selectedSubCounty != null && _selectedWard != null
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistrationScreen(
                          userType: userType!,
                          county: _selectedCounty!,
                          subCounty: _selectedSubCounty!,
                          ward: _selectedWard!,
                        ),
                      ),
                    );
                  }
                : null,
              backgroundColor:
                  (_selectedCounty != null && _selectedSubCounty != null && _selectedWard != null)
                      ? AppColors.primaryGreen
                      : Colors.grey,
              foregroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds dropdown widget
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: SizedBox(),
            items: items.map((item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  /// Auto-detect location (mock)
  Future<void> _detectLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      await _locationService.getCurrentLocation();
      await Future.delayed(Duration(seconds: 2)); // simulate geocoding

      setState(() {
        _selectedCounty = 'Uasin Gishu';
        _selectedSubCounty = 'Turbo';
        _selectedWard = 'Huruma';
        _isLoadingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location detected!'), backgroundColor: AppColors.primaryGreen),
      );
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
