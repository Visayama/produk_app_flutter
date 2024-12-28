  import 'package:flutter/material.dart';
  import 'dart:convert'; // Untuk mengelola JSON
  import 'package:http/http.dart' as http;
  import 'package:intl/intl.dart';

  import 'detail_product.dart';

  class HomePage extends StatefulWidget {
  const HomePage({super.key});


    @override
    _HomePageState createState() => _HomePageState();
  }

  class _HomePageState extends State<HomePage> {
    List<dynamic> products = [];
    bool isLoading = true;

    @override
    void initState() {
      super.initState();
      fetchProducts();
    }

    Future<void> fetchProducts() async {
      try {
        print("Fetching products from the server...");
        final response = await http.get(Uri.parse('http://192.168.100.100:3000/products'));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data is Map<String, dynamic> && data.containsKey('data')) {
            setState(() {
              products = data['data'];
              isLoading = false;
            });
            print("Successfully fetched ${products.length} products.");
          } else {
            throw Exception("Unexpected response format: $data");
          }
        } else {
          throw Exception("Failed to load products. Status code: ${response.statusCode}");
        }
      } catch (e) {
        print("Error fetching products: $e");
        setState(() {
          isLoading = false;
        });
      }
    }

    @override
    Widget build(BuildContext context) {
      // Format harga
      final NumberFormat currencyFormat = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );

      return Scaffold(
        backgroundColor: const Color.fromRGBO(58, 66, 86, 1.0),
        appBar: AppBar(
          elevation: 0.1,
          backgroundColor: const Color.fromRGBO(58, 66, 86, 1.0),
          title: const Text(
            "Daftar Produk",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              elevation: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(64, 75, 96, .9),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  leading: Container(
                    padding: const EdgeInsets.only(right: 12.0),
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1.0, color: Colors.white70)),
                    ),
                    child: const Icon(Icons.shopping_cart, color: Colors.white),
                  ),
                  title: Text(
                    product['name'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    currencyFormat.format(product['price']),
                    // "Rp ${product['price']}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailProduk(productId: product['id']),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      );
    }
  }