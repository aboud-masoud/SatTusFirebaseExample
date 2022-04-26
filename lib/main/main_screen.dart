import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sattus_firebase_tutorial/main/main_bloc.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var bloc = MainBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pioneers'),
      ),
      // Using StreamBuilder to display all products from Firestore in real-time
      body: StreamBuilder(
        stream: bloc.productss.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot = streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['title']),
                    subtitle: Text(documentSnapshot['desc']),
                    trailing: SizedBox(
                      width: 155,
                      child: Row(
                        children: [
                          Text(documentSnapshot['date']),
                          // Press this button to edit a single product
                          IconButton(icon: const Icon(Icons.edit), onPressed: () => _createOrUpdate(documentSnapshot)),
                          // This icon button is used to delete a single product
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => bloc.deleteProduct(documentSnapshot.id).then((value) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You have successfully deleted the product')));
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return loading();
        },
      ),
      // Add new product
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget loading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    bloc.titleController.text = "";
    bloc.descController.text = '';
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      bloc.titleController.text = documentSnapshot['title'];
      bloc.descController.text = documentSnapshot['desc'];
      bloc.dateController.text = documentSnapshot['date'];
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: bloc.titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: bloc.descController,
                  decoration: const InputDecoration(
                    labelText: 'Desc',
                  ),
                ),
                TextField(
                  controller: bloc.dateController,
                  decoration: const InputDecoration(labelText: 'Date'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String? title = bloc.titleController.text;
                    final String? desc = bloc.descController.text;
                    final String? date = bloc.dateController.text;
                    if (title != null) {
                      if (desc != null) {
                        if (action == 'create') {
                          // Persist a new product to Firestore
                          await bloc.productss.add({"title": title, "desc": desc, "date": date});
                        } else if (action == 'update') {
                          // Update the product
                          await bloc.productss.doc(documentSnapshot!.id).update({"title": title, "desc": desc, "date": date});
                        }

                        // Clear the text fields
                        bloc.titleController.text = '';
                        bloc.descController.text = '';

                        // Hide the bottom sheet
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You have to fill price')));
                      }
                    } else {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You have to fill name')));
                    }
                  },
                )
              ],
            ),
          );
        });
  }
}
