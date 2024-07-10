import 'package:flutter/material.dart';

final List<IconData> icons = [
  Icons.category,
  Icons.fastfood,
  Icons.movie,
  Icons.work,
  Icons.home,
  
  Icons.fitness_center,
  Icons.shopping_cart,  // Shopping
  Icons.local_gas_station,  // Transportation
  Icons.school,  // Education
  Icons.healing,  // Health
  Icons.travel_explore,  // Travel
  Icons.spa,  // Personal Care
  Icons.devices,  // Electronics
  Icons.pets,  // Pet Care
  Icons.local_taxi,  // Taxi
  Icons.account_balance_wallet,  // Wallet
  Icons.card_giftcard,  // Gifts
  Icons.favorite,  // Charity
  Icons.account_balance,  // Bank Fees
  Icons.receipt,  // Bills
  Icons.store,  // Groceries
  Icons.child_care,  // Child Care
  Icons.local_hospital,  // Medical
  Icons.attach_money,  // Savings
  Icons.business_center,  // Business
  Icons.library_books,  // Books
  Icons.music_note,  // Music
  Icons.local_drink,  // Drinks
  Icons.local_bar,  // Bars
  Icons.car_repair,  // Car Maintenance
  Icons.directions_car,  // Car Loan
  Icons.airplanemode_active,  // Airplane
  Icons.house_siding,  // Mortgage
  Icons.phone,  // Phone Bill
  Icons.wifi,  // Internet
  Icons.local_hotel,  // Hotel
  Icons.directions_bus,  // Bus
  Icons.beach_access,  // Vacation
  Icons.weekend,  // Furniture
  Icons.attach_file,  // Miscellaneous

  
  Icons.attach_money,  // Salary
  Icons.business,  // Business Income
  Icons.monetization_on,  // Investment Income
  Icons.card_giftcard,  // Gifts Received
  Icons.savings,  // Savings Interest
  Icons.credit_card,  // Refunds
  Icons.trending_up,  // Stock Market Gains
  Icons.stars,  // Awards
  Icons.volunteer_activism,  // Donations Received
];


final List<String> months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];
int year = DateTime.now().year;

final List<String> years = List.generate(year - 2015+1, (index) => (2015+index).toString());
