// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:get/get.dart';
// import '../../waste_classification/models/waste_category_model.dart';
//
// class AddWasteCategoryScreen extends StatelessWidget {
//   AddWasteCategoryScreen({super.key});
//
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   /// Add plastic waste category to Firestore
//   Future<void> _addPlasticCategory() async {
//     try {
//       // Create plastic waste category - let Firestore generate ID
//       final plasticCategory = WasteCategory(
//         categoryId: '', // Empty string - Firestore will generate ID
//         name: 'Plastic',
//         description: 'Plastics that are currently accepted by most Malaysian recycling facilities. Malaysia mainly recycles Type 1 (PET), Type 2 (HDPE), and Type 5 (PP) plastics. These plastics are widely used in everyday packaging and have established recycling value.',
//         disposalMethod: 'Step 1: Empty and remove all contents. Step 2: Rinse with clean water to remove food or liquid residue. Step 3: Remove labels or caps if possible (PET bottles). Step 4: Dry completely to prevent contamination. Step 5: Compress/flatten bottles to save space. Step 6: Place into plastic recycling bins or send to recycling centers.',
//         icon: Iconsax.box,
//         color: Colors.blue,
//         basePoints: 50.0,
//         examples: [
//           'Plastic bottles',
//           'Food containers',
//           'Plastic packaging',
//           'Water bottles',
//           'Shampoo bottles',
//           'Detergent containers',
//         ],
//         isRecyclable: true,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       );
//
//       // Add to Firestore - let Firestore generate document ID
//       final docRef = await _firestore
//           .collection('wasteCategories')
//           .add(plasticCategory.toJson());
//
//       Get.snackbar(
//         'Success',
//         'Plastic category added successfully!\nID: ${docRef.id}',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 4),
//       );
//
//       print('Plastic category added to Firestore with ID: ${docRef.id}');
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to add plastic category: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       print('Error adding plastic category: $e');
//     }
//   }
//
//   /// Add multiple RECYCLABLE waste categories at once
//   Future<void> _addMultipleCategories() async {
//     try {
//       final categories = [
//         // Plastic
//         WasteCategory(
//           categoryId: '',
//           name: 'Plastic',
//           description: 'Plastics that are currently accepted by most Malaysian recycling facilities. Malaysia mainly recycles Type 1 (PET), Type 2 (HDPE), and Type 5 (PP) plastics. These plastics are widely used in everyday packaging and have established recycling value.',
//           disposalMethod: 'Step 1: Empty and remove all contents. Step 2: Rinse with clean water to remove food or liquid residue. Step 3: Remove labels or caps if possible (PET bottles). Step 4: Dry completely to prevent contamination. Step 5: Compress/flatten bottles to save space. Step 6: Place into plastic recycling bins or send to recycling centers.',
//           icon: Iconsax.box,
//           color: Colors.blue,
//           basePoints: 50.0,
//           examples: [
//             'Plastic bottles',
//             'Food containers',
//             'Plastic packaging',
//             'Water bottles',
//             'Shampoo bottles',
//             'Detergent containers'
//           ],
//           isRecyclable: true,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         ),
//         // Paper
//         WasteCategory(
//           categoryId: '',
//           name: 'Paper',
//           description: 'Paper products commonly accepted by Malaysian recycling facilities, including newspapers, magazines, books, cardboard, office paper, paper bags, and other clean, dry paper materials suitable for pulping and recovery.',
//           disposalMethod: 'Step 1: Keep paper clean and dry; avoid oil, food stains, or wet tissue. Step 2: Remove plastic coatings, stickers, or non-paper parts where possible (e.g., plastic covers, clips). Step 3: Flatten carton boxes and stack paper neatly to save space. Step 4: Separate paper by type if requested by local recycling or buy-back centres (e.g., cardboard, newspaper, mixed paper). Step 5: Place into designated paper recycling bins, sell to recycling shops, or send to recycling/buy-back centres participating in Malaysia\'s Separation at Source programmes.',
//           icon: Iconsax.document,
//           color: Colors.brown,
//           basePoints: 15.0,
//           examples: [
//             'Newspapers',
//             'Magazines',
//             'Cardboard boxes',
//             'Office paper',
//             'Books',
//             'Paper packaging'
//           ],
//           isRecyclable: true,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         ),
//         // Glass
//         WasteCategory(
//           categoryId: '',
//           name: 'Glass',
//           description: 'Glass bottles and jars made for food and beverages that can be recycled multiple times, including clear, brown, and green container glass commonly accepted by Malaysian recycling and buy-back centres.',
//           disposalMethod: 'Step 1: Only recycle food- and beverage-grade glass bottles and jars; do not include mirrors, window glass, ceramics, or drinking glasses. Step 2: Empty all contents and gently rinse to remove food or liquid residue. Step 3: Remove caps, lids, corks, and non-glass parts; recycle them separately if accepted. Step 4: If possible, separate clear, brown, and green glass according to local centre requirements. Step 5: Place intact glass bottles and jars into designated glass recycling bins or bring them to participating recycling and buy-back centres in Malaysia.',
//           icon: Iconsax.glass,
//           color: Colors.green,
//           basePoints: 10.0,
//           examples: [
//             'Glass bottles',
//             'Glass jars',
//             'Drinking glasses',
//             'Window glass',
//             'Glass containers'
//           ],
//           isRecyclable: true,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         ),
//         // Aluminium
//         WasteCategory(
//           categoryId: '',
//           name: 'Aluminium',
//           description: 'Aluminium products including beverage cans, food cans, aluminium containers, clean foil (if accepted), scrap aluminium parts, and other non-ferrous aluminium items commonly accepted by Malaysian recycling and buy-back centres for their high recyclability and value.',
//           disposalMethod: 'Step 1: Empty all contents from cans and containers. Step 2: Rinse lightly to remove food or beverage residue and allow to dry. Step 3: Remove labels or caps if possible, though many centres accept cans with labels. Step 4: Keep aluminium items clean and free from contamination (avoid mixing with hazardous waste or excessive non-metallic materials). Step 5: Collect and store aluminium cans and scrap without crushing (some centres prefer uncrushed for sorting). Step 6: Bring to designated recycling bins, sell to scrap metal dealers, or deliver to participating buy-back and recycling centres in Malaysia.',
//           icon: Iconsax.cpu,
//           color: Colors.orange,
//           basePoints: 80.0,
//           examples: [
//             'Aluminium drink cans (soft drink, beer)',
//             'Aluminium food cans (soup, canned fruit)',
//             'Aluminium foil (clean, if accepted)',
//             'Aluminium containers and trays',
//             'Aluminium lids and caps',
//             'Scrap aluminium parts (window frames, cookware)',
//             'Aluminium car rims and wheels',
//             'Used beverage cans (UBC)'
//           ],
//           isRecyclable: true,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         ),
//         // Electronic Waste
//         WasteCategory(
//           categoryId: '',
//           name: 'Electronic Waste',
//           description: 'Waste electrical and electronic equipment (WEEE) classified as scheduled waste (SW110) under Malaysian environmental regulations, including mobile phones, computers, laptops, tablets, televisions, printers, circuit boards, small appliances, chargers, cables, and other electronic devices containing valuable recoverable materials (precious metals, copper, plastics) as well as hazardous substances (lead, mercury, cadmium) that require proper handling, collection, and licensed recycling to prevent environmental contamination and enable resource recovery.',
//           disposalMethod: 'Step 1: Do not dispose of e-waste in regular trash bins; e-waste is classified as scheduled waste (SW110) in Malaysia and must be handled through DOE-licensed channels. Step 2: Remove personal data from devices (phones, computers, tablets) by performing factory resets or data wiping before disposal. Step 3: Where safe and practical, remove batteries from devices and dispose of them separately at battery collection points, as they are classified under SW103. Step 4: Store e-waste in a safe, dry location away from moisture and physical damage until ready for disposal. Step 5: Bring e-waste to designated DOE-registered collection centers, retailer take-back programs, recycling events organized by local authorities or DOE, or engage DOE-licensed e-waste contractors for pickup and certified recycling. Step 6: For businesses generating e-waste, register with DOE as a scheduled waste generator, label and store e-waste properly, and report disposal activities via the e-SWIS (Electronic Scheduled Waste Information System) portal.',
//           icon: Iconsax.mobile,
//           color: Colors.purple,
//           basePoints: 70.0,
//           examples: [
//             'Mobile phones and smartphones',
//             'Laptops and tablets',
//             'Desktop computers and monitors',
//             'Televisions and display screens',
//             'Printers, scanners, and copiers',
//             'Computer peripherals (keyboards, mice, cables)',
//             'Chargers and power adapters',
//             'Circuit boards and electronic components',
//             'Small household appliances (fans, rice cookers, kettles)',
//             'Audio equipment (speakers, headphones)'
//           ],
//           isRecyclable: true,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         ),
//         // Battery
//         WasteCategory(
//           categoryId: '',
//           name: 'Battery',
//           description: 'Various types of batteries classified as scheduled waste (SW103) under Malaysian environmental regulations, including household alkaline batteries, rechargeable lithium-ion batteries, lead-acid car batteries, button cells, and other battery types containing hazardous materials that require proper collection and certified recycling to prevent environmental contamination.',
//           disposalMethod: 'Step 1: Do not dispose of batteries in regular trash bins; batteries are classified as hazardous/scheduled waste in Malaysia and must be handled separately. Step 2: Store used batteries in a safe, dry place away from children and flammable materials; tape terminals of lithium or button cell batteries to prevent short circuits. Step 3: Separate battery types if possible (e.g., alkaline, lithium-ion, lead-acid) to facilitate proper recycling. Step 4: Bring batteries to designated collection points such as retail drop-off locations, e-waste collection centres, recycling events, or DOE-licensed scheduled waste facilities. Step 5: For large-format or industrial batteries (e.g., car batteries, EV batteries), engage DOE-licensed contractors for safe transportation and recycling in compliance with Environmental Quality (Scheduled Wastes) Regulations 2005.',
//           icon: Iconsax.battery_charging,
//           color: Colors.red,
//           basePoints: 60.0,
//           examples: [
//             'Alkaline batteries (AA, AAA, C, D sizes)',
//             'Rechargeable batteries (NiMH, NiCd)',
//             'Lithium-ion batteries (phones, laptops, power banks)',
//             'Lead-acid batteries (car, motorcycle, UPS)',
//             'Button cell batteries (watches, hearing aids)',
//             'Lithium coin cells (CR2032, etc.)',
//             'Power tool batteries',
//             'EV and e-bike batteries (large format)'
//           ],
//           isRecyclable: true,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         ),
//         // Cardboard
//         WasteCategory(
//           categoryId: '',
//           name: 'Cardboard',
//           description: 'Corrugated cardboard boxes and packaging materials made from layered paper pulp, including shipping boxes, product packaging, and cardboard cartons commonly accepted by Malaysian recycling and buy-back centres for paper recovery.',
//           disposalMethod: 'Step 1: Remove all tape, labels, plastic wrapping, staples, and non-cardboard packaging materials where possible. Step 2: Keep cardboard clean and dry; do not recycle cardboard contaminated with grease, oil, food waste, or liquids (e.g., wet pizza boxes). Step 3: Flatten and fold boxes to reduce volume and save storage and transportation space. Step 4: Separate corrugated cardboard (thick, layered boxes) from thin paperboard (e.g., cereal boxes) if required by local centres. Step 5: Place flattened cardboard into designated recycling bins or deliver to participating recycling and buy-back centres in Malaysia.',
//           icon: Iconsax.box,
//           color: Colors.brown[800]!,
//           basePoints: 18.0,
//           examples: [
//             'Corrugated shipping boxes (e-commerce, courier)',
//             'Product packaging boxes (electronics, appliances)',
//             'Cardboard cartons (food, beverage packaging)',
//             'Carton boxes from supermarkets',
//             'Flat-pack furniture boxes',
//             'Cardboard tubes (paper towel, wrapping paper cores)',
//             'Clean pizza boxes (if not greasy)',
//             'Egg cartons (paper/cardboard type)'
//           ],
//           isRecyclable: true,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         ),
//         // Textile
//         WasteCategory(
//           categoryId: '',
//           name: 'Textile',
//           description: 'Clothing, fabric items, footwear, and textile-based products that can be donated, reused, repurposed, or recycled through Malaysia\'s textile collection initiatives such as Kloth Cares, Life Line Clothing, charity organisations, and other fabric recycling programmes to divert textile waste from landfills and incinerators while supporting circular economy principles.',
//           disposalMethod: 'Step 1: Clean and dry items before donation or recycling—machine wash is sufficient, no need to iron. Step 2: Place items in a clean plastic bag or sack (package size within 50cm x 55cm, maximum 7kg per bag for collection bin compatibility). Step 3: Acceptable items include clothing (men\'s, women\'s, children\'s, including undergarments), footwear, bags, household textiles (bed sheets, towels, curtains, blankets, pillowcases), fabric scraps, and accessories (scarves, belts, costume jewellery). Step 4: Non-acceptable items typically include wet or mouldy fabric, contaminated textiles, mattresses, or items mixed with non-textile materials. Step 5: Drop off at designated fabric recycling bins (e.g., Kloth Cares, Life Line Clothing locations), charity collection centres (e.g., Salvation Army, Community Recycle for Charity, Kedai BLESS), or participate in textile recycling events organised by local councils, universities, or NGOs in Malaysia.',
//           icon: Iconsax.brush,
//           color: Colors.pink,
//           basePoints: 20.0,
//           examples: [
//             'Old and preloved clothing (all types, including undergarments)',
//             'Bed sheets and pillowcases',
//             'Towels and blankets',
//             'Curtains and drapes',
//             'Shoes and footwear',
//             'Bags (handbags, backpacks, luggage)',
//             'Fabric scraps and sewing remnants',
//             'Clothing accessories (scarves, belts, hats)',
//             'Children\'s soft toys (fabric-based)',
//             'Tablecloths and napkins'
//           ],
//           isRecyclable: true,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         ),
//       ];
//
//       // Add all categories to Firestore with auto-generated IDs
//       final batch = _firestore.batch();
//
//       for (final category in categories) {
//         final docRef = _firestore.collection('wasteCategories').doc();
//         batch.set(docRef, category.toJson());
//       }
//
//       await batch.commit();
//
//       Get.snackbar(
//         'Success',
//         'All ${categories.length} RECYCLABLE waste categories added successfully with auto-generated IDs!',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 4),
//       );
//
//       print('All RECYCLABLE waste categories added to Firestore with auto-generated IDs');
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to add categories: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       print('Error adding categories: $e');
//     }
//   }
//
//   /// Add NOT RECYCLABLE waste categories
//   Future<void> _addNotRecyclableCategories() async {
//     try {
//       final categories = [
//         // 1. Non-Recyclable Plastic
//         WasteCategory(
//           categoryId: '',
//           name: 'Non-Recyclable Plastic',
//           description: 'Plastics that are currently not accepted by most Malaysian recycling facilities, including multi-layer packaging, soft plastics, polystyrene foam, and contaminated plastic items that cannot be processed through standard recycling streams.',
//           disposalMethod: 'Step 1: Separate non-recyclable plastics from recyclable materials (PET, HDPE, PP) to avoid contaminating the recycling stream. Step 2: Minimize usage by choosing reusable or recyclable alternatives. Step 3: Place into designated general waste bins, not recycling bins. Step 4: Do not burn plastic waste at home due to toxic emissions.',
//           icon: Iconsax.close_circle,
//           color: Colors.grey[700]!,
//           basePoints: 0.0,
//           examples: [
//             'Multi-layer laminated packaging (chip bags, coffee pouches)',
//             'Single-use plastic cutlery and straws',
//             'Squeeze tubes (toothpaste, cosmetic tubes)',
//             'Polystyrene foam (styrofoam food containers, packaging)',
//             'Soft plastic bags and films',
//             'Plastic wrappers and sachets',
//             'Contaminated or dirty plastic packaging',
//             'Mixed-material packaging (plastic-metal composites)'
//           ],
//           isRecyclable: false,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         ),
//
//         // 2. Non-Recyclable Paper
//         WasteCategory(
//           categoryId: '',
//           name: 'Non-Recyclable Paper',
//           description: 'Paper products that cannot be recycled in Malaysia due to contamination, coating, or composition, including waxed paper, laminated paper, thermal paper, and paper contaminated with food or chemicals.',
//           disposalMethod: 'Step 1: Do not place contaminated or coated paper into recycling bins. Step 2: Separate from clean recyclable paper to prevent contamination. Step 3: Dispose of in general waste bins. Step 4: Consider reducing usage of disposable paper cups and switching to reusable alternatives.',
//           icon: Iconsax.document_filter,
//           color: Colors.brown[400]!,
//           basePoints: 0.0,
//           examples: [
//             'Paper cups (with plastic or wax coating)',
//             'Thermal paper (receipts, fax paper)',
//             'Waxed paper and parchment paper',
//             'Laminated paper and coated cardboard',
//             'Carbon paper',
//             'Tissue paper and paper towels (used)',
//             'Food-contaminated paper packaging',
//             'Stickers and sticky notes (with adhesive backing)'
//           ],
//           isRecyclable: false,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         ),
//
//         // 3. Non-Recyclable Glass
//         WasteCategory(
//           categoryId: '',
//           name: 'Non-Recyclable Glass',
//           description: 'Glass items that are not accepted by Malaysian glass recycling programs, including light bulbs, fluorescent lamps, mirrors, ceramics, and heat-resistant glass with different melting points than container glass.',
//           disposalMethod: 'Step 1: Wrap broken glass carefully in newspaper or cardboard to prevent injury. Step 2: Separate from recyclable glass bottles and jars. Step 3: Fluorescent lamps and CFL bulbs contain mercury and should be treated as hazardous waste—bring to e-waste collection centers. Step 4: Place wrapped items in general waste bins or follow local hazardous waste guidelines for lamps.',
//           icon: Iconsax.lamp_on,
//           color: Colors.amber[700]!,
//           basePoints: 0.0,
//           examples: [
//             'Light bulbs (incandescent bulbs)',
//             'Fluorescent lamps and tubes',
//             'CFL (Compact Fluorescent Lamp) bulbs',
//             'LED bulbs (contain electronic components)',
//             'Mirrors and reflective glass',
//             'Ceramics and porcelain',
//             'Pyrex and heat-resistant glass',
//             'Window glass and auto glass',
//             'Drinking glasses and glassware (broken)'
//           ],
//           isRecyclable: false,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         ),
//
//         // 4. Food Waste
//         WasteCategory(
//           categoryId: '',
//           name: 'Food Waste',
//           description: 'Organic waste from food preparation and consumption, including fruit and vegetable scraps, cooked food leftovers, meat, fish, bones, and other biodegradable food materials. In Malaysia, food waste makes up a significant portion of municipal solid waste.',
//           disposalMethod: 'Step 1: Separate food waste from recyclables and general waste. Step 2: If available, use designated food waste bins or compost at home. Step 3: Drain excess liquids before disposal. Step 4: Wrap in newspaper if required. Step 5: Place into organic waste bins or general waste bins if no separate collection is available.',
//           icon: Iconsax.trash,
//           color: Colors.green[600]!,
//           basePoints: 0.0,
//           examples: [
//             'Fruit and vegetable scraps and peels',
//             'Cooked food leftovers and spoiled food',
//             'Rice, noodles, and bread',
//             'Meat, fish, and bones',
//             'Eggshells and dairy products',
//             'Coffee grounds and tea bags',
//             'Food-soiled paper napkins',
//             'Expired or spoiled groceries'
//           ],
//           isRecyclable: false,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         ),
//
//         // 5. Contaminated / Soiled Items
//         WasteCategory(
//           categoryId: '',
//           name: 'Contaminated Items',
//           description: 'Items contaminated with food, grease, bodily fluids, chemicals, or other substances that make them unsuitable for recycling in Malaysia, including greasy packaging, used hygiene products, and heavily soiled materials.',
//           disposalMethod: 'Step 1: Do not place contaminated items into recycling bins. Step 2: Wrap heavily soiled items in newspaper or plastic bags before disposal. Step 3: Place into general waste bins. Step 4: Try to minimize contamination—scrape off excess food from packaging before deciding if recyclable.',
//           icon: Iconsax.danger,
//           color: Colors.red[400]!,
//           basePoints: 0.0,
//           examples: [
//             'Greasy or food-soiled pizza boxes',
//             'Used paper napkins and tissues',
//             'Food-contaminated paper packaging',
//             'Used diapers and sanitary products',
//             'Pet waste and kitty litter',
//             'Cigarette butts',
//             'Contaminated plastic containers (not rinsed)',
//             'Medical waste (bandages, cotton swabs)'
//           ],
//           isRecyclable: false,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         ),
//
//         // 6. General Waste / Residual Waste
//         WasteCategory(
//           categoryId: '',
//           name: 'General Waste',
//           description: 'Mixed waste materials that cannot be recycled, composted, or classified as hazardous waste in Malaysia, including broken household items, damaged goods, and materials with no recovery value, typically sent to landfills.',
//           disposalMethod: 'Step 1: Separate recyclables, e-waste, batteries, and special waste before placing items into general waste. Step 2: Place broken or damaged items that cannot be repaired into general waste bins. Step 3: Minimize generation by choosing reusable products. Step 4: Follow local waste collection schedules.',
//           icon: Iconsax.trash,
//           color: Colors.grey[600]!,
//           basePoints: 0.0,
//           examples: [
//             'Broken ceramics and dishware',
//             'Damaged household items (not repairable)',
//             'Non-recyclable packaging materials',
//             'Rubber products and erasers',
//             'Broken toys (mixed materials)',
//             'Worn-out shoes (non-donatable)',
//             'Single-use disposable items',
//             'Vacuum cleaner dust and dirt'
//           ],
//           isRecyclable: false,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         ),
//       ];
//
//       // Add all NOT RECYCLABLE categories to Firestore
//       final batch = _firestore.batch();
//
//       for (final category in categories) {
//         final docRef = _firestore.collection('wasteCategories').doc();
//         batch.set(docRef, category.toJson());
//       }
//
//       await batch.commit();
//
//       Get.snackbar(
//         'Success',
//         'All ${categories.length} NOT RECYCLABLE waste categories added successfully!',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 4),
//       );
//
//       print('All NOT RECYCLABLE waste categories added to Firestore');
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to add NOT RECYCLABLE categories: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       print('Error adding NOT RECYCLABLE categories: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Waste Categories'),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Add Plastic Category Button
//             Card(
//               elevation: 4,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     const Icon(Iconsax.box, size: 50, color: Colors.blue),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Plastic Waste Category',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'Add plastic waste category with examples like bottles, containers, and packaging materials.',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: _addPlasticCategory,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//                       ),
//                       child: const Text('Add Plastic Category'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // Add All RECYCLABLE Categories Button
//             Card(
//               elevation: 4,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     const Icon(Iconsax.category, size: 50, color: Colors.green),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'All RECYCLABLE Waste Categories',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'Add multiple recyclable waste categories including plastic, paper, glass, aluminium, electronic waste, batteries, cardboard, and textiles.',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: _addMultipleCategories,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//                       ),
//                       child: const Text('Add RECYCLABLE Categories (8 Categories)'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // Add NOT RECYCLABLE Categories Button
//             Card(
//               elevation: 4,
//               color: Colors.grey[100],
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     Icon(Iconsax.close_circle, size: 50, color: Colors.grey[700]),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'NOT RECYCLABLE Waste Categories',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'Add non-recyclable waste categories including multi-layer plastic, paper cups, light bulbs, food waste, contaminated items, and general waste.',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: _addNotRecyclableCategories,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.grey[700],
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//                       ),
//                       child: const Text('Add NOT RECYCLABLE Categories (6 Categories)'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // Information Card
//             Card(
//               color: Colors.blue[50],
//               child: const Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'About Waste Categories',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'Waste categories help users identify and properly dispose of different types of waste. '
//                           'Each category includes examples, disposal methods, and reward points for recycling. '
//                           'Document IDs are automatically generated by Firestore.\n\n'
//                           '• RECYCLABLE: Can be processed and reused (basePoints > 0)\n'
//                           '• NOT RECYCLABLE: Cannot be recycled (basePoints = 0)',
//                       style: TextStyle(fontSize: 14),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
