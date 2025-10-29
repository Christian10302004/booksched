import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String _errorMessage = '';
  bool _isLoading = false;
  String? _role;

  User? get user => _user;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  String? get role => _role;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (user != null) {
      await _fetchUserRole(user.uid);
    } else {
      _role = null;
    }
    notifyListeners();
  }

  Future<void> _fetchUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      _role = doc.data()?['role'] as String?;
    } catch (e) {
      _errorMessage = 'Failed to fetch user role';
    }
    notifyListeners();
  }

  Future<void> createUserWithEmailAndPassword(
      String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = cred.user;
      await _user!.updateDisplayName(name);
      await _firestore.collection('users').doc(_user!.uid).set({
        'name': name,
        'email': email,
        'role': 'user', 
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _fetchUserRole(_user!.uid);
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Registration failed';
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Login failed';
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
