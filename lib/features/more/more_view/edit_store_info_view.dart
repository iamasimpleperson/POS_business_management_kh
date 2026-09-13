import 'package:flutter/material.dart';

class EditStoreInfoView extends StatefulWidget {
  const EditStoreInfoView({super.key});

  @override
  State<EditStoreInfoView> createState() => _EditStoreInfoViewState();
}

class _EditStoreInfoViewState extends State<EditStoreInfoView> {
  final TextEditingController _nameController =
      TextEditingController(text: 'ABC Coffee Shop');
  final TextEditingController _phoneController =
      TextEditingController(text: '012 345 678');
  final TextEditingController _emailController =
      TextEditingController(text: 'abccoffee@gmail.com');
  final TextEditingController _addressController = TextEditingController(
    text: '#123, St. 271, ទួលគោក, ភ្នំពេញ,\nព្រះរាជាណាចក្រកម្ពុជា',
  );

  String _selectedCategory = 'កាហ្វេហាង / សេវាកម្ម';
  final List<String> _categories = [
    'កាហ្វេហាង / សេវាកម្ម',
    'ភោជនីយដ្ឋាន',
    'ហាងលក់រាយ',
    'ផ្សារទំនើប',
    'ផ្សេងៗ',
  ];

  String _selectedCurrency = 'ដុល្លារ (USD)';
  final List<String> _currencies = [
    'ដុល្លារ (USD)',
    'រៀល (KHR)',
  ];

  String _selectedDateFormat = 'DD-MM-YYYY';
  final List<String> _dateFormats = [
    'DD-MM-YYYY',
    'YYYY-MM-DD',
    'MM/DD/YYYY',
  ];

  bool _hasLogo = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'កែព័ត៌មានហាង',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('បានរក្សាទុកព័ត៌មានហាងដោយជោគជ័យ!'),
                  backgroundColor: Color(0xFF2E7D32),
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text(
              'រក្សា',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card 1: Store Main Details
              _buildStoreDetailsCard(),
              const SizedBox(height: 20),

              // Section 2 Header: ការកំណត់មូលដ្ឋាន
              const Text(
                'ការកំណត់មូលដ្ឋាន',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // Card 2: Base Settings
              _buildBaseSettingsCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Store Avatar / Logo with camera button
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFC8E6C9),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.storefront_outlined,
                      size: 40,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Field: Store Name
          _buildRowField(
            icon: Icons.storefront_outlined,
            label: 'ឈ្មោះហាង',
            child: _buildTextField(
              controller: _nameController,
              hintText: 'បញ្ចូលឈ្មោះហាង',
            ),
          ),
          const SizedBox(height: 14),

          // Field: Category Dropdown
          _buildRowField(
            icon: Icons.local_offer_outlined,
            label: 'ប្រភេទ',
            child: _buildDropdownField(
              value: _selectedCategory,
              items: _categories,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedCategory = val);
                }
              },
            ),
          ),
          const SizedBox(height: 14),

          // Field: Phone
          _buildRowField(
            icon: Icons.phone_outlined,
            label: 'លេខ',
            child: _buildTextField(
              controller: _phoneController,
              hintText: 'លេខទូរស័ព្ទ',
              keyboardType: TextInputType.phone,
            ),
          ),
          const SizedBox(height: 14),

          // Field: Email
          _buildRowField(
            icon: Icons.mail_outline,
            label: 'អ៊ីមែល',
            child: _buildTextField(
              controller: _emailController,
              hintText: 'អ៊ីមែល',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          const SizedBox(height: 14),

          // Field: Address
          _buildRowField(
            icon: Icons.location_on_outlined,
            label: 'អាសយដ្ឋាន',
            crossAxisAlignment: CrossAxisAlignment.start,
            child: _buildTextField(
              controller: _addressController,
              hintText: 'អាសយដ្ឋានហាង',
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 14),

          // Field: Logo
          _buildRowField(
            icon: Icons.image_outlined,
            label: 'រូបសញ្ញា',
            child: _hasLogo ? _buildLogoPreview() : _buildUploadLogoPlaceholder(),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Field: Currency
          _buildRowField(
            icon: Icons.monetization_on_outlined,
            label: 'ប្រាក់',
            child: _buildDropdownField(
              value: _selectedCurrency,
              items: _currencies,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedCurrency = val);
                }
              },
            ),
          ),
          const SizedBox(height: 14),

          // Field: Date Format
          _buildRowField(
            icon: Icons.calendar_today_outlined,
            label: 'ថ្ងៃ',
            child: _buildDropdownField(
              value: _selectedDateFormat,
              items: _dateFormats,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedDateFormat = val);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowField({
    required IconData icon,
    required String label,
    required Widget child,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2E7D32),
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 82,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          isDense: true,
          border: InputBorder.none,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey[600],
            size: 20,
          ),
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildLogoPreview() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B4D20), Color(0xFF0F3214)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.local_cafe_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: () {
                setState(() => _hasLogo = false);
              },
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadLogoPlaceholder() {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          setState(() => _hasLogo = true);
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
          ),
          child: Icon(
            Icons.add_photo_alternate_outlined,
            color: Colors.grey[500],
            size: 24,
          ),
        ),
      ),
    );
  }
}
