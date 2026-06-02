import 'package:flutter/material.dart';
import '../models/prediction_result.dart';
import '../services/api_service.dart';

enum PredictionState { idle, loading, success, error }

class PredictionProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  PredictionState state = PredictionState.idle;
  PredictionResult? result;
  String? errorMessage;
  bool isServerOnline = false;
  bool isDownloading = false;

  PredictionProvider() {
    _checkServer();
  }

  Future<void> _checkServer() async {
    isServerOnline = await _api.isServerOnline();
    notifyListeners();
  }

  Future<void> predict(String text) async {
    if (text.trim().isEmpty) return;

    state = PredictionState.loading;
    result = null;
    errorMessage = null;
    notifyListeners();

    try {
      result = await _api.predict(text.trim());
      state = PredictionState.success;
    } catch (e) {
      errorMessage = _friendlyError(e.toString());
      state = PredictionState.error;
    }

    notifyListeners();
  }

  Future<void> downloadData() async {
    isDownloading = true;
    notifyListeners();
    try {
      await _api.downloadCleanData();
    } catch (e) {
      errorMessage = _friendlyError(e.toString());
    }
    isDownloading = false;
    notifyListeners();
  }

  void reset() {
    state = PredictionState.idle;
    result = null;
    errorMessage = null;
    notifyListeners();
  }

  String _friendlyError(String raw) {
    if (raw.contains('timed out') || raw.contains('SocketException')) {
      return 'Cannot reach server. Make sure the FastAPI server is running on port 8000.';
    }
    if (raw.contains('Connection refused')) {
      return 'Connection refused. Start the server with: uvicorn server:app --reload';
    }
    return 'Something went wrong. Please try again.';
  }
}
