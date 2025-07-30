import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';
import '../../core/services/logo_service.dart';
import '../modern_animations.dart';
import 'package:hugeicons/hugeicons.dart';

/// Modal réutilisable pour la recherche de logos d'entreprises
class LogoSearchModal extends StatefulWidget {
  final Function(String) onLogoSelected;

  const LogoSearchModal({
    Key? key,
    required this.onLogoSelected,
  }) : super(key: key);

  @override
  State<LogoSearchModal> createState() => _LogoSearchModalState();
}

class _LogoSearchModalState extends State<LogoSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  final LogoService _logoService = LogoService();
  List<Map<String, String>> _searchResults = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchLogos(String query) async {
    if (query.length < 2) return;
    
    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    final results = await _logoService.searchLogos(query);
    
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Header with search
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Rechercher un logo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textDark : AppColors.text,
                      ),
                    ),
                    const Spacer(),
                    ModernRippleEffect(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCancel01,
                            color: isDark ? AppColors.textDark : AppColors.text,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  style: TextStyle(color: isDark ? AppColors.textDark : AppColors.text),
                  onChanged: _searchLogos,
                  decoration: InputDecoration(
                    hintText: 'Ex: Spotify, Netflix, Amazon...',
                    hintStyle: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: isDark ? AppColors.backgroundDark : AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedSearch01,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Results
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedSearch01,
                              color: AppColors.primary,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Recherchez une entreprise'
                                  : 'Aucun logo trouvé',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return ModernRippleEffect(
                            onTap: () {
                              widget.onLogoSelected(result['url']!);
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.backgroundDark : AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? AppColors.borderDark : AppColors.border,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: NetworkImage(result['url']!),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      result['name']!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? AppColors.textDark : AppColors.text,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
} 