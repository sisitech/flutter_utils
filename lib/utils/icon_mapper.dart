import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const Map<String, IconData> defaultIconMapper = {
  // ---------
  'Untagged': Icons.category,
  'Household': Icons.house,
  // ---------
  'Shopping': Icons.shopping_basket,
  'Wifi': Icons.wifi,
  'Rent': Icons.home,
  'Housekeeping': FontAwesomeIcons.houseChimneyCrack,
  'Energy': Icons.electric_bolt,
  'Construction': Icons.plumbing,
  'Water': Icons.water_drop,
  // ---------
  'Entertainment': Icons.tv,
  // ---------
  'Cable': Icons.tv,
  'Streaming': Icons.tablet,
  'Cinema': FontAwesomeIcons.ticket,
  'Music': Icons.headphones,
  'Social': Icons.group,
  'Sports': Icons.sports_soccer,
  'Vacation': Icons.hotel,
  // ---------
  // 'Shopping': Icons.shopping_basket,
  // ---------
  'Supermarket': Icons.shopping_basket,
  'Naivas': Icons.shopping_basket,
  'Quickmart': Icons.shopping_basket,
  'Carrefour': Icons.shopping_basket,
  //---
  'Online': Icons.shopping_cart,
  'Jumia': Icons.shopping_cart,
  'Jiji': Icons.shopping_cart,
  'Aliexpress': Icons.shopping_cart,
  //---
  'Local': Icons.store,
  'Mall': FontAwesomeIcons.building,
  'Shops': Icons.store,
  'Gikomba': Icons.store,
  'Attire': FontAwesomeIcons.shirt,
  'Books': FontAwesomeIcons.book,
  // ---------
  'Transport': FontAwesomeIcons.car,
  // ---------
  'Fuel': Icons.gas_meter,
  'Total Energies': Icons.gas_meter,
  'Shell': Icons.gas_meter,
  'Rubis': Icons.gas_meter,
  'Oilibya': Icons.gas_meter,
  //--
  'Taxi': Icons.local_taxi,
  'Uber': FontAwesomeIcons.uber,
  'Bolt': Icons.local_taxi,
  //--
  'Public': FontAwesomeIcons.bus,
  //---
  'Flight': Icons.airplanemode_active,
  'Kenya Airways': Icons.airplanemode_active,
  'Jambojet': Icons.airplanemode_active,
  'Fly540': Icons.airplanemode_active,
  'Delivery': Icons.delivery_dining,
  'Vehicle': Icons.car_repair,
  // ---------
  'Food & Drinks': FontAwesomeIcons.bowlFood,
  'Food & Dining': FontAwesomeIcons.bowlFood,
  // ---------
  'Restaurant': Icons.restaurant_rounded,
  'Meal': Icons.restaurant_menu,
  'Groceries': Icons.shopping_bag,
  'Drinks': FontAwesomeIcons.wineBottle,
  'Fast Food': Icons.fastfood,
  // ---------
  'Personal': Icons.person,
  // ---------
  'Self-care': FontAwesomeIcons.spa,
  'Goodwill': Icons.handshake,
  'Devices': Icons.phone_android,
  'Communication': Icons.call,
  // ---------
  'Family & Friends': Icons.people,
  // ---------
  'Family': Icons.family_restroom,
  'Friends': Icons.people,
  'Bae': FontAwesomeIcons.heart,
  'Acquaintance': Icons.person,
  // ---------
  'Finance': Icons.payments,
  // ---------
  'Loan': FontAwesomeIcons.creditCard,
  'Tala': FontAwesomeIcons.creditCard,
  'Branch': FontAwesomeIcons.creditCard,
  'Student Loan': FontAwesomeIcons.creditCard,
  'M-kopa': FontAwesomeIcons.creditCard,
  'Fuliza': FontAwesomeIcons.creditCard,
  'Income': Icons.call_received,
  'Investment': FontAwesomeIcons.coins,
  'Savings': Icons.savings,
  'Insurance': Icons.savings_outlined,
  //---
  'Money Transfers': FontAwesomeIcons.moneyBillTransfer,
  'KCB': FontAwesomeIcons.buildingColumns,
  'Equity': FontAwesomeIcons.buildingColumns,
  'Sidian': FontAwesomeIcons.buildingColumns,
  'Family Bank': FontAwesomeIcons.buildingColumns,
  'Co-Op bank': FontAwesomeIcons.buildingColumns,
  'Stanbic': FontAwesomeIcons.buildingColumns,
  'I&M': FontAwesomeIcons.buildingColumns,
  'Absa': FontAwesomeIcons.buildingColumns,
  'SChartered': FontAwesomeIcons.buildingColumns,
  // ---------
  'Official': Icons.work,
  // ---------
  'IT': Icons.computer,
  'Business': Icons.business,
  'Government': Icons.flag,
  'Legal': FontAwesomeIcons.scaleUnbalanced,
  // ---------
  'Education': Icons.school,
  // ---------
  'School Fees': Icons.payments,
  'Stationery': FontAwesomeIcons.penRuler,
  // ---------
  'Health': Icons.local_hospital,
  'Health & Fitness': Icons.local_hospital,
  // ---------
  'Medicare': FontAwesomeIcons.pills,
  'Hospital': FontAwesomeIcons.truckMedical,
  //----
  'Apps': FontAwesomeIcons.googlePlay,

  // ---- tags
  'Safaricom': Icons.wifi,
  'Zuku': Icons.wifi,
  'Faiba': Icons.wifi,
  'Cleaning': FontAwesomeIcons.broom,
  'Clothes': FontAwesomeIcons.shirt,
  'Cyber': Icons.language,
  'Shoes': FontAwesomeIcons.shoePrints,
  'Accessories': Icons.watch,
  'Selfcare': FontAwesomeIcons.faceSmileBeam,
  'Salon': Icons.face_3,
  'Spa': FontAwesomeIcons.spa,
  'Nails': Icons.back_hand,
  'Products': Icons.water_drop,
  'Treats': FontAwesomeIcons.heart,
  'Charity': FontAwesomeIcons.handHoldingHeart,
  'Faith': FontAwesomeIcons.personPraying,
  'Airtime': Icons.phone,
  'Bundles': Icons.network_cell,
  'Matatu': FontAwesomeIcons.vanShuttle,
  'Tuktuk': Icons.train,
  'SGR': FontAwesomeIcons.train,
  'Boda': Icons.motorcycle,
  'Bus': FontAwesomeIcons.bus,
  'Parking': FontAwesomeIcons.squareParking,
  'Expressway': FontAwesomeIcons.road,
  'FedEx': FontAwesomeIcons.fedex,
  'Fargo': FontAwesomeIcons.truck,
  'Glovo': Icons.delivery_dining,
  'Maintenance': Icons.plumbing,
  'Repair': Icons.car_repair,
  'Pizza': FontAwesomeIcons.pizzaSlice,
  'Ice Cream': FontAwesomeIcons.iceCream,
  'Chicken': FontAwesomeIcons.drumstickBite,
  'Burgers': FontAwesomeIcons.burger,
  'Meat': FontAwesomeIcons.cow,
  'Snacks': FontAwesomeIcons.cookieBite,
  'Cereals': FontAwesomeIcons.wheatAwn,
  'Dairy': FontAwesomeIcons.cow,
  'Vegetables': FontAwesomeIcons.carrot,
  'Liquor': FontAwesomeIcons.whiskeyGlass,
  'Organic': FontAwesomeIcons.glassWater,
  'Cafe': FontAwesomeIcons.mugSaucer,
  'Java': FontAwesomeIcons.java,
  'Artcaffe': Icons.coffee,
  'Bakery': Icons.cake,
  'Lunch': Icons.restaurant_menu,
  'Breakfast': Icons.restaurant_menu,
  'Dinner': Icons.restaurant_menu,
  'Supper': Icons.restaurant_menu,
  'Tea Break': Icons.restaurant_menu,
  'Hotel': FontAwesomeIcons.airbnb,
  'Beach': Icons.beach_access,
  'Park': Icons.park,
  'Tours': Icons.hiking_rounded,
  'Baecation': FontAwesomeIcons.airbnb,
  'Museum': Icons.museum, 'Netflix': Icons.ondemand_video,
  'Showmax': Icons.ondemand_video,
  'Hulu': Icons.ondemand_video,
  'Amazon Prime': FontAwesomeIcons.amazon,
  'Amazon': FontAwesomeIcons.amazon,
  'HBO': Icons.ondemand_video,
  'Viusasa': Icons.ondemand_video,
  'DSTV': Icons.tv,
  'GoTV': Icons.tv,
  'StarTimes': Icons.tv, 'Club': Icons.liquor,
  'Party': FontAwesomeIcons.users,
  'Stadium': Icons.stadium,
  'Family Gathering': Icons.family_restroom,
  'Date': FontAwesomeIcons.heart,
  'Hangout': Icons.group, 'Spotify': FontAwesomeIcons.spotify,
  'Concert': FontAwesomeIcons.ticket,
  'Records': FontAwesomeIcons.recordVinyl,
  'Betting': Icons.payment,
  'Live Games': Icons.sports_score,
  'KPLC': Icons.lightbulb,
  'Solar': Icons.sunny,
  'Gas': Icons.propane_tank,
  'Charcoal': Icons.fireplace,
  'Paraffin': Icons.water_drop,
  'Toiletries': Icons.wash,
  'Furniture': Icons.chair,
  'Electronics': Icons.tv,
  'Nanny': Icons.child_care,
  'Labour': Icons.person,
  'Gardener': Icons.nature,
  'Security': Icons.lock,
  'Garbage': Icons.delete,
  'Plumbing': Icons.plumbing,
  'Renovation': Icons.format_paint,
  'Laundry': FontAwesomeIcons.shirt,
  'Mother': Icons.elderly_woman,
  'Father': Icons.elderly,
  'Brother': Icons.man,
  'Sister': Icons.woman,
  'Relative': FontAwesomeIcons.person,
  'Daughter': Icons.girl,
  'Son': Icons.boy,
  'Gift': Icons.card_giftcard,
  'Rennovation': FontAwesomeIcons.house,
  'Materials': FontAwesomeIcons.hammer,
  'Tech': FontAwesomeIcons.microchip,
  'Work': FontAwesomeIcons.briefcase,
  'Salary': FontAwesomeIcons.moneyBillWave,
  'Allowance': FontAwesomeIcons.moneyBill1Wave,
  'Side Hustle': FontAwesomeIcons.businessTime,
  'Voucher': FontAwesomeIcons.ticket,
  'Promotion': FontAwesomeIcons.ticket,
  'Send Money': Icons.person,
  'Receive Money': Icons.call_received,
  'Deposit Mshwari': Icons.savings,
  'Withdrawal Mshwari': Icons.savings_outlined,
  'Paybill': Icons.business,
  'Buy Goods': Icons.store,
  'Pochi La Biashara': Icons.account_box,
  'Buy Airtime': Icons.call,
  'Buy Airtime Another': Icons.call,
  'Withdrawal': Icons.call_made,
  'W': Icons.call_made,
  'D': Icons.call_received,
};
