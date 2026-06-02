import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../models/prediction_result.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // ── POST /predict ──────────────────────────────────────────
  // Matches server.py: predict_api(req: TextRequest) -> { label, confidence }
  Future<PredictionResult> predict(String text) async {
    final uri = Uri.parse('$baseUrl/predict');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw const SocketException('Connection timed out'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PredictionResult.fromJson(json);
    } else {
      throw HttpException(
        'Prediction failed (${response.statusCode}): ${response.body}',
      );
    }
  }

  // ── GET /download-clean-data ───────────────────────────────
  // Matches server.py: download_clean_data() -> FileResponse("cleaned_data.csv")
  Future<void> downloadCleanData() async {
    final uri = Uri.parse('$baseUrl/download-clean-data');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not open download URL');
    }
  }

  // ── Connectivity check ─────────────────────────────────────
  Future<bool> isServerOnline() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 5));
      return response.statusCode < 500;
    } catch (_) {
      return false;
    }
  }
}
