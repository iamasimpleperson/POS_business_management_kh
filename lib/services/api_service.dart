import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../features/customer/customer_models/customer_model.dart';
import '../features/supplier/supplier_models/supplier_model.dart';
import '../features/sales/sales_model/sales_model.dart';
import '../features/purchase/purchase_models/purchase_model.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse({required this.success, this.data, this.error, this.statusCode});
}

class ApiService {
  static final ApiService instance = ApiService._internal();
  factory ApiService() => instance;
  ApiService._internal();

  static const String baseUrl =
      'https://sme-business-management.onrender.com/api/v1';

  String? _token;
  int? _currentBusinessId;
  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? _currentBusiness;

  String? get token => _token;
  int? get currentBusinessId => _currentBusinessId;
  Map<String, dynamic>? get currentUser => _currentUser;
  Map<String, dynamic>? get currentBusiness => _currentBusiness;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  void setToken(String? token) {
    _token = token;
  }

  void setCurrentBusinessId(int? id) {
    _currentBusinessId = id;
  }

  void setCurrentBusiness(Map<String, dynamic>? business) {
    _currentBusiness = business;
    if (business != null && business['id'] != null) {
      _currentBusinessId = business['id'] as int?;
    }
  }

  Map<String, String> _headers({bool isJson = true}) {
    final headers = <String, String>{};
    if (isJson) {
      headers['Content-Type'] = 'application/json';
      headers['Accept'] = 'application/json';
    }
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // ==================== AUTHENTICATION ====================

  /// Login: POST /api/v1/auth/login
  /// FastAPI OAuth2 uses application/x-www-form-urlencoded
  Future<ApiResponse<String>> login({
    required String username,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/login');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {'username': username.trim(), 'password': password},
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['access_token'] != null) {
        _token = body['access_token'].toString();

        // Auto-fetch user details and businesses
        await fetchMe();
        await fetchUserBusinesses();

        return ApiResponse(
          success: true,
          data: _token,
          statusCode: response.statusCode,
        );
      } else {
        final errorMsg = _extractErrorMessage(body) ?? 'បរាជ័យក្នុងការចូលគណនី';
        return ApiResponse(
          success: false,
          error: errorMsg,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'មិនអាចភ្ជាប់ទៅកាន់ម៉ាស៊ីនបម្រើបានទេ: $e',
      );
    }
  }

  /// Register: POST /api/v1/auth/register
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/register');
      final payload = {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      };

      final response = await http.post(
        uri,
        headers: _headers(isJson: true),
        body: jsonEncode(payload),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: body,
          statusCode: response.statusCode,
        );
      } else {
        final errorMsg =
            _extractErrorMessage(body) ?? 'បរាជ័យក្នុងការបង្កើតគណនី';
        return ApiResponse(
          success: false,
          error: errorMsg,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(success: false, error: 'បញ្ហាបណ្តាញ: $e');
    }
  }

