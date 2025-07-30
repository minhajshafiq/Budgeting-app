import '../constants/constants.dart';
import '../../data/company_mappings.dart';

/// Service pour la recherche de logos d'entreprises via Logo.dev
class LogoService {
  String get _logoDevApiKey => ApiConfig.logoDevApiKey;
  
  /// Recherche des logos basée sur une requête textuelle
  Future<List<Map<String, String>>> searchLogos(String query) async {
    final List<Map<String, String>> results = [];
    final normalizedQuery = _normalizeString(query.toLowerCase());
    
    // Recherche dans la base de données d'entreprises
    for (final company in CompanyMappings.companies) {
      final normalizedCompanyName = _normalizeString(company['name']!.toLowerCase());
      if (normalizedCompanyName.contains(normalizedQuery)) {
        final logoUrl = 'https://img.logo.dev/${company['domain']}?token=$_logoDevApiKey';
        results.add({
          'name': company['name']!,
          'url': logoUrl,
        });
      }
    }
    
    // Si aucun résultat exact, essayer de générer des domaines
    if (results.isEmpty) {
      final domains = _generateDomainVariants(query);
      for (final domain in domains) {
        final logoUrl = 'https://img.logo.dev/$domain?token=$_logoDevApiKey';
        results.add({
          'name': query,
          'url': logoUrl,
        });
      }
    }
    
    return results;
  }
  
  /// Normalise une chaîne en supprimant les accents et caractères spéciaux
  String _normalizeString(String input) {
    return input
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('ç', 'c')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ÿ', 'y')
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('_', '');
  }
  
  /// Génère des variantes de domaines à partir d'un nom d'entreprise
  List<String> _generateDomainVariants(String companyName) {
    final clean = companyName.toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
    
    return [
      '$clean.com',
      '$clean.fr',
      '$clean.net',
      '$clean.org',
    ];
  }
} 