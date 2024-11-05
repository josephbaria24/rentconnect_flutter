// ignore_for_file: prefer_const_constructors, prefer_final_fields, unused_import, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:typed_data';
import 'package:rentcon/pages/agreementDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:rentcon/config.dart';
import 'package:rentcon/models/property.dart';
import 'package:rentcon/navigation_menu.dart';
import 'package:rentcon/pages/global_loading_indicator.dart';
import 'package:rentcon/pages/landlords/AddingRoom.dart';
import 'package:rentcon/pages/landlords/addListing.dart';
import 'package:rentcon/pages/landlords/detailedProperty.dart';
import 'package:rentcon/pages/landlords/manageProperty.dart';
import 'package:rentcon/pages/landlords/roomCreation.dart';
import 'package:rentcon/pages/landlords/updateListing.dart';
import 'package:rentcon/pages/landlords/widgets/billsBoxes.dart';
import 'package:rentcon/pages/landlords/widgets/copyOfpaymentdetails.dart';
import 'package:rentcon/pages/landlords/widgets/editProperty.dart';
import 'package:rentcon/pages/landlords/widgets/hasInquiry.dart';
import 'package:rentcon/pages/landlords/widgets/helpScreen.dart';
import 'package:rentcon/pages/landlords/widgets/no_inquiries_widget.dart';
import 'package:rentcon/pages/landlords/widgets/occupant_list_widget.dart';
import 'package:rentcon/pages/landlords/widgets/payment_details.dart';
import 'package:rentcon/pages/landlords/widgets/reservation_details.dart';
import 'package:rentcon/pages/landlords/widgets/reserver_list.dart';
import 'package:rentcon/pages/profile.dart';
import 'package:rentcon/pages/toast.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:rentcon/pages/propertyDetailPage.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'PaymentLandlordSide.dart';
import 'package:saver_gallery/saver_gallery.dart';

class CurrentListingPage extends StatefulWidget {
  final String token;


  const CurrentListingPage({required this.token, Key? key}) : super(key: key);

  @override
  State<CurrentListingPage> createState() => _CurrentListingPageState();
}

class _CurrentListingPageState extends State<CurrentListingPage> {
  late String userId;
  late String email;
  late String roomId;
  List<dynamic>? items;
  String? responseBody;
  DateTime? _selectedDueDate;
  DateTime? _selectedStartDate;
  Map<String, List<dynamic>> propertyRooms = {};
  Map<String, List<dynamic>> propertyInquiries = {};
  Map<String, dynamic> userProfiles = {};
  Map<String, dynamic> profilePic= {};
  Map<String, dynamic>? inquiry = {};
  String? selectedUserId; 
  Map<String, dynamic> room = {};


  final ThemeController _themeController = Get.find<ThemeController>();
  bool _loading = true; // Added state for loading
  bool showAllRooms = false;
  late String landlordId;
  int _currentMonthIndex = 0; // Track the current month index
   final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  late PageController _monthPageController;
  late ToastNotification toastNotification;
  late ScrollController tab2ScrollController;
  String? roomID;


  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id']?.toString() ?? 'unknown id';
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    getPropertyList(userId);
    _loading = true;
    fetchRoomInquiries;
     _monthPageController = PageController(initialPage: _currentMonthIndex); // Initialize the PageController
      _fetchProofForAllMonths(room['_id'], widget.token); 
    tab2ScrollController = ScrollController();
     if (mounted) {
    toastNotification = ToastNotification(context);
  }
     // Fetch property list first
  getPropertyList(userId).then((_) {
    // Once property list is fetched, initialize roomId
    initializeRoomId();
    // Now it's safe to call fetchRoomInquiries with roomId
    if (roomId.isNotEmpty) {
      fetchRoomInquiries(roomId);
    }
  });
  }


  Color getStatusColor(String? status) {
  switch (status) {
    case 'Waiting':
      return const Color.fromARGB(255, 255, 196, 0); // Yellow for Waiting
    case 'Approved':
      return Colors.green; // Green for Approved
    case 'Rejectesd':
      return Colors.red; // Red for Rejected
    default:
      return _themeController.isDarkMode.value
          ? Colors.grey // Default color for dark mode
          : Colors.black; // Default color for light mode
  }
}

  @override
  void dispose() {
    tab2ScrollController.dispose(); // Dispose the controller
    super.dispose();
  }

Future<String?> getProofOfPaymentForSelectedMonth(String roomId, String token, String selectedMonth) async {
  final String apiUrl = 'https://rentconnect.vercel.app/payment/room/$roomId/monthlyPayments';

  try {
    print('API URL: $apiUrl');

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['status'] == true && data['monthlyPayments'].isNotEmpty) {
        final List<dynamic> monthlyPayments = data['monthlyPayments'];

        // Find the payment for the selected month
        final paymentForMonth = monthlyPayments.firstWhere(
          (payment) => payment['month'] == selectedMonth,
          orElse: () => null, // If no payment is found for that month
        );

        if (paymentForMonth != null) {
          final proofOfPayment = paymentForMonth['proofOfPayment'];
          print('Proof of Payment for $selectedMonth: $proofOfPayment');
          return proofOfPayment; // Return if it's a String (URL)
        } else {
          print('No proof of payment found for $selectedMonth.');
          return null; // No payment found for the selected month
        }
      } else {
        print('No payments found or empty monthlyPayments.');
        return null;
      }
    } else {
      throw Exception('Failed to fetch proof of payment: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching proof of payment: $e');
    return null;
  }
}

final List<String> rejectionReasons = [
  'Not enough information provided.',
  'Room is already rented.',
  'Duration is too long.',
  'Not a valid request type.',
  'User did not meet the criteria.',
  'Request was made too late.',
  'Other reasons.',
];


 Map<String, bool> _monthsWithProof = {
    'January': false,
    'February': false,
    'March': false,
    'April': false,
    'May': false,
    'June': false,
    'July': false,
    'August': false,
    'September': false,
    'October': false,
    'November': false,
    'December': false,
  };

  Future<void> _fetchProofForAllMonths(String? roomId, String token) async {
    for (String month in _monthsWithProof.keys) {
      final proof = await getProofOfPaymentForSelectedMonth(roomId!, token, month);
      _monthsWithProof[month] = proof != null; // Set to true if proof exists
    }
    setState(() {}); // Update UI after fetching proof for all months
  }


