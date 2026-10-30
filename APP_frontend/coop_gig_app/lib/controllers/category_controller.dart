import 'package:flutter/material.dart';
import '../models/service.dart';
import '../services/api_service.dart';

class CategoryController with ChangeNotifier {
  List<CategoryItem> _categories = [];
  List<ServiceItem> _services = [];
  CategoryItem? _selectedCategory;
  ServiceItem? _selectedService;
  bool _isLoading = false;
  String? _errorMessage;

  List<CategoryItem> get categories => _categories;
  List<ServiceItem> get services => _services;
  CategoryItem? get selectedCategory => _selectedCategory;
  ServiceItem? get selectedService => _selectedService;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await ApiService().getCategories();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(CategoryItem category) {
    _selectedCategory = category;
    _selectedService = null;
    notifyListeners();
    fetchServices(categoryId: category.id);
  }

  Future<void> fetchServices({int? categoryId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _services = await ApiService().getServices(categoryId: categoryId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectService(ServiceItem service) {
    _selectedService = service;
    notifyListeners();
  }
}

