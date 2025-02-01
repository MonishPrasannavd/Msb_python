import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:msb_app/providers/master/master_provider.dart';
import 'package:msb_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:msb_app/models/msb_country.dart';
import 'package:msb_app/models/msb_state.dart';

class CountryStateDropdown extends StatefulWidget {
  const CountryStateDropdown({super.key});

  @override
  CountryStateDropdownState createState() => CountryStateDropdownState();
}

class CountryStateDropdownState extends State<CountryStateDropdown> {
  MsbCountry? selectedCountry;
  MsbState? selectedState;

  @override
  Widget build(BuildContext context) {
    final masterProvider = Provider.of<MasterProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final countries = masterProvider.countries;
    final states = masterProvider.states;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country Dropdown
        DropdownSearch<MsbCountry>(
          compareFn: (item1, item2) => item1.id == item2.id,
          itemAsString: (item) => item.name ?? '',
          items: (f, cs) => countries,
          onChanged: (MsbCountry? country) {
            setState(() {
              selectedCountry = country;
              selectedState = null; // Reset state when country changes
              userProvider.selectedCountry = country;
            });
          },
          selectedItem: selectedCountry,
          validator: (value) => value == null ? 'Country is required' : null,
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                labelText: "Search Country",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
            ),
          ),
          decoratorProps: const DropDownDecoratorProps(
              decoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: 'Select Country')),
        ),
        const SizedBox(height: 16),
        // State Dropdown
        DropdownSearch<MsbState>(
          compareFn: (item1, item2) => item1.id == item2.id,
          itemAsString: (item) => item.name ?? '',
          items: (f, cs) => selectedCountry != null
              ? states
                  .where((state) => state.countryId == selectedCountry!.id)
                  .toList()
              : [],
          onChanged: (MsbState? state) {
            setState(() {
              selectedState = state;
              userProvider.selectedState = state;
            });
          },
          selectedItem: selectedState,
          validator: (value) => value == null ? 'State is required' : null,
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                labelText: "Search State",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
            ),
          ),
          decoratorProps: const DropDownDecoratorProps(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Select State',
            ),
          ),
        ),
      ],
    );
  }
}
