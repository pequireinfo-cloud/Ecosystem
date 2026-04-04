import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';

class ManageProfilePage extends StatefulWidget {
  const ManageProfilePage({super.key});

  @override
  State<ManageProfilePage> createState() => _ManageProfilePageState();
}

class _ManageProfilePageState extends State<ManageProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _nicknameController;
  late TextEditingController _dobController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  
  String _selectedCountry = 'United States';
  String _selectedGender = 'Male';

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: 'Andrew Ainsley');
    _nicknameController = TextEditingController(text: 'Andrew');
    _dobController = TextEditingController(text: '12/27/1995');
    _emailController = TextEditingController(text: 'andrew_ainsley@yourdomain.com');
    _phoneController = TextEditingController(text: '+1 111 467 378 399');
    _addressController = TextEditingController(text: '267 New Avenue Park, New York');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: -0.5),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildModernTextField(controller: _fullNameController, hint: 'Full Name'),
              const SizedBox(height: 20),
              _buildModernTextField(controller: _nicknameController, hint: 'Nickname'),
              const SizedBox(height: 20),
              _buildModernTextField(
                controller: _dobController, 
                hint: 'Date of Birth',
                suffixIcon: Icons.calendar_month_rounded,
                onTap: _selectDate,
                readOnly: true,
              ),
              const SizedBox(height: 20),
              _buildModernTextField(
                controller: _emailController, 
                hint: 'Email',
                suffixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _buildDropdownField(
                value: _selectedCountry,
                items: ['United States', 'Canada', 'United Kingdom', 'Australia'],
                onChanged: (val) => setState(() => _selectedCountry = val!),
              ),
              const SizedBox(height: 20),
              _buildPhoneField(),
              const SizedBox(height: 20),
              _buildDropdownField(
                value: _selectedGender,
                items: ['Male', 'Female', 'Other'],
                onChanged: (val) => setState(() => _selectedGender = val!),
              ),
              const SizedBox(height: 20),
              _buildModernTextField(
                controller: _addressController, 
                hint: 'Address',
              ),
              const SizedBox(height: 48),
              _buildUpdateButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 12, 27),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.redesignPurple,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.month}/${picked.day}/${picked.year}";
      });
    }
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hint,
    IconData? suffixIcon,
    VoidCallback? onTap,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        onTap: onTap,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.black87, size: 20) : null,
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.redesignPurple, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Row(
            children: [
              // Mock Flag (using a container for demo)
              Container(
                width: 24,
                height: 16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  image: const DecorationImage(
                    image: NetworkImage('https://flagcdn.com/w40/us.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.black54),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.redesignPurple.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            Navigator.pop(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.redesignPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: const Text(
          'Update',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
