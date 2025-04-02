import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Test',
      home: InventoryPage(),
    );
  }
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  // text fields' controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  final CollectionReference inventory =
  FirebaseFirestore.instance.collection('inventory');


  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _nameController.text = documentSnapshot['name'];
      _priceController.text = documentSnapshot['price'].toString();
      _quantityController.text = documentSnapshot['quantity'].toString();
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                ),
              ),
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: false),
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                ),
              ),              
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                child: Text(action == 'create' ? 'Create' : 'Update'),
                onPressed: () async {
                  String name = _nameController.text;
                  double price = double.parse(_priceController.text);
                  int quantity = int.parse(_quantityController.text);
                  if (name.isNotEmpty && price != null) {
                    if (action == 'create') {
                      // Persist a new product to Firestore
                      await inventory.add({"name": name, "price": price, "quantity": quantity});
                    }

                    if (action == 'update') {
                      // Update the product
                      await inventory.doc(documentSnapshot!.id).update({
                        "name": name,
                        "price": price,
                        "quantity": quantity,
                      });
                    }

                    _nameController.text = '';
                    _priceController.text = '';
                    _quantityController.text = '';

                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          ),
        );
      },
    );
  }

  // Deleting a product by id
  Future<void> _deleteProduct(String productId) async {
    inventory.doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You have successfully deleted a product'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management System'),
        actions: [
          ElevatedButton(onPressed: 
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EmployeePage()),
              );
            }, 
            child: Text("Employees"),)
        ],
      ),
      // Using StreamBuilder to display all products from Firestore in real-time
      body: 
        StreamBuilder(
        stream: inventory.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['name'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                    subtitle: Text("Price: " + documentSnapshot['price'].toString() + "\nQuantity: " + documentSnapshot['quantity'].toString(), style: TextStyle(fontSize: 10),),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _createOrUpdate(documentSnapshot),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _deleteProduct(documentSnapshot.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),

      
      
      // Add new product
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: Text("Add\nItem", textAlign: TextAlign.center,),
      ),
    );
  }
}

class EmployeePage extends StatefulWidget {
  const EmployeePage({Key? key}) : super(key: key);

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  // text fields' controllers
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();



  final CollectionReference employees =
  FirebaseFirestore.instance.collection('employees');

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _fNameController.text = documentSnapshot['fName'];
      _lNameController.text = documentSnapshot['lName'];
      _dobController.text = documentSnapshot['dob'];
      _salaryController.text = documentSnapshot['salary'].toString();
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _fNameController,
                decoration: const InputDecoration(labelText: 'First'),
              ),
              TextField(
                controller: _lNameController,
                decoration: const InputDecoration(labelText: 'Last'),
              ),
              TextField(
                controller: _dobController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                ),
              ),
              TextField(
                keyboardType: TextInputType.numberWithOptions(),
                controller: _salaryController,
                decoration: const InputDecoration(
                  labelText: 'salary',
                ),
              ),              
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                child: Text(action == 'create' ? 'Create' : 'Update'),
                onPressed: () async {
                  String fName = _fNameController.text;
                  String lName = _lNameController.text;
                  String dob = _dobController.text;
                  double salary = double.parse(_salaryController.text);
                  if (fName.isNotEmpty && lName.isEmpty && dob.isNotEmpty && salary != null) {
                    if (action == 'create') {
                      // Persist a new product to Firestore
                      await employees.add({"fName": fName, "lName": lName, "dob": dob, "salary":salary});
                    }

                    if (action == 'update') {
                      // Update the product
                      await employees.doc(documentSnapshot!.id).update({
                        "fName": fName,
                        "lName": lName,
                        "dob":dob,
                        "salary": salary,
                      });
                    }

                    _fNameController.text = '';
                    _lNameController.text = '';

                    _dobController.text = '';
                    _salaryController.text = '';

                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          ),
        );
      },
    );
  }

  // Deleting a product by id
  Future<void> _deleteProduct(String productId) async {
    employees.doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You have successfully deleted a product'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management System', style: TextStyle(fontSize: 17),),
                actions: [
          ElevatedButton(onPressed: 
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InventoryPage()),
              );
            }, 
            child: Text("Inventory"),)
        ],
      ),
      // Using StreamBuilder to display all products from Firestore in real-time
      body: 
        StreamBuilder(
        stream: employees.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['fName'] + " " + documentSnapshot['lName'] , style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                    subtitle: Text("Date of Birth: " + documentSnapshot['dob'] + "\nSalary: " + documentSnapshot['salary'].toString(), style: TextStyle(fontSize: 10),),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _createOrUpdate(documentSnapshot),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _deleteProduct(documentSnapshot.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),

      
      
      // Add new product
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: Text("Add\nItem", textAlign: TextAlign.center,),
      ),
    );
  }
}