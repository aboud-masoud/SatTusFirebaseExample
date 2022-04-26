import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MainBloc {
  // text fields' controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  final CollectionReference productss = FirebaseFirestore.instance.collection('todo');

  // Deleteing a product by id
  Future<void> deleteProduct(String productId) async {
    return await productss.doc(productId).delete();
  }
}
