import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wuespace_kiosk/item.dart';


class User {
  final String name;
  int balance;
  int id;

  User({required this.id, required this.name, required this.balance});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      balance: json['balance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
    };
  }
}

class UserListScreen extends StatefulWidget {
  final bool isForSelectingUser;
  final Item? selectedItem;

  const UserListScreen({super.key, required this.isForSelectingUser, this.selectedItem});

  @override
  UserListScreenState createState() => UserListScreenState();
}

class UserListScreenState extends State<UserListScreen> {
  List<User> users = [];
  int maxId = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  String renderPrice(int price, {bool euroSign = true}) {
    int euros = (price / 100).truncate();
    int cents = price % 100;
    

    return "${euros},${cents<10?'0':''}${cents}${euroSign?'€':''}";
  }

  Future<void> loadUsers() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/wuespace_kiosk/user.json';
      final file = File(filePath);

      
      if (await file.exists()) {
        final contents = await file.readAsString();

        final jsonData = jsonDecode(contents) as Map<String, dynamic>;

        maxId = jsonData['max_id'];
        List userJsonList = jsonData['users'] as List;
        setState(() {
          users = userJsonList.map((json) => User.fromJson(json)).toList();
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
      final filePath = '${directory.path}/wuespace_kiosk/user.json';
      final file = File(filePath);
      final jsonUserData = users.map((user) => user.toJson()).toList();
      final Map<String, dynamic> jsonData = Map();
      jsonData['users'] = jsonUserData;
      jsonData['max_id'] = maxId;
      await file.writeAsString(jsonEncode(jsonData));
      print('User data saved');
    } catch (e) {
      print('Failed to save user data: $e');
    }
  }

  void addUser(String name, int balance) {
    setState(() {
      users.add(User(id: ++maxId, name: name, balance: balance));
    });
    saveUsers();
  }

  void updateUserBalance(User user, int amount) {
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
          title: const Text('Add New User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                const balance = 0;
                if (name.isNotEmpty) {
                  addUser(name, balance);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void openBalanceAdjustmentDialog(User user) {
    final TextEditingController balanceController =
        TextEditingController(text: renderPrice(user.balance, euroSign: false));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Schulden von ${user.name} anpassen:'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: balanceController,
                decoration: const InputDecoration(labelText: 'Neuer Schuldenwert (€)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10,),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        balanceController.text = ((double.tryParse(balanceController.text) ?? 0.0) - 10).toStringAsFixed(2);
                      });
                    },
                    child: const Text('-10€'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        balanceController.text = ((double.tryParse(balanceController.text) ?? 0.0) - 5).toStringAsFixed(2);
                      });
                    },
                    child: const Text('-5€'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        balanceController.text = ((double.tryParse(balanceController.text) ?? 0.0) - 1).toStringAsFixed(2);
                      });
                    },
                    child: const Text('-1€'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        balanceController.text = ((double.tryParse(balanceController.text) ?? 0.0) - 0.5).toStringAsFixed(2);
                      });
                    },
                    child: const Text('-50ct'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        balanceController.text = ((double.tryParse(balanceController.text) ?? 0.0) - 0.1).toStringAsFixed(2);
                      });
                    },
                    child: const Text('-10ct'),
                  ),
                ],
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  balanceController.text = "0.00";
                });
              },
              child: const Text('Auf 0 setzen'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: const ButtonStyle(foregroundColor: WidgetStatePropertyAll(Colors.red)),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final parsedBal = double.tryParse(balanceController.text) ?? 0.0;
                int newBal = (parsedBal * 100) as int;
                setState(() {
                  user.balance = newBal;
                });
                saveUsers();
                Navigator.of(context).pop();
              },
              style: const ButtonStyle(foregroundColor: WidgetStatePropertyAll(Colors.green)),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> showConfirmationDialog(User user, BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text('Kauf bestätigen'),
        content: Text('Kauf für ${user.name} Bestätigen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Return false on cancel
            child: const Text('Abbrechen', style: TextStyle(color: Colors.red),),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Return true on confirm
            child: const Text('Bestätigen', style: TextStyle(color: Colors.green),),
          ),
        ],
      );
    },
  ) ?? false; // Default to false if dialog is dismissed
}

  void showCheckmarkAndClose(BuildContext context, int newBal) {
    // Show dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
                const SizedBox(height: 10),
                Text("Erfolg, neuer Stand: ${renderPrice(newBal)}"),
              ],
            ),
          ),
        );
      },
    );

    // Close dialog after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close the dialog
      Navigator.of(context).pop(); // Close the user list
    });
  }

  Future<void> addTransaction(User user, Item item) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/wuespace_kiosk/transactions.json';
      final file = File(filePath);

      List jsonData = <dynamic>[];

      if (await file.exists()) {
        final contents = await file.readAsString();
        jsonData.addAll(jsonDecode(contents) as List); 
      } else {
        print('Transaction File not found at: $filePath');
      }
      Map<String, dynamic> transaction = Map();

      transaction['user'] = user;
      transaction['item'] = item;
      jsonData.add(transaction);

      await file.writeAsString(jsonEncode(jsonData));
      
      print('Transaction data saved');
    } catch (e) {
      print('Failed to add transaction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isForSelectingUser ? 'Käufer auswählen' : 'Schuldenliste'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return GestureDetector(
                  onTap: () async {
                    if (widget.isForSelectingUser && widget.selectedItem != null) {

                      if(!await showConfirmationDialog(user, context)) return;
                      // Add item price to user's balance
                      updateUserBalance(user, widget.selectedItem!.price);
                      addTransaction(user, widget.selectedItem!);
                      showCheckmarkAndClose(context, user.balance);
                    } else {
                      // Open balance adjustment dialog
                      openBalanceAdjustmentDialog(user);
                    }
                  },
                  child: Card(
                    child: ListTile(
                      title: Row(children: [
                          Text(user.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                          Spacer(),
                          Text(
                            user.balance < 0 ? 
                              'Guthaben: ${renderPrice(-1 * user.balance)}':
                              'Schulden: ${renderPrice(user.balance)}',
                            style: TextStyle(color: user.balance <= 0 ? Colors.green : Colors.red),
                          ),
                      ],),
                      trailing: Icon(user.balance < 0 ? Icons.add : user.balance == 0 ? Icons.check : Icons.remove),
                      dense: true,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
              onPressed: () => showAddUserDialog(context),
              tooltip: 'Person hinzufügen',
              child: const Icon(Icons.add),
            ),
    );
  }
}
