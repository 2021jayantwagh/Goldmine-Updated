import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:best/data/services/user_role_service.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_location.dart';
import 'package:best/presentation/controllers/auth_controller.dart';

class AddListingPage extends StatefulWidget {
  @override
  _AddListingPageState createState() => _AddListingPageState();
}

class _AddListingPageState extends State<AddListingPage> {
  String _selectedListingType = 'Rent';
  String _selectedCategory = 'House';
  bool _isAdmin = false;
  bool _isLoading = true;
  String _adminName = '';
  final _supabase = Supabase.instance.client;
  final _authController = Get.find<AuthController>();
  final TextEditingController _propertyNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _loadAdminInfo();
  }

  @override
  void dispose() {
    _propertyNameController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminStatus() async {
    await _authController.verifyAdminStatus();
    setState(() {
      _isAdmin = _authController.isAdmin.value;
    });

    if (!_isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access denied. Admin privileges required.'),
          backgroundColor: Colors.red,
        ),
      );
      Get.offAllNamed('/home');
    }
  }

  Future<void> _loadAdminInfo() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final userData = await _supabase
            .from('profiles')
            .select('full_name')
            .eq('id', user.id)
            .single();

        setState(() {
          _adminName = userData['full_name'] ?? 'Admin';
          _isLoading = false;
        });
      } else {
        setState(() {
          _adminName = 'Admin';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _adminName = 'Admin';
        _isLoading = false;
      });
    }
  }

  void _validateAndNavigate() {
    if (_propertyNameController.text.trim().isEmpty) {
      // Show centered error message box
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB8C100).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFB8C100),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Property Name Required',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Please enter a property name before proceeding.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB8C100),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      'OK',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddLocationPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Listing',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: _isAdmin
          ? _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting Text
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                                text: 'Hi $_adminName, Fill detail of your '),
                            TextSpan(
                              text: 'real estate',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Property Name Input Field
                      TextField(
                        controller: _propertyNameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          hintText: 'Enter property name',
                          hintStyle: GoogleFonts.poppins(fontSize: 16),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Icon(Icons.home_outlined,
                                color: Colors.black54, size: 28),
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),

                      // Listing Type
                      Text(
                        'Listing type',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: ['Rent', 'Sell'].map((type) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ChoiceChip(
                              labelPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              label: Text(
                                type,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: _selectedListingType == type
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              selected: _selectedListingType == type,
                              selectedColor: const Color(0xFFB8C100),
                              backgroundColor: Colors.grey.shade300,
                              onSelected: (selected) {
                                setState(() => _selectedListingType = type);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 35),

                      // Property Category
                      Text(
                        'Property category',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          'House',
                          'Apartment',
                          'Hotel',
                          'Villa',
                          'Cottage'
                        ].map((category) {
                          return ChoiceChip(
                            labelPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            label: Text(
                              category,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: _selectedCategory == category
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            selected: _selectedCategory == category,
                            selectedColor: const Color(0xFFB8C100),
                            backgroundColor: Colors.grey.shade300,
                            onSelected: (selected) {
                              setState(() => _selectedCategory = category);
                            },
                          );
                        }).toList(),
                      ),
                      const Spacer(),

                      // Navigation Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back Button (Rounded with Shadow)
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: FloatingActionButton(
                              onPressed: () => Navigator.pop(context),
                              backgroundColor: Colors.white,
                              elevation: 0,
                              child: const Icon(Icons.arrow_back,
                                  color: Colors.black, size: 28),
                            ),
                          ),

                          // Next Button (Gradient Style)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFC1D000), Color(0xFF7A8900)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 70, vertical: 18),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: _validateAndNavigate,
                              child: Text(
                                'Next',
                                style: GoogleFonts.poppins(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
