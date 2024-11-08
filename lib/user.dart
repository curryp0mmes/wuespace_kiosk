import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wuespace_kiosk/item.dart';


class User {
  final String name;
  double balance;

  User({required this.name, required this.balance});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      balance: json['balance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'balance': balance,
    };
  }
}

class UserListScreen extends StatefulWidget {
  final bool isForSelectingUser;
  final Item? selectedItem;

  UserListScreen({required this.isForSelectingUser, this.selectedItem});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<User> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/kiosk/user.json';
      final file = File(filePath);

      
      if (await file.exists()) {
        final contents = await file.readAsString();

        final jsonData = jsonDecode(contents) as List;
        setState(() {
          users = jsonData.map((json) => User.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        print('File not found at: $filePath');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Failed to load users: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveUsers() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/kiosk/user.json';
      final file = File(filePath);
      final jsonData = jsonEncode(users.map((user) => user.toJson()).toList());
      await file.writeAsString(jsonData);
      print('User data saved');
    } catch (e) {
      print('Failed to save user data: $e');
    }
  }

  void addUser(String name, double balance) {
    setState(() {
      users.add(User(name: name, balance: balance));
    });
    saveUsers();
  }

  void updateUserBalance(User user, double amount) {
    setState(() {
      user.balance += amount;
    });
    saveUsers();
  }

  void showAddUserDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                const balance = 0.0;
                if (name.isNotEmpty) {
                  addUser(name, balance);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void openBalanceAdjustmentDialog(User user) {
    final TextEditingController balanceController =
        TextEditingController(text: user.balance.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adjust Balance for ${user.name}'),
          content: TextField(
            controller: balanceController,
            decoration: InputDecoration(labelText: 'New Balance (€)'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newBalance = double.tryParse(balanceController.text) ?? 0.0;
                setState(() {
                  user.balance = newBalance;
                });
                saveUsers();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isForSelectingUser ? 'Select User' : 'User List'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return GestureDetector(
                  onTap: () {
                    if (widget.isForSelectingUser && widget.selectedItem != null) {
                      // Add item price to user's balance
                      updateUserBalance(user, widget.selectedItem!.price);
                      Navigator.of(context).pop();
                    } else {
                      // Open balance adjustment dialog
                      openBalanceAdjustmentDialog(user);
                    }
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(user.name,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          'Balance: €${user.balance.toStringAsFixed(2)}'),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
              onPressed: () => showAddUserDialog(context),
              child: Icon(Icons.add),
              tooltip: 'Add User',
            ),
    );
  }
}
