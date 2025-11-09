import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../screens/address/address_model.dart';
import '../screens/auth/login_screen.dart';

class ApiService {
  // Base URL for your backend
  // static const String baseUrl = "http://172.20.10.2:8080/api";
  // static const String baseUrl = "https://service-be-nagh.onrender.com/api";
  // static const String baseUrl = "http://localhost:8080/api";
  static const String baseUrl = 'http://3.94.103.35:8080/api';

  static String? token;

  // ------------------ Helper for headers ------------------
  static Map<String, String> _headers({bool withAuth = false}) {
    final headers = {"Content-Type": "application/json"};
    if (withAuth && token != null) {
      headers["Authorization"] = "Bearer $token";
    }
    return headers;
  }

  // ------------------ Global 401 Handler ------------------
  static Future<bool> _checkUnauthorized(BuildContext context, http.Response res) async {
    if (res.statusCode == 401) {
      debugPrint("⚠️ Unauthorized (401) — Redirecting to LoginScreen");

      token = null; // clear token from memory

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      }
      return true;
    }
    return false;
  }



  // ------------------ Registration ------------------
  static Future<Map<String, dynamic>> registerUser(Map<String, dynamic> userData) async {
    print("➡️ POST /auth/register | Request Body: ${json.encode(userData)}");
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: _headers(),
      body: json.encode(userData),
    );
    print("⬅️ Response Status: ${response.statusCode}");
    print("⬅️ Response Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to register user: ${response.body}");
    }
  }

  // ------------------ Login ------------------
  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final body = {"email": email, "password": password};
    print("➡️ POST /auth/login | Request Body: ${json.encode(body)}");
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: _headers(),
      body: json.encode(body),
    );
    print("⬅️ Response Status: ${response.statusCode}");
    print("⬅️ Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      token = data['token']; // save token for future requests
      return data;
    } else {
      throw Exception("Failed to login: ${response.body}");
    }
  }

  // ------------------ Place Order ------------------
  static Future<Map<String, dynamic>> placeOrder( BuildContext context,Map<String, dynamic> orderData) async {
    print("➡️ POST /orders | Request Body: ${json.encode(orderData)}");
    final response = await http.post(
      Uri.parse("$baseUrl/orders"),
      headers: _headers(withAuth: true),
      body: json.encode(orderData),
    );
    print("⬅️ Response Status: ${response.statusCode}");
    print("⬅️ Response Body: ${response.body}");
    if (await _checkUnauthorized(context, response)) {
      return {};
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        return Map<String, dynamic>.from(json.decode(response.body));
      } catch (e) {
        print("⚠️ JSON Decode Error: $e");
        return {"message": "Order placed successfully (non-JSON response)."};
      }
    } else {
      throw Exception("Failed to place order: ${response.statusCode} → ${response.body}");
    }
  }

  // ------------------ Get All Orders ------------------
  static Future<List<Map<String, dynamic>>> getOrders(BuildContext context) async {
    print("➡️ GET /orders");
    final response = await http.get(
      Uri.parse("$baseUrl/orders"),
      headers: _headers(withAuth: true),
    );
    print("⬅️ Response Status: ${response.statusCode}");
    print("⬅️ Response Body: ${response.body}");
    if (await _checkUnauthorized(context, response)) return [];

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Failed to load orders: ${response.body}");
    }
  }

  // ------------------ Update Order Status ------------------
  static Future<Map<String, dynamic>> updateOrderStatus( BuildContext context,int orderId, String status) async {
    print("➡️ PUT /orders/$orderId/status?status=$status");
    final response = await http.put(
      Uri.parse("$baseUrl/orders/$orderId/status?status=$status"),
      headers: _headers(withAuth: true),
    );
    print("⬅️ Response Status: ${response.statusCode}");
    print("⬅️ Response Body: ${response.body}");
    if (await _checkUnauthorized(context, response)) return {};

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to update order status: ${response.body}");
    }
  }

  // ------------------ Cancel Order ------------------
  static Future<Map<String, dynamic>> cancelOrder( BuildContext context,int orderId) async {
    print("➡️ PUT /orders/$orderId/cancel");
    final response = await http.put(
      Uri.parse("$baseUrl/orders/$orderId/cancel"),
      headers: _headers(withAuth: true),
    );
    print("⬅️ Response Status: ${response.statusCode}");
    print("⬅️ Response Body: ${response.body}");
    if (await _checkUnauthorized(context, response)) return {};

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to cancel order: ${response.body}");
    }
  }

  // ------------------ Get Order Details ------------------
  static Future<Map<String, dynamic>> getOrderDetails( BuildContext context,String orderId) async {
    print("➡️ GET /orders/$orderId");
    final response = await http.get(
      Uri.parse("$baseUrl/orders/$orderId"),
      headers: _headers(withAuth: true),
    );
    print("⬅️ Response Status: ${response.statusCode}");
    print("⬅️ Response Body: ${response.body}");
    if (await _checkUnauthorized(context, response)) return {};

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to get order details: ${response.body}");
    }
  }

  static Future<List<dynamic>> getServicesWithItems(BuildContext context) async {
    final response = await http.get(Uri.parse('$baseUrl/pricing/services-with-items'));
    if (await _checkUnauthorized(context, response)) return [];

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load services with items');
    }
  }

  // ------------------ User Info ------------------
  static Future<Map<String, dynamic>> getUserInfo(int userId) async {
    print("➡️ GET /users/me");
    final response = await http.get(
      Uri.parse("$baseUrl/users/me"),
      headers: _headers(withAuth: true),
    );
    print("⬅️ Response Status: ${response.statusCode}");
    print("⬅️ Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to get user info: ${response.body}");
    }
  }

  // ------------------ User Orders ------------------
  static Future<List<Map<String, dynamic>>> getUserOrders() async {
    print("➡️ GET /orders/my");
    final response = await http.get(
      Uri.parse("$baseUrl/orders/my"),
      headers: _headers(withAuth: true),
    );
    print("⬅️ Response Status: ${response.statusCode}");
    print("⬅️ Response Body: ${response.body}");

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Failed to get user orders: ${response.body}");
    }
  }

  // ------------------ Update User Info ------------------
  static Future<Map<String, dynamic>> updateUserInfo(Map<String, dynamic> updatedData) async {
    print("➡️ PUT /users/update | Request Body: ${json.encode(updatedData)}");
    final response = await http.put(
      Uri.parse("$baseUrl/users/update"),
      headers: _headers(withAuth: true),
      body: json.encode(updatedData),
    );
    print("⬅️ Response Status: ${response.statusCode}");
    print("⬅️ Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to update user info: ${response.body}");
    }
  }

  // ------------------ Addresses ------------------
  static Future<List<Address>> getAddresses(BuildContext context) async {
    print("➡️ GET /addresses");
    final response = await http.get(
      Uri.parse("$baseUrl/addresses"),
      headers: _headers(withAuth: true),
    );
    print("⬅️ Response Status: ${response.statusCode}");
    print("⬅️ Response Body: ${response.body}");
    if (await _checkUnauthorized(context, response)) return [];

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => Address.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch addresses: ${response.body}");
    }
  }

  static Future<Address> addAddress( Address address) async {
    print("➡️ POST /addresses | Request Body: ${json.encode(address.toJson())}");
    final response = await http.post(
      Uri.parse("$baseUrl/addresses"),
      headers: _headers(withAuth: true),
      body: json.encode(address.toJson()),
    );
    print("⬅️ Response Status: ${response.statusCode}");
    print("⬅️ Response Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Address.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to add address: ${response.body}");
    }
  }

  static Future<Address> updateAddress(String id, Address address) async {
    print("➡️ PUT /addresses/$id | Request Body: ${json.encode(address.toJson())}");
    final response = await http.put(
      Uri.parse("$baseUrl/addresses/$id"),
      headers: _headers(withAuth: true),
      body: json.encode(address.toJson()),
    );
    print("⬅️ Response Status: ${response.statusCode}");
    print("⬅️ Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return Address.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to update address: ${response.body}");
    }
  }

  static Future<void> deleteAddress(String id) async {
    print("➡️ DELETE /addresses/$id");
    final response = await http.delete(
      Uri.parse("$baseUrl/addresses/$id"),
      headers: _headers(withAuth: true),
    );
    print("⬅️ Response Status: ${response.statusCode}");
    print("⬅️ Response Body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to delete address: ${response.body}");
    }
  }



  static Future<List<dynamic>> getServices() async {
    final response = await http.get(Uri.parse('$baseUrl/laundry-services'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load services');
    }
  }



  // ✅ Fetch Active Orders (Real API)
  static Future<List<dynamic>> getActiveOrders(BuildContext context) async {
    final url = Uri.parse('$baseUrl/orders/active');

    final response = await http.get(
      url,
      headers: _headers(withAuth: true),
    );
    if (await _checkUnauthorized(context, response)) return [];

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Failed to load active orders: ${response.statusCode} ${response.body}',
      );
    }
  }

}