Future<int?> getReservationDuration(String roomId, String token) async {
  final response = await http.get(
    Uri.parse('https://rentconnect.vercel.app/inquiries/rooms/$roomId'),
    headers: {
      'Authorization': 'Bearer $token', // If you're using token-based authentication
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    // Parse the response JSON
    final data = json.decode(response.body);

    // Check if inquiries exist and return the reservationDuration
    if (data is List && data.isNotEmpty) {
      // Assuming the inquiry structure contains 'reservationDuration'
      return data.first['reservationDuration'];
    }
  } else {
    // Handle the error (you can throw an error or return null)
    print('Failed to load inquiries: ${response.statusCode}');
  }
  return null; // Return null if no valid data is found
}








 

void showRoomDetailBottomSheet(BuildContext context, dynamic room, Map<String, dynamic> userProfiles, List<dynamic> inquiries, {String? selectedMonth, int currentMonthIndex = 0, int initialTabIndex = 0}) async {
   Future<void> markAsAvailable() async {
    try {
      // Replace with your actual backend API endpoint
      final response = await http.put(
        Uri.parse('https://rentconnect.vercel.app/rooms/room/${room['_id']}/markAsAvailable'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        // Successfully marked as available, update local room status
        setState(() {
          room['roomStatus'] = 'available';
        });
        toastNotification.success("Room marked as available");
      } else {
         print('Failed to mark room as available: ${response.body}');
         toastNotification.error("Failed to mark room as available");
      }
    } catch (e) {
      print("Error marking room as available: $e");
         toastNotification.error("Error marking room as available");
    }
  }

  ScrollController tab1ScrollController = ScrollController(); // ScrollController for Tab 1
  ScrollController tab2ScrollController = ScrollController(); // ScrollController for Tab 2
    print('UserId from inquiry: $userId'); // Print the userId for debugging
      print('RoomId from inquiry: ${room['_id']}');
  int? reservationDuration = await getReservationDuration(room['_id'], widget.token);
  print("inquiry $inquiries");
  showModalBottomSheet(
    backgroundColor: _themeController.isDarkMode.value? const Color.fromARGB(255, 43, 45, 56): Colors.white,
    context: context,
    isScrollControlled: true, // Makes the modal sheet taller
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      int selectedDay = room['dueDate'] != null 
          ? DateTime.parse(room['dueDate']).day 
          : 5; // Default to the 5th day
      DateTime? _selectedDueDate;

      void calculateDueDate() {
        DateTime today = DateTime.now();

        // Set the due date to the selected day of the current month
        _selectedDueDate = DateTime(today.year, today.month, selectedDay);
        
        // If today is past the selected day, move to the next month
        if (today.day > selectedDay) {
          _selectedDueDate = DateTime(today.year, today.month + 1, selectedDay+1);
        }
      }

      // Call the function to calculate due date
      calculateDueDate();

      List<String> photos = [
        (room['photo1'] as String?)?.toString() ?? '',
        (room['photo2'] as String?)?.toString() ?? '',
        (room['photo3'] as String?)?.toString() ?? '',
      ].where((photo) => photo.isNotEmpty).toList();

      PageController pageController = PageController();
      bool hasOccupants = room['occupantUsers'] != null && room['occupantUsers'].isNotEmpty;
      bool hasReserver = room['reservationInquirers'] != null && room['reservationInquirers'].isNotEmpty;
      bool isReserved = room['roomStatus'] == 'reserved';
      bool isRented = inquiries.isNotEmpty && inquiries.any((inquiry) => inquiry['isRented'] == true);
      bool isAvailable = room['roomStatus'] == 'available';
      bool isOccupied = room['roomStatus'] == 'occupied';

      bool hasPendingInquiry = false;
      if (propertyInquiries.containsKey(room['_id'])) {
        List<dynamic> inquiries = propertyInquiries[room['_id']] ?? [];
        hasPendingInquiry = inquiries.any((inquiry) => inquiry['status'] == 'pending');
      }
      

      return DefaultTabController(
        length: 2, // Two tabs
        initialIndex: initialTabIndex,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.90,
            maxWidth: MediaQuery.of(context).size.width * 0.98,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 130),  // indent and endIndent effect
                  height: 6,  // thickness
                  decoration: BoxDecoration(
                    color: Colors.grey,  // Divider color
                    borderRadius: BorderRadius.circular(10),  // Rounded corners
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10.0, left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Room No. ${room['roomNumber']?.toString() ?? 'Unknown'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        fontFamily: 'manrope',
                      ),
                    ),
                    
                  ],
                ),
              ),
              // TabBar
              TabBar(
                labelColor: _themeController.isDarkMode.value? Colors.white: Colors.black,
                indicatorColor: _themeController.isDarkMode.value? Colors.white:Colors.black,
                tabs: [
                  Tab(text: 'Room'),
                  Tab(text: 'Payment'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Tab 1: Occupants, Room Photos, Agreement, etc.
                    Padding(
                      padding: const EdgeInsets.only(right: 3.0),
                      child: Scrollbar(
                        controller: tab1ScrollController, // Add ScrollController for Tab 1
                        thickness: 4,
                        radius: Radius.circular(10),
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: tab1ScrollController, // Assign ScrollController here too
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                if (hasOccupants)
                                  OccupantListWidget(
                                    propertyInquiries: propertyInquiries,
                                    room: room,
                                    occupantUsers: room['occupantUsers'],
                                    userProfiles: userProfiles,
                                    profilePic: profilePic,
                                    fetchUserProfile: fetchUserProfile,
                                    isDarkMode: _themeController.isDarkMode.value,
                                  ),
                                if (hasReserver)
                                  ReserverList(
                                    hasReserver: hasReserver,
                                    room: room,
                                    userProfiles: userProfiles,
                                    profilePic: profilePic,
                                    themeController: _themeController,
                                    fetchUserProfile: fetchUserProfile,
                                  ),
                                SizedBox(height: 10),
                                Column( // Change Row to Column to stack photo and text vertically
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround, // Aligns children evenly
                                      children: [
                                        SizedBox(
                                          height: 150,
                                          width: 150,
                                          child: photos.isNotEmpty
                                              ? PageView.builder(
                                                  controller: pageController,
                                                  itemCount: photos.length,
                                                  itemBuilder: (context, index) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        showFullscreenImage(context, photos[index]);
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          border: Border.all(width: 1, color: _themeController.isDarkMode.value ? Colors.white : Colors.black),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4),
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(8),
                                                            child: FadeInImage.assetNetwork(
                                                              placeholder: 'assets/images/placeholder.webp',
                                                              image: photos[index],
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )
                                              : const Center(child: Text("No photos available")),
                                        ),
                                        SizedBox(width: 10),
                                        
                                          Expanded( // Makes the text take remaining space
                                            child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the start
                                                  children: [
                                                    Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: 'Monthly rent: ', 
                                                            style: TextStyle(
                                                              fontFamily: 'manrope',
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 13
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: '₱${room['price'] ?? 'N/A'}',
                                                            style: TextStyle(
                                                              fontFamily: 'manrope',
                                                              fontWeight: FontWeight.normal,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: 'Capacity: ', 
                                                            style: TextStyle(
                                                              fontFamily: 'manrope',
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: '${room['capacity'] ?? 'N/A'}',
                                                            style: TextStyle(
                                                              fontFamily: 'manrope',
                                                              fontWeight: FontWeight.normal,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: 'Month Deposit: ', 
                                                            style: TextStyle(
                                                              fontFamily: 'manrope',
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: '${room['deposit'] ?? 'N/A'}',
                                                            style: TextStyle(
                                                              fontFamily: 'manrope',
                                                              fontWeight: FontWeight.normal,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: 'Month Advance: ', 
                                                            style: TextStyle(
                                                              fontFamily: 'manrope',
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: '${room['advance'] ?? 'N/A'}',
                                                            style: TextStyle(
                                                              fontFamily: 'manrope',
                                                              fontWeight: FontWeight.normal,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                          ), // Spacing between the photo and texts
                                      ],
                                    ),
                                    if (photos.isNotEmpty)
                                      SizedBox(height: 5),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 67.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft, // Aligns to the left
                                        child: SmoothPageIndicator(
                                          controller: pageController,
                                          count: photos.length,
                                          effect: ExpandingDotsEffect(
                                            dotHeight: 5,
                                            dotWidth: 5,
                                            activeDotColor: Theme.of(context).brightness == Brightness.dark
                                                ? Colors.white
                                                : Colors.black,
                                            dotColor: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                 if (isOccupied || isReserved)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        // Show confirmation dialog
                                        bool? confirmed = await showDialog(
                                          context: context,
                                          builder: (context) {
                                            bool isHolding = false;
                                            double progress = 0.0;

                                            return StatefulBuilder(
                                              builder: (context, setState) {
                                                void startHold() {
                                                  setState(() => isHolding = true);
                                                  Future.delayed(const Duration(milliseconds: 30), () {
                                                    if (isHolding && progress < 1.0) {
                                                      setState(() => progress += 0.01);
                                                      startHold();
                                                    } else if (progress >= 1.0) {
                                                      Navigator.of(context).pop(true); // Confirm action
                                                    }
                                                  });
                                                }

                                                void stopHold() {
                                                  setState(() {
                                                    isHolding = false;
                                                    progress = 0.0;
                                                  });
                                                }

                                                return AlertDialog(
                                                  title: Text("Confirmation"),
                                                  content: Text("This action is irreversible and will remove all the occupants record from your room. Do you want to proceed?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop(false); // Cancel action
                                                      },
                                                      child: Text("Cancel"),
                                                    ),
                                                    GestureDetector(
                                                      onTapDown: (_) => startHold(),
                                                      onTapUp: (_) => stopHold(),
                                                      onTapCancel: stopHold,
                                                      child: Stack(
                                                        alignment: Alignment.center,
                                                        children: [
                                                          Container(
                                                            width: 130,
                                                            height: 40,
                                                            child: LinearProgressIndicator(
                                                              borderRadius: BorderRadius.circular(12),
                                                              value: progress,
                                                              backgroundColor: const Color.fromARGB(255, 179, 179, 179),
                                                              color: _themeController.isDarkMode.value ? Colors.white : const Color.fromARGB(255, 224, 11, 64),
                                                            ),
                                                          ),
                                                          Text("Hold to Proceed", style: TextStyle(color: isHolding ? const Color.fromARGB(255, 255, 255, 255) : Colors.black)),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        );

                                        // If confirmed, mark as available
                                        if (confirmed == true) {
                                          await markAsAvailable();
                                        }
                                      },
                                      child: Text(
                                        "Mark as Available",
                                        style: TextStyle(
                                          fontFamily: 'manrope',
                                          color: _themeController.isDarkMode.value ? Colors.black : Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                                        textStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),

                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Tab 2: Payment Details with Scrollbar
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Scrollbar(
                        thickness: 4,
                        radius: Radius.circular(10),
                        controller: tab2ScrollController, // Add ScrollController for Tab 2
                        thumbVisibility: true, // Show scrollbar
                        child: SingleChildScrollView(
                          controller: tab2ScrollController, // Assign ScrollController here too
                          child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              if (isOccupied) ...[
                                PaymentDetails(
                                  token: widget.token,
                                  room: room,
                                  selectedDueDate: _selectedDueDate,
                                  selectedMonth: selectedMonth,
                                ),
                                SizedBox(height: 10,),
                                Container(decoration: BoxDecoration(
                                  color: _themeController.isDarkMode.value? Colors.white:Colors.black,
                                  borderRadius: BorderRadius.circular(2)
                                ),
                                height: 2,),
                                Billsboxes(
                                  inquiries: inquiries

                                )
                              ],
                              if (isReserved) ...[
                                ReservationDetails(room: room, token: widget.token, mounted: mounted, reservationDuration: reservationDuration, selectedUserId: selectedUserId!,)
                              ],
                            ],
                          ),
                        ),
                      ),

                 ))],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}







  Future<void> updateInquiryStatus(
      String? inquiryId, String? newStatus, String? token) async {
    final url = Uri.parse(
        'https://rentconnect.vercel.app/inquiries/update/$inquiryId'); // Match your backend route

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $token', // Send authorization token if needed
        },
        body: jsonEncode(
            {'status': newStatus}), // Pass the new status in the request body
      );

      if (response.statusCode == 200) {
        print('Inquiry status updated successfully to $newStatus');
        // Optionally, you can show a success message or refresh the list
      } else {
        print('Failed to update inquiry status: ${response.body}');
        // Optionally, show an error message in the UI
      }
    } catch (error) {
      print('Error updating inquiry status: $error');
      // Optionally, show an error message in the UI
    }
  }
  bool _isLoading = false;



// Approve and update the room
Future<void> updateInquiryStatusAndRoom(
    Map<String, dynamic> inquiry,
    String inquiryId,
    String status,
    String roomId,
    String userId,
    String token,
    int? reservationDuration,
) async {
    final url = 'https://rentconnect.vercel.app/inquiries/update/$inquiryId'; // Update inquiry status
    try {
        final response = await http.patch(
            Uri.parse(url),
            headers: {
                'Authorization': 'Bearer $token', // Include token if required
                'Content-Type': 'application/json',
            },
            body: json.encode({
                'status': status,
                'requestType': inquiry['requestType'], // Include requestType
                'roomId': roomId,
                'userId': userId,
                'reservationDuration': reservationDuration, // Pass the duration
            }),
        );

        if (response.statusCode == 200) {
            // Get the occupant's email
            final emailResponse = await http.get(
                Uri.parse('https://rentconnect.vercel.app/inquiries/$inquiryId/email'),
                headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                },
            );
            if (emailResponse.statusCode == 200) {
                final occupantEmail = json.decode(emailResponse.body)['email'];
                final message = status == 'approved'
                    ? 'Your inquiry for room ${inquiry['roomId']['roomNumber']} has been approved. Please Settle all needed payment immediately.'
                    : 'Your inquiry for room ${inquiry['roomNumber']} has been rejected.';

                await _sendOccupantNotificationEmail(occupantEmail, message, inquiry['userId']);
                print('Occupant notified successfully.');
            } else {
                print('Failed to retrieve occupant email: ${emailResponse.statusCode}');
            }
        } else {
           print('Failed to update inquiry. Status Code: ${response.statusCode}');
            print('Response Body: ${response.body}');
            // Handle error
            throw Exception('Failed to update inquiry and room');
        }
    } catch (e) {
        // Handle exceptions (like network errors)
        print('Error updating inquiry and room: $e');
    } 
}


Future<void> _sendOccupantNotificationEmail(String occupantEmail, String message, String userId) async {
    final emailServiceUrl = 'https://rentconnect.vercel.app/notification/create'; // Endpoint to send notifications
    try {
        final response = await http.post(
            Uri.parse(emailServiceUrl),
            headers: {
                'Content-Type': 'application/json',
            },
            body: json.encode({
                'userId': userId, // Include the userId
                'message': message,
                'requesterEmail': occupantEmail, // This is the same as occupantEmail
            }),
        );

        if (response.statusCode != 201) {
            print('Failed to send notification email to occupant: ${response.statusCode}');
        } else {
            final responseBody = json.decode(response.body);
            print('Email service response: $responseBody');
        }
    } catch (error) {
        print('Error sending notification email: $error');
    }
}






Future<void> rejectAndDeleteInquiry(String inquiryId, String token, String reason) async {
  try {
    // First, call your API to reject the inquiry and send the reason
    final response = await http.patch(
      Uri.parse('https://rentconnect.vercel.app/inquiries/reject/$inquiryId'), // Update the endpoint
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'reason': reason, // Include the rejection reason in the request body
      }),
    );

    if (response.statusCode == 200) {
      print('Inquiry rejected successfully.');

      // Get the inquiry details, including userId and occupant's email
      final inquiryResponse = await http.get(
        Uri.parse('https://rentconnect.vercel.app/inquiries/$inquiryId'), // Update the endpoint to get inquiry details
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (inquiryResponse.statusCode == 200) {
        final inquiryData = json.decode(inquiryResponse.body);
        final occupantEmail = inquiryData['requesterEmail']; // Assuming this field exists
        final userId = inquiryData['userId']; // Get userId from the inquiry data

        // Prepare the rejection message
        final message = 'Your inquiry has been rejected for the following reason: $reason';
        await _sendOccupantNotificationEmail(occupantEmail, message, userId); // Pass userId here
        print('Occupant notified successfully.');
      } else {
        print('Failed to retrieve inquiry details: ${inquiryResponse.statusCode}');
      }
    } else {
      print('Failed to reject inquiry: ${response.statusCode}');
    }
  } catch (error) {
    print('Error rejecting inquiry: $error');
  }
}



  Future<bool> deleteProperty(String propertyId) async {
    final response = await http.delete(Uri.parse('https://rentconnect.vercel.app/deleteProperty/$propertyId'));

    if (response.statusCode == 200) {
      // Successfully deleted the property
      return true;
    } else {
      // Handle error or property not found
      final Map<String, dynamic> responseData = json.decode(response.body);
      throw Exception(responseData['error'] ?? 'Failed to delete property');
    }
  }

  void _deletePropertiesOrRooms() {
    // Implement your logic to delete properties or rooms here
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Property/Room'),
          content: Text(
              'Are you sure you want to delete the selected property or room?'),
          actions: [
            TextButton(
              onPressed: () {
                // Add your deletion logic here
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

 void _confirmDelete(String propertyId) async {
  final bool? confirmed = await showCupertinoDialog<bool>(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text('Delete Property'),
      content: Text('Are you sure you want to delete this property?'),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancel'),
        ),
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Delete', style: TextStyle(
            color: Colors.red
          ),),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    try {
      final success = await deleteProperty(propertyId);
      if (success) {
        setState(() {
          // Ensure items is non-null before calling removeWhere
          if (items != null) {
            items?.removeWhere((property) => property['_id'] == propertyId);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Property deleted successfully.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete property: $error')),
      );
    }
  }
}



void _navigateToEditProperty(String propertyId) {
  // Find the property by its ID from the items list
  var selectedProperty = items?.firstWhere((property) => property['_id'] == propertyId);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UpdateProperty(
        token: widget.token,
        propertyId: propertyId,
        propertyDetails: selectedProperty,  // Passing the selected property details
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    print('selected UserId from inquiry: $selectedUserId');
      print("roomID ${room['_id']}");

    return Scaffold(
      backgroundColor: _themeController.isDarkMode.value
          ? Color.fromARGB(255, 28, 29, 34)
          : Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: _themeController.isDarkMode.value
            ? const Color.fromARGB(255, 28, 29, 34)
            : Colors.white,
        title: Text(
          'Listed properties',
          style: TextStyle(
            color:
                _themeController.isDarkMode.value ? Colors.white : Colors.black,
            fontFamily: 'manrope',
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 12.0),
          child: SizedBox(
            height: 40,  // Set a specific height for the button
            width: 40,   // Set a specific width to make it a square button
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, // Transparent background to simulate outline
                side: BorderSide(
                  color: _themeController.isDarkMode.value ? Colors.white : Colors.black, // Outline color
                  width: 0.90, // Outline width
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Optional rounded corners
                ),
                elevation: 0, // Remove elevation to get the outline effect
                padding: EdgeInsets.all(0), // Remove any padding to center the icon
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.chevron_left,
                color: _themeController.isDarkMode.value ? Colors.white : Colors.black, // Icon color based on theme
                size: 16, // Icon size
              ),
            ),
          ),
        ),
        actions: [
         GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  insetAnimationDuration: Duration(milliseconds: 300),
                  insetAnimationCurve: Curves.easeInOut,
                  child: const Helpscreen(),
                );
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Icon(Icons.help_outline_rounded),
          ),
        ),

        ],
      ),
      body: RefreshIndicator(
        color: Colors.black,
        backgroundColor: Colors.white,
        onRefresh: _refresh,
        child: Skeletonizer(
          enableSwitchAnimation: true,
          enabled: _loading, // Enable skeleton loader based on _loading state
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: _themeController.isDarkMode.value
                        ? Color.fromARGB(255, 28, 29, 34)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: items == null
                        ? Center(child: GlobalLoadingIndicator())
                         : items!.isEmpty
                        ?  Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'You have no listed property!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: _themeController.isDarkMode.value
                                        ? const Color.fromARGB(255, 255, 255, 255)
                                        : const Color.fromARGB(255, 0, 0, 0),
                                    fontFamily: 'manrope',
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                
                                const SizedBox(height: 20),
                                Image.asset(
                                  'assets/icons/emptypana.png',
                                  height: 300, // Adjust height as needed
                                   // Adjust width as needed
                                ),
                                Text(
                                  'Add now by pressing the plus button',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _themeController.isDarkMode.value
                                        ? Colors.white70
                                        : Colors.black54,
                                        fontFamily: 'manrope',
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: items!.length,
                            itemBuilder: (context, index) {
                              final item = items![index];
                              final propertyId = item['_id'];
                              final rooms = propertyRooms[propertyId] ?? [];
                              final photoUrl = item['photo'] != null &&
                                      item['photo'].isNotEmpty
                                  ? (item['photo'].startsWith('http')
                                      ? item['photo']
                                      : '$url${item['photo']}')
                                  : 'https://via.placeholder.com/150'; // Fallback URL

                              return Card(
                                color: _themeController.isDarkMode.value
                                    ? const Color.fromARGB(255, 36, 38, 43)
                                    : const Color.fromARGB(255, 255, 255, 255),
                                elevation: 5.0,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Property Type
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      item['typeOfProperty'] ?? 'Unknown Property Type',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18,
                                                        color: _themeController.isDarkMode.value
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                    Tooltip(
                                                      message: 'Property status: ${item['status']}',
                                                      child: Text(
                                                        item['status'] ?? 'No Status',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                          color: getStatusColor(item['status']), // Call the function to get the color based on status
                                                        ),
                                                      ),
                                                    ),
                                                    PopupMenuButton(
                                                      color: _themeController.isDarkMode.value? const Color.fromARGB(255, 42, 44, 48): Colors.white,
                                                    icon: Icon(Icons.more_vert), // Three-dot icon
                                                    itemBuilder: (context) => [
                                                      PopupMenuItem(
                                                        value: 'edit', // Value for the edit option
                                                        child: Text('Edit Property'), // Display text for the edit option
                                                      ),
                                                      PopupMenuItem(
                                                        value: 'delete', // Value for the delete option
                                                        child: Text('Delete Property'), // Display text for the delete option
                                                      ),
                                                    ],
                                                    onSelected: (value) {
                                                      if (value == 'edit') {
                                                        // Call your edit function or navigate to the edit page
                                                       _navigateToEditProperty(propertyId); // Replace this with your actual edit logic
                                                      } else if (value == 'delete') {
                                                        _confirmDelete(propertyId); // Call the confirm delete function
                                                      }
                                                    },
                                                  ),

                                                  ],
                                                ),



                                                const SizedBox(height: 8),

                                                // Location Row
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      size: 16,
                                                      color: _themeController.isDarkMode.value
                                                          ? const Color.fromARGB(255, 255, 0, 0)
                                                          : const Color.fromARGB(255, 255, 0, 0),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${item['street'] ?? 'No Address'}',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: _themeController.isDarkMode.value
                                                            ? Colors.white70
                                                            : Colors.black54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),

                                                // Description
                                                Text(
                                                  item['description'] ?? 'No Description',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: _themeController.isDarkMode.value
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),

                                                // Image (Placed after text elements)
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: Image.network(
                                                    photoUrl,
                                                    width: double.infinity, // Make image take full width
                                                    height: 180, // Adjust height based on your design
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                        const SizedBox(height: 10),
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Room/Unit Available',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5.0), // Add some padding to make the line look nicer
                                                  child: Divider(
                                                    thickness: 1.5, // Adjust the thickness of the line
                                                    color: _themeController.isDarkMode.value ? Colors.white : Colors.black, // Change color based on the theme
                                                  ),
                                                ),
                                              ),
                                              
                                              Padding(
                                                padding: const EdgeInsets.all(6.0),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => Addingroom(
                                                              token: widget.token,
                                                              propertyId: propertyId,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Icon(
                                                        Icons.add_circle_rounded,
                                                        size: 27,
                                                        color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),

                                        SizedBox(height: 8),
                                        rooms.isEmpty
                                            ? Text('No rooms available.')
                                            : Column(
                                                children: rooms.map((room) {
                                                  final roomPhoto1 =
                                                      '${room['photo1']}';
                                                  final roomId = room[
                                                      '_id']; // Get room ID for inquiries
                                                  final inquiries =
                                                      propertyInquiries[
                                                              roomId] ??
                                                          []; // Fetch inquiries for this room

                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    child: DecoratedBox(
                                                      decoration: BoxDecoration(
                                                         boxShadow: [
                                                          BoxShadow(
                                                            color: _themeController.isDarkMode.value
                                                                ? const Color.fromARGB(95, 0, 0, 0) // Adjust color for dark mode
                                                                : const Color.fromARGB(59, 0, 0, 0), // Adjust color for light mode
                                                            blurRadius: 8.0, // Softens the shadow
                                                            offset: Offset(0, 5), // Changes the position of the shadow
                                                            spreadRadius: 0, // Increases the size of the shadow
                                                          ),
                                                        ],
                                                        color: _themeController
                                                                .isDarkMode
                                                                .value
                                                            ? const Color
                                                                .fromARGB(
                                                                174, 68, 67, 82)
                                                            : const Color.fromARGB(255, 255, 255, 255),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: InkWell(
                                                        
                                                          onTap: () =>
                                                              showRoomDetailBottomSheet(
                                                                  context,
                                                                  room, userProfiles, inquiries),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        4.0),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    ClipRRect(
                                                                      borderRadius: BorderRadius.circular(10),
                                                                      child: Image.network(
                                                                        roomPhoto1,
                                                                        width: 80,
                                                                        height: 60,
                                                                        fit: BoxFit.cover,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(width: 12),
                                                                    Expanded(
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            'Room No. ${room['roomNumber']?.toString() ?? 'Unknown Room Number'}',
                                                                            style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 14,
                                                                              color: _themeController.isDarkMode.value ? const Color.fromARGB(255, 255, 255, 255) : Colors.black,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(height: 4),
                                                                          Text(
                                                                            'Price: ₱${room['price']?.toString() ?? 'N/A'}',
                                                                            style: TextStyle(
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w600,
                                                                              color: _themeController.isDarkMode.value ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 0, 0, 0),
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            'Capacity: ${room['capacity']?.toString() ?? 'N/A'}',
                                                                            style: TextStyle(
                                                                              fontFamily: 'manrope',
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w600,
                                                                              color: _themeController.isDarkMode.value ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 0, 0, 0),
                                                                            ),
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Text(
                                                                                'Room Status: ',
                                                                                style: TextStyle(
                                                                                  fontFamily: 'manrope',
                                                                                  fontSize: 12,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  color: _themeController.isDarkMode.value ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 0, 0, 0),
                                                                                ),
                                                                              ),
                                                                              Flexible(
                                                                                child: Container(
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                                                  decoration: BoxDecoration(
                                                                                    color: _getRoomStatusColor(room['roomStatus']),
                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                  ),
                                                                                  child: Tooltip(
                                                                                    message: 'this room is currently ${room['roomStatus']}',
                                                                                    child: Text(
                                                                                      '${room['roomStatus']?.toString().toUpperCase() ?? 'N/A'}',
                                                                                      style: TextStyle(
                                                                                        fontFamily: 'manrope',
                                                                                        fontWeight: FontWeight.w800,
                                                                                        fontSize: 12,
                                                                                        color: const Color.fromARGB(255, 5, 5, 5),
                                                                                      ),
                                                                                      overflow: TextOverflow.ellipsis, // Prevent overflow by truncating the text
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),

                                                                const SizedBox(
                                                                    height: 10),
                                                                // Only show inquiries if the room status is 'available'
                                                                if (room['roomStatus'] == 'available') ...[
                                                                  Text(
                                                                    'Inquiries',
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          16,
                                                                      color: _themeController
                                                                              .isDarkMode
                                                                              .value
                                                                          ? const Color
                                                                              .fromARGB(
                                                                              255,
                                                                              255,
                                                                              255,
                                                                              255)
                                                                          : const Color
                                                                              .fromARGB(
                                                                              255,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                    ),
                                                                  ),
                                                                  SizedBox(height:8),
                                                                  inquiries.isEmpty? Text('No inquiries yet.')
                                                                      : Column(
                                                                          children:
                                                                              inquiries.map((inquiry) {
                                                                            String userId = inquiry['userId'];
                                                                            var profile = userProfiles[userId]; // Get the user profile

                                                                            // Default to "Unknown User" if profile is not available
                                                                            String userName = (profile != null)
                                                                                ? '${profile['firstName']} ${profile['lastName']}'
                                                                                : 'Unknown User';
                                                                            String userContact = (profile != null && profile['contactDetails'] != null)
                                                                        ? 'Phone: ${profile['contactDetails']['phone'] ?? 'No phone provided'}\n' +
                                                                          'Address: ${profile['contactDetails']['address'] ?? 'No address provided'}'
                                                                        : 'No contact details available';

                                                                            return Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Tooltip(
                                                                                triggerMode: TooltipTriggerMode.longPress,
                                                                               verticalOffset: -50,
                                                                                message: 'Tap to see inquiry detail',
                                                                                child: GestureDetector(
                                                                                  onTap: () {
                                                                                    showInquiryDetailsDialog(context, userName, userContact, inquiry);
                                                                                  },
                                                                                  child: DecoratedBox(
                                                                                    decoration: BoxDecoration(
                                                                                      color: _themeController.isDarkMode.value
                                                                                          ? const Color.fromARGB(255, 0, 0, 0)
                                                                                          : const Color.fromARGB(59, 187, 187, 187),
                                                                                      borderRadius: BorderRadius.circular(12),
                                                                                    ),
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.all(10.0),
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                            children: [
                                                                                              Text(
                                                                                                'Inquiry from $userName', // Display user name
                                                                                                style: TextStyle(
                                                                                                  fontWeight: FontWeight.bold,
                                                                                                  fontSize: 14,
                                                                                                ),
                                                                                              ),
                                                                                              Text(
                                                                                                'View', // Display user name
                                                                                                style: TextStyle(
                                                                                                  fontWeight: FontWeight.bold,
                                                                                                  fontSize: 14,
                                                                                                  color: Colors.blue
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                          
                                                                                          SizedBox(height: 4),
                                                                                          Text(
                                                                                            'Request Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(inquiry['requestDate']))}',
                                                                                            style: TextStyle(
                                                                                              fontSize: 12,
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(height: 4),
                                                                                          Text(
                                                                                            'Request Type: ${inquiry['requestType']?.toString().toUpperCase() ?? 'N/A'}',
                                                                                            style: TextStyle(
                                                                                              fontSize: 12,
                                                                                              fontWeight: FontWeight.w600,
                                                                                            ),
                                                                                          ),
                                                                                          const SizedBox(height: 8),

                                                                                          // Approve and Reject Buttons
                                                                                              Row(
                                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                children: [
                                                                                                  // Approve Button
                                                                                                  Expanded(
                                                                                                    child: ElevatedButton(
                                                                                                      style: ElevatedButton.styleFrom(
                                                                                                        backgroundColor: const Color.fromARGB(255, 0, 255, 106),
                                                                                                        shape: RoundedRectangleBorder(
                                                                                                          borderRadius: BorderRadius.circular(8.0),
                                                                                                        ),
                                                                                                      ),
                                                                                                      onPressed: () async {
                                                                                                        bool? confirm = await showCupertinoDialog(
                                                                                                          context: context,
                                                                                                          builder: (BuildContext context) {
                                                                                                            return CupertinoAlertDialog(
                                                                                                              title: Text("Approve Inquiry"),
                                                                                                              content: Text("Are you sure you want to approve this inquiry?"),
                                                                                                              actions: <Widget>[
                                                                                                                CupertinoDialogAction(
                                                                                                                  child: Text("Cancel"),
                                                                                                                  onPressed: () {
                                                                                                                    Navigator.of(context).pop(false);
                                                                                                                  },
                                                                                                                ),
                                                                                                                 CupertinoDialogAction(
                                                                                                                    isDestructiveAction: true,
                                                                                                                    child: Text("Approve"),
                                                                                                                    onPressed: () {
                                                                                                                        Navigator.of(context).pop(true); // Only pop here
                                                                                                                    },
                                                                                                                ),
                                                                                                              ],
                                                                                                            );
                                                                                                          },
                                                                                                        );

                                                                                                        
                                                                                                if (confirm == true) {
                                                                                                    // Call the function to approve inquiry and update room
                                                                                                    try {
                                                                                                        await updateInquiryStatusAndRoom(
                                                                                                            inquiry,
                                                                                                            inquiry['_id'],
                                                                                                            'approved',
                                                                                                            roomId,
                                                                                                            userId,
                                                                                                            widget.token,
                                                                                                            inquiry['reservationDuration'],
                                                                                                        );

                                                                                                        // Only navigate here after successful update
                                                                                                        Navigator.pushReplacement(
                                                                                                            context,
                                                                                                            MaterialPageRoute(
                                                                                                                builder: (context) => CurrentListingPage(token: widget.token),
                                                                                                            ),
                                                                                                        );
                                                                                                        await fetchRoomInquiries(roomId);
                                                                                                    } catch (error) {
                                                                                                        print('Error: $error');
                                                                                                    }
                                                                                                }
                                                                                                      },
                                                                                                      child: Text(
                                                                                                        'Approve',
                                                                                                        style: TextStyle(
                                                                                                          color: Colors.black,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),

                                                                                                  const SizedBox(width: 8),

                                                                                                  // Reject Button
                                                                                                  Expanded(
                                                                                                  child: ElevatedButton(
                                                                                                    style: ElevatedButton.styleFrom(
                                                                                                      backgroundColor: const Color.fromARGB(255, 255, 3, 78), // Button color for Reject
                                                                                                      shape: RoundedRectangleBorder(
                                                                                                        borderRadius: BorderRadius.circular(8.0),
                                                                                                      ),
                                                                                                    ),
                                                                                                    onPressed: () async {
                                                                                                      // Show confirmation dialog for rejection
                                                                                                      bool? confirm = await showCupertinoDialog(
                                                                                                        context: context,
                                                                                                        builder: (BuildContext context) {
                                                                                                          return CupertinoAlertDialog(
                                                                                                            title: Text("Reject Inquiry"),
                                                                                                            content: Text("Are you sure you want to reject this inquiry?"),
                                                                                                            actions: <Widget>[
                                                                                                              CupertinoDialogAction(
                                                                                                                child: Text("Cancel"),
                                                                                                                onPressed: () {
                                                                                                                  Navigator.of(context).pop(false); // Return false
                                                                                                                },
                                                                                                              ),
                                                                                                              CupertinoDialogAction(
                                                                                                                isDestructiveAction: true,
                                                                                                                child: Text("Reject"),
                                                                                                                onPressed: () {
                                                                                                                  Navigator.of(context).pop(true); // Return true
                                                                                                                },
                                                                                                              ),
                                                                                                            ],
                                                                                                          );
                                                                                                        },
                                                                                                      );

                                                                                                      if (confirm == true) {
                                                                                                        // Show reasons dialog if the inquiry is rejected
                                                                                                        final String? selectedReason = await showCupertinoDialog<String>(
                                                                                                          context: context,
                                                                                                          builder: (BuildContext context) {
                                                                                                            return CupertinoAlertDialog(
                                                                                                              title: Text("Select Rejection Reason"),
                                                                                                              content: Column(
                                                                                                                mainAxisSize: MainAxisSize.min,
                                                                                                                children: rejectionReasons.map((reason) {
                                                                                                                  return CupertinoDialogAction(
                                                                                                                    child: Text(reason),
                                                                                                                    onPressed: () {
                                                                                                                      Navigator.of(context).pop(reason); // Return the selected reason
                                                                                                                    },
                                                                                                                  );
                                                                                                                }).toList(),
                                                                                                              ),
                                                                                                            );
                                                                                                          },
                                                                                                        );

                                                                                                        if (selectedReason != null) {
                                                                                                          // Call API to reject inquiry and delete it with the selected reason
                                                                                                          print('Reject button clicked for inquiry by $userName with reason: $selectedReason');
                                                                                                          if (inquiry['_id'] != null && widget.token != null) {
                                                                                                            await rejectAndDeleteInquiry(inquiry['_id'], widget.token, selectedReason); // Pass the reason
                                                                                                          } else {
                                                                                                            print('Error: Inquiry ID or token is null');
                                                                                                          }
                                                                                                        }
                                                                                                      }
                                                                                                    },
                                                                                                    child: Text(
                                                                                                      'Reject',
                                                                                                      style: TextStyle(
                                                                                                        color: Colors.black,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),


                                                                                                ],
                                                                                              ),
                                                                                                  
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              )

                                                                            );
                                                                          }).toList(),
                                                                        ),
                                                                ],
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        hoverColor: const Color.fromARGB(186, 0, 213, 241),
        backgroundColor: _themeController.isDarkMode.value?Colors.white: const Color.fromARGB(255, 0, 18, 32),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Addlisting(token: widget.token),
            ),
          );
        },
        child: Icon(Icons.add, color:_themeController.isDarkMode.value?Colors.black: Colors.white, size: 30,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }



void showInquiryDetailsDialog(BuildContext context, String userName, String userContact, Map<String, dynamic> inquiry) {
  debugPrintStack(label: 'Error location', maxFrames: 10);
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text(
          "Inquiry Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Name:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    userName,
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'Contact:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                userContact,
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Request Date:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    inquiry['requestDate'] != null
                        ? DateFormat('yyyy-MM-dd').format(DateTime.parse(inquiry['requestDate']))
                        : 'No date provided',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Request Type:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    inquiry['requestType']?.toString()?.toUpperCase() ?? 'N/A',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
            // Conditionally show Proposed Start Date if requestType is 'rent'
            if (inquiry['requestType']?.toString()?.toLowerCase() == 'rent') ...[
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Proposed Start Date:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      inquiry['proposedStartDate'] != null
                          ? DateFormat('yyyy-MM-dd').format(DateTime.parse(inquiry['proposedStartDate']))
                          : 'No date provided',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ],
            if (inquiry['requestType']?.toString()?.toLowerCase() == 'reservation') ...[
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Reservation duration:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.start,
                ),
                SizedBox(width: 5),
                Expanded(
                child: Text(
                  inquiry['reservationDuration'] != null
                      ? '${inquiry['reservationDuration']} Days'  // Append 'Days' after the duration
                      : 'No duration provided',  // Fallback if null
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.start,
                ),
                ),
              ],
            ),
          ],
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Message:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    inquiry['customTerms']?.toString() ?? 'None',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}



Future<void> getPropertyList(String userId) async {
    try {
      setState(() {
        _loading = true; // Set loading to true when starting fetch
      });

      var regBody = {"userId": userId};
      var response = await http.post(
        Uri.parse(getProperty),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        List<dynamic> properties = jsonResponse['success'] ?? [];
        setState(() {
          
          items = properties;
          _loading = false; // Set loading to false after fetch
        });

        for (var property in properties) {
          String propertyId = property['_id'];
          fetchRooms(propertyId);
          // Fetch inquiries for each property
        }
      } else {
        print("Error: ${response.statusCode}");
        print("Response Body: ${response.body}");
        setState(() {
          _loading = false; // Set loading to false on error
        });
      }
    } catch (e) {
      print("Error fetching property list: $e");
      setState(() {
        _loading = false; // Set loading to false on error
      });
    }
  }




  Future<void> fetchUserProfile(String userId) async {
    try {
      final response =
          await http.get(Uri.parse('https://rentconnect.vercel.app/user/$userId'));
      if (response.statusCode == 200) {
        final user = json.decode(response.body);
        setState(() {
          userProfiles[userId] =
              user['profile']; // Store profile data by userId
          profilePic[userId] =
              user['profilePicture']; // Store profile data by userId
        });
      } else {
        print(
            "Error fetching user profile for $userId: ${response.statusCode}");
      }
    } catch (error) {
      print('Error fetching user profile for $userId: $error');
    }
  }


Future<void> fetchRoomInquiries(String roomId) async {
  try {
    final response = await http.get(Uri.parse('https://rentconnect.vercel.app/inquiries/rooms/$roomId'));
    
    if (response.statusCode == 200) {
      final inquiries = json.decode(response.body) as List<dynamic>; // Decode as List
      setState(() {
        propertyInquiries[roomId] = inquiries; 
        initializeRoomId();// Store inquiries by room ID
      });
      
      // Fetch user profiles for each inquiry
      for (var inquiry in inquiries) {
      final userId = inquiry['userId'];
      roomID = inquiry['roomId']['_id'];
      if (inquiry['status'] == 'approved') {
        selectedUserId = userId; // Store userId of the approved inquiry
      }
      
      print('UserId from inquiry: $userId'); // Print the userId for debugging
      print('RoomId from inquiry: $roomID'); // Print the userId for debugging
      await fetchUserProfile(userId); // Fetch user profile if needed
    }
    } else {
      print("Error fetching inquiries for room $roomId: ${response.statusCode}");
    }
  } catch (error) {
    print('Error fetching inquiries for room $roomId: $error');
  }
}

void initializeRoomId() {
  if (propertyInquiries.isNotEmpty) {
    String firstKey = propertyInquiries.keys.first;
    if (propertyInquiries[firstKey] != null && propertyInquiries[firstKey]!.isNotEmpty) {
      roomId = propertyInquiries[firstKey]![0]['roomId']['_id'];
      print("Initialized roomId: $roomId");
    }
  }
}
  Future<void> fetchRooms(String propertyId) async {
    try {
      final response = await http.get(Uri.parse(
          'https://rentconnect.vercel.app/rooms/properties/$propertyId/rooms'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Fetch rooms response data: $data');

        if (data['status']) {
          setState(() {
            propertyRooms[propertyId] = data['rooms'] ?? [];
            //roomId= data['rooms']['_id'];
          });
        
          // Fetch inquiries and user profiles for each room
          for (var room in data['rooms']) {
            String roomId = room['_id'];

            // Fetch inquiries for the room
            await fetchRoomInquiries(roomId);

            // Fetch profiles for the occupants (users and non-users)
            List<dynamic> occupantUsers = room['occupantUsers'] ?? [];
            for (var occupantUserId in occupantUsers) {
              await fetchUserProfile(occupantUserId); // Fetch profile by userId
            }
          }
        } else {
          print(
              'Failed to fetch rooms for property $propertyId. Status: ${data['status']}');
        }
      } else {
        print(
            'Failed to load rooms for property $propertyId. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching rooms for property $propertyId: $e');
    }
  }


Future<void> updateRoomStatus(String? roomId, String? newStatus) async {
  final url = Uri.parse('https://rentconnect.vercel.app/rooms/updateRoom/$roomId'); // Replace with your backend URL
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer your_jwt_token' // Add your JWT token if required
  };

  final updateData = {
    'roomStatus': newStatus,
  };

  try {
    final response = await http.patch(
      url,
      headers: headers,
      body: json.encode(updateData),
    );

    if (response.statusCode == 200) {
      // Handle successful response
      final responseData = json.decode(response.body);
      print('Room updated successfully: ${responseData['room']}');
    } else {
      // Handle error response
      final errorData = json.decode(response.body);
      print('Failed to update room: ${errorData['error']}');
    }
  } catch (error) {
    print('Error updating room: $error');
  }
}

  void showPropertyDetailPage(Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Manageproperty(
          token: widget.token,
          property: property,
          userEmail: email,
          userRole: 'none',
          profileStatus: 'none',
        ),
      ),
    );
  }

  Color _getRoomStatusColor(String? status) {
    switch (status) {
      case 'available':
        return _themeController.isDarkMode.value
            ? const Color.fromARGB(255, 0, 214, 89)
            : const Color.fromARGB(100, 0, 255, 106);
      case 'occupied':
        return _themeController.isDarkMode.value
            ? const Color.fromARGB(255, 0, 132, 255)
            : const Color.fromARGB(100, 0, 217, 255);
      case 'reserved':
        return _themeController.isDarkMode.value
            ? const Color.fromARGB(255, 238, 194, 0)
            : const Color.fromARGB(100, 255, 230, 0);
      default:
        return _themeController.isDarkMode.value
            ? Colors.white70
            : Colors.black54;
    }
  }

  Future<void> _refresh() async {
    setState(() {
      items = null;
      propertyRooms.clear();
      _loading = true; // Set loading to true when refreshing
    });

    await getPropertyList(userId);
  }


Future<void> markRoomAsOccupied(BuildContext context, String roomID) async {
  if (selectedUserId != null) {
    try {
      final response = await http.patch(
        Uri.parse('https://rentconnect.vercel.app/rooms/$roomID/occupy'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': selectedUserId, // Pass the userId from approved inquiry
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // Log the response body

      if (response.statusCode == 200) {
        // Parse the response body for additional data
        final data = json.decode(response.body);
        
        // Extract the agreement details from the response
        final agreementData = data['agreement'];

        // Handle success (e.g., show a success message, refresh UI)
        print('Room marked as occupied successfully: ${data['message']}');

        // Navigate to AgreementDetails page and pass the agreement dat
      } else {
        // Handle error responses
        print('Error marking room as occupied: ${response.body}');
      }
    } catch (error) {
      print('Error occurred while marking room as occupied: $error');
    }
  } else {
    print('No userId found to mark as occupied');
  }
}




Future<String?> fetchProofOfReservation(String roomId) async {
  try {
    // Example API call to fetch payment details
    var response = await http.get(Uri.parse('https://rentconnect.vercel.app/payment/room/$roomId/proofOfReservation'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['proofOfReservation']; // Ensure the key matches your backend response
    } else {
      // Handle error, return null if not available
      return null;
    }
  } catch (e) {
    // Handle any errors during the request
    return null;
  }
}


Future<void> saveImage(String imageUrl) async {
        try {
          final response = await http.get(Uri.parse(imageUrl));

          if (response.statusCode == 200) {
            final Uint8List imageBytes = response.bodyBytes;
            final result = await SaverGallery.saveImage(
              imageBytes,
        quality: 60, // Adjust image quality
        name: "saved_image", // Provide a name for the saved image
        androidRelativePath: "Pictures/YourAppName", // Specify the directory path
        androidExistNotSave: false, // Prevent saving if a file with the same name exists
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Image saved to gallery!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to fetch image.')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving image: $e')),
          );
        }
      }


void showFullscreenImage(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.black,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop(); // Close the fullscreen image on tap
          },
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4, // Limit height to 90% of screen
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child; // If loading complete
                    return Center(child: CircularProgressIndicator()); // Show loading indicator
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(child: Text('Error loading image', style: TextStyle(color: Colors.white)));
                  },
                ),
                Positioned(
                  top: 5,
                  right: 10,
                  child: IconButton(
                    icon: Icon(Icons.download, color: Colors.white),
                    onPressed: () {
                      saveImage(imageUrl);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

}






                                        













// void showRoomDetailPopover(BuildContext context, dynamic room, Map<String, dynamic> userProfiles,  List<dynamic> inquiries, {String? selectedMonth,  int currentMonthIndex = 0}) async{
//   int? reservationDuration = await getReservationDuration(room['_id'], widget.token);
//   showCupertinoDialog(
//     context: context,
//     barrierDismissible: true,
//     builder: (context) {
//       int selectedDay = room['dueDate'] != null
//           ? DateTime.parse(room['dueDate']).day
//           : 5; // Default to the 5th day
//       DateTime? _selectedDueDate;

//       void calculateDueDate() {
//         DateTime today = DateTime.now();
//         _selectedDueDate = DateTime(today.year, today.month, selectedDay);

//         // If the selected day has already passed this month, move to next month
//         if (today.day > selectedDay) {
//           _selectedDueDate = DateTime(today.year, today.month + 1, selectedDay);
//         }
//       }

//       calculateDueDate();

//       List<String> photos = [
//         (room['photo1'] as String?)?.toString() ?? '',
//         (room['photo2'] as String?)?.toString() ?? '',
//         (room['photo3'] as String?)?.toString() ?? '',
//       ].where((photo) => photo.isNotEmpty).toList();

//       PageController pageController = PageController();

//       bool hasOccupants = room['occupantUsers'] != null && room['occupantUsers'].isNotEmpty;
//       bool hasReserver = room['reservationInquirers'] != null && room['reservationInquirers'].isNotEmpty;
//       bool isReserved = room['roomStatus'] == 'reserved';
//       bool isAvailable = room['roomStatus'] == 'available';
//       bool hasInquiry = propertyInquiries['status'] == 'pending';
//       bool isOccupied = room['roomStatus'] == 'occupied';

//       bool hasPendingInquiry = false;
//             if (propertyInquiries.containsKey(room['_id'])) {
//               List<dynamic> inquiries = propertyInquiries[room['_id']] ?? [];
//               hasPendingInquiry = inquiries.any((inquiry) => inquiry['status'] == 'pending');
//             }

//       return Dialog(
//         backgroundColor: Theme.of(context).brightness == Brightness.dark
//             ? const Color.fromARGB(255, 41, 43, 53)
//             : Colors.white,
//         insetPadding: EdgeInsets.symmetric(
//           horizontal: MediaQuery.of(context).size.width < 400
//               ? 9.0 // Smaller padding for smaller screens
//               : 30.0, // More padding for larger screens
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxHeight: MediaQuery.of(context).size.height * 0.8, // Limits the height to 80% of screen
//             maxWidth: MediaQuery.of(context).size.width * 0.98, // Adjust the width to 90% of the screen
//           ),
//           child: StatefulBuilder(
//             builder: (BuildContext context, StateSetter setState) {
//               // Set the initially selected month if provided
//               if (selectedMonth != null) {
//                 _selectedMonth = selectedMonth;
//               }

//               return Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Row for Room Number and Close Button
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Room No. ${room['roomNumber']?.toString() ?? 'Unknown'}',
//                           style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 20,
//                               fontFamily: 'manrope'),
//                         ),
//                         ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor:_themeController.isDarkMode.value
//                               ? const Color.fromARGB(0, 0, 0, 0): const Color.fromARGB(255, 255, 255, 255), // Background color similar to ghost button
//                           elevation: 0,
//                           minimumSize: const Size(0, 33), // Set the height
//                           padding: EdgeInsets.zero, // Remove padding to match size closely
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8.0), // Optional rounded corners
//                           ),
//                         ),
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                         child: Icon(
//                           Icons.close,
//                           color: _themeController.isDarkMode.value
//                               ? Colors.white
//                               : const Color.fromARGB(255, 11, 3, 39), // Icon color based on dark mode
//                         ),
//                       ),

//                       ],
//                     ),

//                     const SizedBox(height: 10),

//                     if (hasOccupants) ...[
//                       OccupantListWidget(
//                         propertyInquiries: propertyInquiries,
//                         room: room,
//                         occupantUsers: room['occupantUsers'],
//                         userProfiles: userProfiles,
//                         profilePic: profilePic,
//                         fetchUserProfile: fetchUserProfile,
//                         isDarkMode: _themeController.isDarkMode.value,
//                       ),
//                     ],

//                     if (hasReserver) ...[
//                       ReserverList(
//                         hasReserver: hasReserver,
//                         room: room,
//                         userProfiles: userProfiles,
//                         profilePic: profilePic,
//                         themeController: _themeController,  // Your theme controller instance
//                         fetchUserProfile: fetchUserProfile, // Your fetch user profile function
//                       ),
//                     ],

//                     Expanded(
//                       child: Scrollbar(
//                         thickness: 7,
//                         radius: Radius.circular(20),
//                         thumbVisibility: true,
//                         controller: pageController, // Makes the scrollbar always visible
//                         child: Padding(
//                           padding: const EdgeInsets.only(right: 10.0),
//                           child: SingleChildScrollView(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 SizedBox(
//                                   height: 150,
//                                   child: photos.isNotEmpty
//                                       ? PageView.builder(
//                                           controller: pageController,
//                                           itemCount: photos.length,
//                                           itemBuilder: (context, index) {
//                                             return GestureDetector(
//                                               onTap: () {
//                                                 // Show full-screen image with save option
//                                                 showFullscreenImage(context, photos[index]);
//                                               },
//                                               child: Padding(
//                                                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                                                 child: ClipRRect(
//                                                   borderRadius: BorderRadius.circular(12),
//                                                   child: FadeInImage.assetNetwork(
//                                                     placeholder: 'assets/images/placeholder.webp',
//                                                     image: photos[index],
//                                                     fit: BoxFit.cover,
//                                                   ),
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                         )
//                                       : const Center(child: Text("No photos available")),
//                                 ),
//                                 if (photos.isNotEmpty)
//                                   Center(
//                                     child: SmoothPageIndicator(
//                                       controller: pageController,
//                                       count: photos.length,
//                                       effect: ExpandingDotsEffect(
//                                         dotHeight: 8,
//                                         dotWidth: 8,
//                                         activeDotColor:
//                                             Theme.of(context).brightness == Brightness.dark
//                                                 ? Colors.white
//                                                 : Colors.black,
//                                         dotColor: Colors.grey,
//                                       ),
//                                     ),
//                                   ),

//                                 if (isAvailable) ... [
//                                   NoInquiriesWidget(),
//                                 ],

//                                 if (hasInquiry) ... [
//                                   Hasinquiry(
//                                     occupantUsers: room['occupantUsers'],
//                                   userProfiles: userProfiles,
//                                   profilePic: profilePic,
//                                   fetchUserProfile: fetchUserProfile,
//                                   isDarkMode: _themeController.isDarkMode.value,

//                                   ),
//                                 ],

//                                 // Proof of Reservation when Reserved
    //                             if (isReserved) ...[
    //                               Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     Text(
    //       'Reservation Details',
    //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    //     ),
    //     const SizedBox(height: 5),
    //     Text('Reservation Fee: ₱${room['reservationFee'] ?? 'N/A'}'),
    //     Text('Duration of Reservation: ${reservationDuration} days'), // Display reservationDuration
    //     const SizedBox(height: 10),
    //     Text('Proof of Reservation:', style: TextStyle(fontWeight: FontWeight.bold)),
    //     FutureBuilder<String?>(
    //       future: fetchProofOfReservation(room['_id']),
    //       builder: (context, snapshot) {
    //         if (snapshot.connectionState == ConnectionState.waiting) {
    //           return Container(
    //             height: 100,
    //             alignment: Alignment.center,
    //             child: CupertinoActivityIndicator(),
    //           );
    //         } else if (snapshot.hasError) {
    //           return Container(
    //             height: 100,
    //             decoration: BoxDecoration(
    //               borderRadius: BorderRadius.circular(12),
    //               color: Colors.grey[200],
    //             ),
    //             alignment: Alignment.center,
    //             child: Text('Error loading image'),
    //           );
    //         } else if (snapshot.hasData && snapshot.data != null) {
    //           return GestureDetector(
    //             onTap: () {
    //               showFullscreenImage(context, snapshot.data!);
    //             },
    //             child: Container(
    //               height: 100,
    //               alignment: Alignment.center,
    //               child: ClipRRect(
    //                 borderRadius: BorderRadius.circular(12),
    //                 child: FadeInImage.assetNetwork(
    //                   placeholder: 'assets/images/placeholder.webp',
    //                   image: snapshot.data!,
    //                   fit: BoxFit.cover,
    //                 ),
    //               ),
    //             ),
    //           );
    //         } else {
    //           return Container(
    //             height: 100,
    //             decoration: BoxDecoration(
    //               borderRadius: BorderRadius.circular(12),
    //               color: const Color.fromARGB(136, 131, 131, 131),
    //             ),
    //             alignment: Alignment.center,
    //             child: Text('No proof uploaded yet'),
    //           );
    //         }
    //       },
    //     ),
    //     const SizedBox(height: 10),
    //     Center(child: Text('Is the reservant moved-in?', style: TextStyle(
    //       fontFamily: 'manrope',
    //       color: _themeController.isDarkMode.value? const Color.fromARGB(255, 216, 216, 216): const Color.fromARGB(193, 53, 53, 53),
    //       fontSize: 13,
    //     ),)),
    //     Tooltip(
    //       message: 'Is the reservant moved-in?',
    //       child: Center(
    //         child: ShadButton(
    //           backgroundColor: _themeController.isDarkMode.value? Colors.white: const Color.fromARGB(255, 0, 16, 34),
    //           onPressed: () async {

    //             // Show confirmation dialog
    //             showCupertinoDialog(
    //               context: context,
    //               builder: (BuildContext context) {
    //                 return CupertinoAlertDialog(
    //                   title: Text('Confirm Occupation'),
    //                   content: Text('Are you sure you want to mark this room as occupied?'),
    //                   actions: [
    //                     CupertinoDialogAction(
    //                       child: Text('Cancel'),
    //                       isDefaultAction: true,
    //                       onPressed: () {
    //                         Navigator.of(context).pop(); // Close the dialog without action
    //                       },
    //                     ),
    //                     CupertinoDialogAction(
    //                       child: Text('Confirm'),
    //                       isDestructiveAction: true,
    //                       onPressed: () async {
    //                         await markRoomAsOccupied(context,room["_id"],);

    //                         Navigator.of(context).pop(); // Close confirmation dialog

    //                         // Show success dialog
    //                         showCupertinoDialog(
    //                           context: context,
    //                           builder: (BuildContext context) {
    //                             return CupertinoAlertDialog(
    //                               title: Text('Success'),
    //                               content: Text('Successfully marked as occupied!'),
    //                               actions: [
    //                                 CupertinoDialogAction(
    //                                   child: Text('OK'),
    //                                   onPressed: () {
    //                                     Navigator.of(context).pop(); // Close success dialog
    //                                     Navigator.pushReplacement(
    //                                       context,
    //                                       MaterialPageRoute(
    //                                         builder: (context) => CurrentListingPage(token: widget.token),
    //                                       ),
    //                                     );
    //                                   },
    //                                 ),
    //                               ],
    //                             );
    //                           },
    //                         );
    //                       },
    //                     ),
    //                   ],
    //                 );
    //               },
    //             );
    //           },
    //           child: Text('Mark as Occupied', style: TextStyle(
    //             color: _themeController.isDarkMode.value? Colors.black: Colors.white
    //           ),),
    //         ),
    //       ),
    //     ),
    //   ],
    // ),
    //                             ],



//                                 // Payment Details when Occupied
//                                 if (isOccupied) ...[
//                                   PaymentDetails(
//                                     room: room,
//                                     selectedDueDate: _selectedDueDate,
//                                     selectedMonth: _selectedMonth,
//                                     proofFuture: _proofFuture,
//                                     buildMonthButtons: (room) => buildMonthButtons(room!, context), // Pass the function here
//                                   ),
//                                 ],
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       );
//     },
//   );
// }

// Future<String?>? _proofFuture;
// String _selectedMonth = '';

// Future<void> _onMonthSelected(String month, Map<String, dynamic> room, BuildContext context) async {
//   if (!mounted) return;

//   _selectedMonth = month; // Update the selected month
//   _currentMonthIndex = months.indexOf(month); // Update the current month index
//   _proofFuture = getProofOfPaymentForSelectedMonth(room['_id'], widget.token, month);

//   // Close any existing dialogs
//   Navigator.of(context).pop(); 

//   // Open a new room detail popover and pass the selected month and current index
//   showRoomDetailPopover(context, room, userProfiles, propertyInquiries[room['_id']] ?? [], 
//     selectedMonth: month, currentMonthIndex: _currentMonthIndex, initialTabIndex: 1);
// }

// // Build month buttons
// Widget buildMonthButtons(Map<String, dynamic> room, BuildContext context, int currentMonthIndex) {
//   List<String> months = [
//     'January', 'February', 'March', 'April', 'May', 'June',
//     'July', 'August', 'September', 'October', 'November', 'December'
//   ];

//   return Container(
//     height: 42,
//     width: double.infinity,
//     child: Row(
//       children: [
//         // Left Arrow Indicator
//         if (months.isNotEmpty) 
//           Padding(
//             padding: const EdgeInsets.only(right: 6.0),
//             child: SizedBox(
//               width: 20,
//               child: IconButton(
//                 icon: Icon(Icons.chevron_left_rounded),
//                 onPressed: () {
//                   // Handle left arrow click (optional)
//                 },
//               ),
//             ),
//           ),

//         // Month Buttons
//         Expanded(
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: months.length,
//             itemBuilder: (BuildContext context, int index) {
//               String month = months[index];
//               bool isSelected = index == currentMonthIndex; // Check if this month is selected

//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4),
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Pass the context to _onMonthSelected
//                     _onMonthSelected(month, room, context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: isSelected ? const Color.fromARGB(255, 26, 100, 238) : _themeController.isDarkMode.value? const Color.fromARGB(255, 134, 133, 133): Color.fromARGB(255, 163, 163, 163), // Highlight selected month
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                     elevation: 2,
//                   ),
//                   child: Text(
//                     month,
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: 'manrope',
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),

//         // Right Arrow Indicator
//         if (months.isNotEmpty)
//           Padding(
//             padding: const EdgeInsets.only(right: 8.0),
//             child: SizedBox(
//               width: 20,
//               child: IconButton(
//                 icon: Icon(Icons.chevron_right_rounded),
//                 onPressed: () {
//                   // Handle right arrow click (optional)
//                 },
//               ),
//             ),
//           ),
//       ],
//     ),
//   );
// }
