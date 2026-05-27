import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pequire_user_app/core/services/storage_service.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pequire_user_app/features/auth/domain/entities/user_entity.dart';
import 'package:pequire_user_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:pequire_user_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:pequire_user_app/features/profile/presentation/bloc/profile_state.dart';

class ManageProfilePage extends StatefulWidget {
  final UserEntity user;
  const ManageProfilePage({super.key, required this.user});

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
  String? _avatarUrl;
  bool _isUploadingAvatar = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.name ?? widget.user.email.split('@')[0]);
    _nicknameController = TextEditingController(text: widget.user.nickname ?? '');
    _avatarUrl = widget.user.avatarUrl;
    _dobController = TextEditingController(text: widget.user.dob ?? '');
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber ?? '');
    _addressController = TextEditingController(text: widget.user.lastAddress ?? '');
    
    _selectedCountry = widget.user.country ?? 'India';
    _selectedGender = widget.user.gender ?? 'Not Specified';
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
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully!')),
            );
            Navigator.pop(context);
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _avatarUrl != null 
                          ? NetworkImage(_avatarUrl!) as ImageProvider
                          : const AssetImage('assets/profile_avatar.webp'),
                        child: _isUploadingAvatar 
                          ? const CircularProgressIndicator(color: AppColors.redesignPurple)
                          : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                            if (image != null) {
                              setState(() => _isUploadingAvatar = true);
                              try {
                                final url = await StorageService().uploadImage(image, 'avatars');
                                setState(() => _avatarUrl = url);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
                              } finally {
                                setState(() => _isUploadingAvatar = false);
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.redesignPurple,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
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
                  items: ['India', 'United States', 'Canada', 'United Kingdom', 'Australia'],
                  onChanged: (val) => setState(() => _selectedCountry = val!),
                ),
                const SizedBox(height: 20),
                _buildPhoneField(),
                const SizedBox(height: 20),
                _buildDropdownField(
                  value: _selectedGender,
                  items: ['Male', 'Female', 'Other', 'Not Specified'],
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
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
            context.read<ProfileBloc>().add(UpdateProfile({
              'name': _fullNameController.text,
              'nickname': _nicknameController.text,
              'avatarUrl': _avatarUrl,
              'dob': _dobController.text,
              'email': _emailController.text,
              'gender': _selectedGender,
              'country': _selectedCountry,
              'address': {'street': _addressController.text}
            }));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.redesignPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
