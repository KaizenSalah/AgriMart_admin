import 'dart:async';

import 'package:agri_mart_admin/controllers/db_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminProvider extends ChangeNotifier {
  List<QueryDocumentSnapshot> categories = [];
  StreamSubscription<QuerySnapshot>? _categorySubscription;
  List<QueryDocumentSnapshot> products = [];
  StreamSubscription<QuerySnapshot>? _productsSubscription;
  List<QueryDocumentSnapshot> orders = [];
  StreamSubscription<QuerySnapshot>? _ordersSubscription;

  int totalCategories = 0;
  int totalProducts = 0;
  int totalOrders = 0;
  int ordersDelivered = 0;
  int ordersCancelled = 0;
  int ordersOnTheWay = 0;
  int orderPendingProcess = 0;

  AdminProvider() {
    if (FirebaseAuth.instance.currentUser != null) {
      init();
    }
  }

  /// Starts Firestore listeners for the authenticated admin session.
  void init() {
    getCategories();
    getProducts();
    readOrders();
  }

  // GET all the categories
  void getCategories() {
    _categorySubscription?.cancel();
    _categorySubscription = DbService().readCategories().listen((snapshot) {
      categories = snapshot.docs;
      totalCategories = snapshot.docs.length;
      notifyListeners();
    });
  }

  // GET all the products
  void getProducts() {
    _productsSubscription?.cancel();
    _productsSubscription = DbService().readProducts().listen((snapshot) {
      products = snapshot.docs;
      totalProducts = snapshot.docs.length;
      notifyListeners();
    });
  }

  // read all the orders
  void readOrders() {
    _ordersSubscription?.cancel();
    _ordersSubscription = DbService().readOrders().listen((snapshot) {
      orders = snapshot.docs;
      totalOrders = snapshot.docs.length;
      setOrderStatusCount();
      notifyListeners();
    });
  }

  // to the various order types
  void setOrderStatusCount() {
    ordersDelivered = 0;
    ordersCancelled = 0;
    ordersOnTheWay = 0;
    orderPendingProcess = 0;
    for (int i = 0; i < orders.length; i++) {
      if (orders[i]["status"] == "DELIVERED") {
        ordersDelivered++;
      } else if (orders[i]["status"] == "CANCELLED") {
        ordersCancelled++;
      } else if (orders[i]["status"] == "ON_THE_WAY") {
        ordersOnTheWay++;
      } else {
        orderPendingProcess++;
      }
    }
    notifyListeners();
  }

  /// Cancels active Firestore listeners and clears cached admin state.
  void cancelProvider() {
    _ordersSubscription?.cancel();
    _productsSubscription?.cancel();
    _categorySubscription?.cancel();
    categories = [];
    products = [];
    orders = [];
    totalCategories = 0;
    totalProducts = 0;
    totalOrders = 0;
    ordersDelivered = 0;
    ordersCancelled = 0;
    ordersOnTheWay = 0;
    orderPendingProcess = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    _productsSubscription?.cancel();
    _categorySubscription?.cancel();
    super.dispose();
  }
}
