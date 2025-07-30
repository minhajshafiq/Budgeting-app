import 'package:flutter/foundation.dart';

class SupabaseConfig {
  // ⚠️ REMPLACEZ CES VALEURS PAR VOS VRAIES CLÉS SUPABASE
  // URL de votre projet Supabase (ex: https://votre-projet.supabase.co)
  static const String _devUrl = 'https://neablxirjvyujzkkdgfv.supabase.co';
  // Clé anonyme de votre projet Supabase
  static const String _devAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5lYWJseGlyanZ5dWp6a2tkZ2Z2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE0NTQ5MjgsImV4cCI6MjA2NzAzMDkyOH0.uwlV0k96PWXIKchthGR-jVxPLPlSbrtr09y0Li7SQNA';
  
  // Pour la production, vous pouvez utiliser des variables d'environnement
  static const String _prodUrl = 'YOUR_PRODUCTION_SUPABASE_URL_HERE';
  static const String _prodAnonKey = 'YOUR_PRODUCTION_SUPABASE_ANON_KEY_HERE';
  
  static String get url {
    if (kReleaseMode) {
      return const String.fromEnvironment('SUPABASE_URL', defaultValue: _prodUrl);
    }
    return _devUrl;
  }
  
  static String get anonKey {
    if (kReleaseMode) {
      return const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: _devAnonKey);
    }
    return _devAnonKey;
  }
  
  // Vérifier si les clés sont configurées
  static bool get isConfigured {
    final currentUrl = url;
    final currentKey = anonKey;
    
    // Vérifier que les clés ne sont pas les valeurs par défaut
    final isUrlValid = currentUrl.isNotEmpty && 
                      currentUrl != _prodUrl && 
                      currentUrl.startsWith('https://');
    final isKeyValid = currentKey.isNotEmpty && 
                      currentKey != _prodAnonKey && 
                      currentKey.startsWith('eyJ');
    
    return isUrlValid && isKeyValid;
  }
} 