  /// Get current user: GET /api/v1/auth/me
  Future<ApiResponse<Map<String, dynamic>>> fetchMe() async {
    try {
      final uri = Uri.parse('$baseUrl/auth/me');
      final response = await http.get(uri, headers: _headers());

      if (response.statusCode == 200) {
        _currentUser = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse(
          success: true,
          data: _currentUser,
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(success: false, statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  // ==================== BUSINESSES ====================

  /// Get user businesses: GET /api/v1/businesses/
  Future<ApiResponse<List<Map<String, dynamic>>>> fetchUserBusinesses() async {
    try {
      final uri = Uri.parse('$baseUrl/businesses/');
      final response = await http.get(uri, headers: _headers());

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        final businesses = list.map((e) => e as Map<String, dynamic>).toList();

        if (businesses.isNotEmpty) {
          _currentBusiness = businesses.first;
          _currentBusinessId = businesses.first['id'] as int?;
        } else {
          // If the user has no business, create one automatically
          final created = await createBusiness(
            name: 'ABC Coffee Shop',
            phone: '012 345 678',
            currency: 'USD',
          );
          if (created.success && created.data != null) {
            _currentBusiness = created.data!;
            _currentBusinessId = created.data!['id'] as int?;
            businesses.add(created.data!);
          }
        }

        return ApiResponse(
          success: true,
          data: businesses,
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(success: false, statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// Create Business: POST /api/v1/businesses/
  Future<ApiResponse<Map<String, dynamic>>> createBusiness({
    required String name,
    String? phone,
    String? address,
    String currency = 'USD',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/businesses/');
      final payload = <String, dynamic>{'name': name, 'currency': currency};
      if (phone != null) payload['phone'] = phone;
      if (address != null) payload['address'] = address;

      final response = await http.post(
        uri,
        headers: _headers(),
        body: jsonEncode(payload),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          data: body,
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(body),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  // ==================== DASHBOARD & ANALYTICS ====================

  /// Get dashboard analytics: GET /api/v1/businesses/{business_id}/dashboard
  Future<ApiResponse<Map<String, dynamic>>> getDashboard({int? businessId}) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/businesses/$bId/dashboard');
      final response = await http.get(uri, headers: _headers());

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse(
          success: true,
          data: body,
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(jsonDecode(response.body)),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'បរាជ័យក្នុងការទាញយកទិន្នន័យ Dashboard: $e',
      );
    }
  }

  // ==================== PRODUCTS ====================

  /// Get products: GET /api/v1/businesses/{business_id}/products
  Future<ApiResponse<List<ProductModel>>> getProducts({
    int? businessId,
    bool includeInactive = false,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse(
        '$baseUrl/businesses/$bId/products?include_inactive=$includeInactive',
      );
      final response = await http.get(uri, headers: _headers());

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        final products = list
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: true,
          data: products,
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(jsonDecode(response.body)),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, error: 'បរាជ័យក្នុងការទាញយកទំនិញ: $e');
    }
  }

  /// Create product: POST /api/v1/businesses/{business_id}/products
  Future<ApiResponse<ProductModel>> createProduct({
    int? businessId,
    required ProductCreate product,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/businesses/$bId/products');
      final response = await http.post(
        uri,
        headers: _headers(),
        body: jsonEncode(product.toJson(businessIdOverride: bId)),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          data: ProductModel.fromJson(body),
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(body),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// Update product: PUT /api/v1/businesses/{business_id}/products/{product_id}
  Future<ApiResponse<ProductModel>> updateProduct({
    int? businessId,
    required int productId,
    required ProductUpdate product,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/businesses/$bId/products/$productId');
      final response = await http.put(
        uri,
        headers: _headers(),
        body: jsonEncode(product.toJson()),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: ProductModel.fromJson(body),
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(body),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// Delete product: DELETE /api/v1/businesses/{business_id}/products/{product_id}
  Future<ApiResponse<bool>> deleteProduct({
    int? businessId,
    required int productId,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/businesses/$bId/products/$productId');
      final response = await http.delete(uri, headers: _headers());

      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse(
          success: true,
          data: true,
          statusCode: response.statusCode,
        );
      }
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(body) ?? 'បរាជ័យក្នុងការលុបទំនិញ',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  // ==================== CATEGORIES ====================

  /// Get categories: GET /api/v1/businesses/{business_id}/categories
  Future<ApiResponse<List<CategoryModel>>> getCategories({
    int? businessId,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/businesses/$bId/categories');
      final response = await http.get(uri, headers: _headers());

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        final categories = list
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: true,
          data: categories,
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(jsonDecode(response.body)),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, error: 'បរាជ័យក្នុងការទាញយកប្រភេទ: $e');
    }
  }

  /// Create category: POST /api/v1/businesses/{business_id}/categories
  Future<ApiResponse<CategoryModel>> createCategory({
    int? businessId,
    required String name,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/businesses/$bId/categories');
      final response = await http.post(
        uri,
        headers: _headers(),
        body: jsonEncode({'name': name, 'business_id': bId}),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          data: CategoryModel.fromJson(body),
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(body),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  // ==================== STOCK ADJUSTMENTS ====================

  /// Adjust stock: POST /api/v1/businesses/{business_id}/stock-adjustments
  Future<ApiResponse<StockMovementModel>> adjustStock({
    int? businessId,
    required StockAdjustmentCreate adjustment,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/businesses/$bId/stock-adjustments');
      final response = await http.post(
        uri,
        headers: _headers(),
        body: jsonEncode(adjustment.toJson()),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          data: StockMovementModel.fromJson(body),
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(body),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// Get stock movements: GET /api/v1/businesses/{business_id}/stock-movements
  Future<ApiResponse<List<StockMovementModel>>> getStockMovements({
    int? businessId,
    int? productId,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      var urlStr = '$baseUrl/businesses/$bId/stock-movements';
      if (productId != null) {
        urlStr += '?product_id=$productId';
      }
      final uri = Uri.parse(urlStr);
      final response = await http.get(uri, headers: _headers());

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        final movements = list
            .map((e) => StockMovementModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: true,
          data: movements,
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(jsonDecode(response.body)),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }


  /// Get customers: GET /api/v1/businesses/{business_id}/customers
  Future<ApiResponse<List<CustomerModel>>> getCustomers({
    int? businessId,
    int skip = 0,
    int limit = 100,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/businesses/$bId/customers?skip=$skip&limit=$limit');
      final response = await http.get(uri, headers: _headers());

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        final customers = list
            .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: true,
          data: customers,
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(jsonDecode(response.body)),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'បរាជ័យក្នុងការទាញយកអតិថិជន: $e',
      );
    }
  }

  /// Create customer: POST /api/v1/businesses/{business_id}/customers
  Future<ApiResponse<CustomerModel>> createCustomer({
    int? businessId,
    required CustomerCreate customer,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/businesses/$bId/customers');
      final payload = customer.toJson(businessIdOverride: bId);
      final response = await http.post(
        uri,
        headers: _headers(),
        body: jsonEncode(payload),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          data: CustomerModel.fromJson(body),
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(body) ?? 'បរាជ័យក្នុងការបន្ថែមអតិថិជន',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'បរាជ័យក្នុងការតភ្ជាប់: $e',
      );
    }
  }

  /// Get customer details: GET /api/v1/businesses/{business_id}/customers/{customer_id}
  Future<ApiResponse<CustomerModel>> getCustomer({
    int? businessId,
    required int customerId,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/businesses/$bId/customers/$customerId');
      final response = await http.get(uri, headers: _headers());

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: CustomerModel.fromJson(body),
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(body),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// Update customer: PUT /api/v1/businesses/{business_id}/customers/{customer_id}
  Future<ApiResponse<CustomerModel>> updateCustomer({
    int? businessId,
    required int customerId,
    required CustomerUpdate customer,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/businesses/$bId/customers/$customerId');
      final response = await http.put(
        uri,
        headers: _headers(),
        body: jsonEncode(customer.toJson()),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: CustomerModel.fromJson(body),
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(body) ?? 'បរាជ័យក្នុងការកែប្រែព័ត៌មានអតិថិជន',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// Delete customer: DELETE /api/v1/businesses/{business_id}/customers/{customer_id}
  Future<ApiResponse<bool>> deleteCustomer({
    int? businessId,
    required int customerId,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/businesses/$bId/customers/$customerId');
      final response = await http.delete(uri, headers: _headers());

      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse(
          success: true,
          data: true,
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(jsonDecode(response.body)) ?? 'បរាជ័យក្នុងការលុបអតិថិជន',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// Get customer history: GET /api/v1/businesses/{business_id}/customers/{customer_id}/history
  Future<ApiResponse<Map<String, dynamic>>> getCustomerHistory({
    int? businessId,
    required int customerId,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/businesses/$bId/customers/$customerId/history');
      final response = await http.get(uri, headers: _headers());

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: body as Map<String, dynamic>,
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(body),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  // ==================== SUPPLIERS ====================

  /// Get suppliers: GET /api/v1/businesses/{business_id}/suppliers
  Future<ApiResponse<List<SupplierModel>>> getSuppliers({
    int? businessId,
    int skip = 0,
    int limit = 100,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/businesses/$bId/suppliers?skip=$skip&limit=$limit');
      final response = await http.get(uri, headers: _headers());

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        final suppliers = list
            .map((e) => SupplierModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: true,
          data: suppliers,
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(jsonDecode(response.body)),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'បរាជ័យក្នុងការទាញយកអ្នកផ្គត់ផ្គង់: $e',
      );
    }
  }

  /// Create supplier: POST /api/v1/businesses/{business_id}/suppliers
  Future<ApiResponse<SupplierModel>> createSupplier({
    int? businessId,
    required SupplierCreate supplier,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/businesses/$bId/suppliers');
      final payload = supplier.toJson(businessIdOverride: bId);
      final response = await http.post(
        uri,
        headers: _headers(),
        body: jsonEncode(payload),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          data: SupplierModel.fromJson(body),
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(body) ?? 'បរាជ័យក្នុងការបន្ថែមអ្នកផ្គត់ផ្គង់',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'បរាជ័យក្នុងការតភ្ជាប់: $e',
      );
    }
  }

  /// Get supplier details: GET /api/v1/businesses/{business_id}/suppliers/{supplier_id}
  Future<ApiResponse<SupplierModel>> getSupplier({
    int? businessId,
    required int supplierId,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/businesses/$bId/suppliers/$supplierId');
      final response = await http.get(uri, headers: _headers());

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: SupplierModel.fromJson(body),
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(body),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// Update supplier: PUT /api/v1/businesses/{business_id}/suppliers/{supplier_id}
  Future<ApiResponse<SupplierModel>> updateSupplier({
    int? businessId,
    required int supplierId,
    required SupplierUpdate supplier,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/businesses/$bId/suppliers/$supplierId');
      final response = await http.put(
        uri,
        headers: _headers(),
        body: jsonEncode(supplier.toJson()),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: SupplierModel.fromJson(body),
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(body) ?? 'បរាជ័យក្នុងការកែប្រែព័ត៌មានអ្នកផ្គត់ផ្គង់',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// Delete supplier: DELETE /api/v1/businesses/{business_id}/suppliers/{supplier_id}
  Future<ApiResponse<bool>> deleteSupplier({
    int? businessId,
    required int supplierId,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/businesses/$bId/suppliers/$supplierId');
      final response = await http.delete(uri, headers: _headers());

      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse(
          success: true,
          data: true,
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(jsonDecode(response.body)) ?? 'បរាជ័យក្នុងការលុបអ្នកផ្គត់ផ្គង់',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  // ==================== SALES ====================

  /// Create sale: POST /api/v1/businesses/{business_id}/sales
  Future<ApiResponse<SaleResponse>> createSale({
    int? businessId,
    required SaleCreate sale,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/businesses/$bId/sales');
      final payload = sale.toJson(businessIdOverride: bId);
      final response = await http.post(
        uri,
        headers: _headers(),
        body: jsonEncode(payload),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          data: SaleResponse.fromJson(body),
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(body) ?? 'បរាជ័យក្នុងការបង្កើតការលក់',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'បរាជ័យក្នុងការតភ្ជាប់: $e',
      );
    }
  }

  /// Get sales: GET /api/v1/businesses/{business_id}/sales
  Future<ApiResponse<List<SaleResponse>>> getSales({
    int? businessId,
    String? status,
    int? customerId,
    int skip = 0,
    int limit = 100,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      var urlStr = '$baseUrl/businesses/$bId/sales?skip=$skip&limit=$limit';
      if (status != null && status.isNotEmpty) {
        urlStr += '&status=$status';
      }
      if (customerId != null && customerId > 0) {
        urlStr += '&customer_id=$customerId';
      }
      final uri = Uri.parse(urlStr);
      final response = await http.get(uri, headers: _headers());

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        final sales = list
            .map((e) => SaleResponse.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: true,
          data: sales,
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(jsonDecode(response.body)),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'បរាជ័យក្នុងការទាញយកបញ្ជីលក់: $e',
      );
    }
  }

  /// Get single sale: GET /api/v1/businesses/{business_id}/sales/{sale_id}
  Future<ApiResponse<SaleResponse>> getSale({
    int? businessId,
    required int saleId,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/businesses/$bId/sales/$saleId');
      final response = await http.get(uri, headers: _headers());

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: SaleResponse.fromJson(body),
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(body),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// Complete sale: POST /api/v1/businesses/{business_id}/sales/{sale_id}/complete
  Future<ApiResponse<SaleResponse>> completeSale({
    int? businessId,
    required int saleId,
    required double paidAmount,
    String? paymentMethod,
    DateTime? saleDate,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/businesses/$bId/sales/$saleId/complete');
      final payload = <String, dynamic>{
        'paid_amount': paidAmount,
        'payment_method': ?paymentMethod,
        'sale_date': (saleDate ?? DateTime.now()).toUtc().toIso8601String(),
      };
      final response = await http.post(
        uri,
        headers: _headers(),
        body: jsonEncode(payload),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: SaleResponse.fromJson(body),
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(body) ?? 'បរាជ័យក្នុងការបញ្ចប់ការលក់',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  // ==================== PURCHASES ====================

  /// Create purchase: POST /api/v1/businesses/{business_id}/purchases
  Future<ApiResponse<PurchaseResponse>> createPurchase({
    int? businessId,
    required PurchaseCreate purchase,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/businesses/$bId/purchases');
      final payload = purchase.toJson(businessIdOverride: bId);
      final response = await http.post(
        uri,
        headers: _headers(),
        body: jsonEncode(payload),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          data: PurchaseResponse.fromJson(body),
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(body) ?? 'បរាជ័យក្នុងការបង្កើតការទិញចូល',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'បរាជ័យក្នុងការតភ្ជាប់: $e',
      );
    }
  }

  /// Get purchases: GET /api/v1/businesses/{business_id}/purchases
  Future<ApiResponse<List<PurchaseResponse>>> getPurchases({
    int? businessId,
    int? supplierId,
    int skip = 0,
    int limit = 100,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      var urlStr = '$baseUrl/businesses/$bId/purchases?skip=$skip&limit=$limit';
      if (supplierId != null && supplierId > 0) {
        urlStr += '&supplier_id=$supplierId';
      }
      final uri = Uri.parse(urlStr);
      final response = await http.get(uri, headers: _headers());

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        final purchases = list
            .map((e) => PurchaseResponse.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResponse(
          success: true,
          data: purchases,
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(jsonDecode(response.body)),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'បរាជ័យក្នុងការទាញយកបញ្ជីទិញចូល: $e',
      );
    }
  }

  /// Get single purchase: GET /api/v1/businesses/{business_id}/purchases/{purchase_id}
  Future<ApiResponse<PurchaseResponse>> getPurchase({
    int? businessId,
    required int purchaseId,
  }) async {
    final bId = businessId ?? _currentBusinessId;
    if (bId == null) {
      return ApiResponse(
        success: false,
        error: 'មិនទាន់មានព័ត៌មានអាជីវកម្ម (Business ID)',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/businesses/$bId/purchases/$purchaseId');
      final response = await http.get(uri, headers: _headers());

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: PurchaseResponse.fromJson(body),
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        error: _extractErrorMessage(body),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'បរាជ័យក្នុងការទាញយកព័ត៌មានទិញចូល: $e',
      );
    }
  }

  // ==================== HELPERS ====================

  String? _extractErrorMessage(dynamic body) {
    if (body == null) return null;
    if (body is Map) {
      if (body['detail'] != null) {
        if (body['detail'] is String) return body['detail'];
        if (body['detail'] is List && (body['detail'] as List).isNotEmpty) {
          final first = (body['detail'] as List).first;
          if (first is Map && first['msg'] != null) {
            return first['msg'].toString();
          }
          return first.toString();
        }
      }
      if (body['message'] != null) return body['message'].toString();
    }
    return null;
  }
}
