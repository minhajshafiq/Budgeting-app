import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../utils/constants.dart';

class TransactionItem extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final String imageUrl;
  final String category;
  final Function(Map<String, dynamic>)? onUpdate;

  const TransactionItem({
    Key? key,
    required this.title,
    required this.date,
    required this.amount,
    this.imageUrl = 'https://storage.googleapis.com/pr-newsroom-wp/1/2018/11/Spotify_Logo_RGB_Green.png',
    this.category = 'Abonnements',
    this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        HapticFeedback.lightImpact();
        _showTransactionEditModal(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark 
                  ? AppColors.surfaceDark 
                  : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.borderDark 
                    : AppColors.border, 
                  width: 1
                ),
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    imageUrl,
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.attach_money, size: 24);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: amount.startsWith('+') 
                    ? Colors.green.shade700 
                    : Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.textDark 
                        : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionEditModal(BuildContext context) {
    // Extraire le montant sans le signe et le symbole €
    String amountText = amount.replaceAll('€', '');
    if (amountText.startsWith('+') || amountText.startsWith('-')) {
      amountText = amountText.substring(1);
    }
    
    // Contrôleurs pour les champs du formulaire
    final TextEditingController titleController = TextEditingController(text: title);
    final TextEditingController amountController = TextEditingController(text: amountText);
    final TextEditingController dateController = TextEditingController(text: date);
    final TextEditingController categoryController = TextEditingController(text: category);
    
    // Valeur pour le switch de transaction récurrente
    bool isRecurring = false;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 5.0,
                sigmaY: 5.0,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.surfaceDark 
                    : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.black.withOpacity(0.3) 
                        : Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      spreadRadius: Theme.of(context).brightness == Brightness.dark ? 2 : 5,
                      offset: const Offset(0, -2),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Barre de drag
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 70,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[700] 
                          : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    
                    // Titre
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Modifier la transaction',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Formulaire
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Champ Titre
                            _buildAnimatedField(
                              label: 'Titre',
                              controller: titleController,
                              icon: Icons.business,
                              index: 0,
                            ),
                            const SizedBox(height: 16),
                            
                            // Champs Montant et Date sur la même ligne
                            Row(
                              children: [
                                // Champ Montant
                                Expanded(
                                  flex: 2,
                                  child: _buildAnimatedField(
                                    label: 'Montant',
                                    controller: amountController,
                                    icon: Icons.euro,
                                    keyboardType: TextInputType.number,
                                    suffix: '€',
                                    index: 1,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Champ Date
                                Expanded(
                                  flex: 3,
                                  child: _buildAnimatedField(
                                    label: 'Date',
                                    controller: dateController,
                                    icon: Icons.calendar_today,
                                    index: 2,
                                    onTap: () {
                                      // Montrer le sélecteur de date
                                      FocusScope.of(context).requestFocus(FocusNode());
                                      
                                      // Extraire la date actuelle du texte
                                      DateTime initialDate = DateTime.now();
                                      try {
                                        if (dateController.text.isNotEmpty) {
                                          final parts = dateController.text.split(' ');
                                          if (parts.length == 3) {
                                            final day = int.parse(parts[0]);
                                            final month = _getMonthNumber(parts[1]);
                                            final year = int.parse(parts[2]);
                                            initialDate = DateTime(year, month, day);
                                          }
                                        }
                                      } catch (e) {
                                        // En cas d'erreur, utiliser la date actuelle
                                        initialDate = DateTime.now();
                                      }
                                      
                                      // Créer un thème personnalisé pour le sélecteur de date
                                      final ThemeData theme = Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: AppColors.primary,
                                          onPrimary: Colors.white,
                                          surface: Colors.white,
                                          onSurface: Colors.black,
                                        ),
                                        dialogBackgroundColor: Colors.white,
                                        textButtonTheme: TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            foregroundColor: AppColors.primary,
                                          ),
                                        ),
                                      );
                                      
                                      // Afficher le sélecteur de date avec un délai pour éviter les problèmes de contexte
                                      Future.delayed(Duration.zero, () {
                                        showDatePicker(
                                          context: context,
                                          initialDate: initialDate,
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2050), // Augmenter la date maximale autorisée
                                          builder: (context, child) {
                                            return Theme(data: theme, child: child!);
                                          },
                                        ).then((picked) {
                                          if (picked != null) {
                                            setState(() {
                                              dateController.text = '${picked.day} ${_getMonthName(picked.month)} ${picked.year}';
                                            });
                                          }
                                        });
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Champ Catégorie
                            _buildAnimatedField(
                              label: 'Catégorie',
                              controller: categoryController,
                              icon: Icons.category,
                              index: 3,
                            ),
                            const SizedBox(height: 16),
                            
                            // Option transaction récurrente
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: 1.0,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    Switch(
                                      value: isRecurring,
                                      onChanged: (value) {
                                        setState(() {
                                          isRecurring = value;
                                        });
                                      },
                                      activeColor: AppColors.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Transaction récurrente mensuelle',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Info transaction récurrente
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: isRecurring ? 1.0 : 0.0,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: AppColors.primary,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Cette transaction est récurrente chaque mois',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Boutons sans animation lourde
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(color: Colors.grey.shade300),
                                      ),
                                    ),
                                    child: const Text('Annuler'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Créer une nouvelle transaction avec les valeurs modifiées
                                      final updatedTransaction = {
                                        'title': titleController.text,
                                        'amount': amountController.text.contains('-') 
                                            ? '-${amountController.text.replaceAll('-', '')}€' 
                                            : '-${amountController.text}€',
                                        'date': dateController.text,
                                        'category': categoryController.text,
                                        'imageUrl': imageUrl,
                                        'isRecurring': isRecurring,
                                      };
                                      
                                      // Appeler le callback onUpdate si disponible
                                      if (onUpdate != null) {
                                        onUpdate!(updatedTransaction);
                                      }
                                      
                                      // Afficher un toast de confirmation
                                      _showToast(context, 'Transaction mise à jour: ${titleController.text} - ${amountController.text}€ - ${dateController.text}');
                                      
                                      // Fermer le modal
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Enregistrer'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      // Libérer les contrôleurs
      titleController.dispose();
      amountController.dispose();
      dateController.dispose();
      categoryController.dispose();
    });
  }
  
  Widget _buildAnimatedField({
    required String label,
    required TextEditingController controller,
    required int index,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? suffix,
    VoidCallback? onTap,
  }) {
    // Utiliser une animation plus légère pour réduire la charge sur le thread principal
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: 1.0,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        onTap: onTap,
        readOnly: onTap != null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, size: 20) : null,
          suffixText: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
  
  void _showToast(BuildContext context, String message) {
    // Créer un overlay pour le toast
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100.0,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(25.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    
    // Insérer dans l'overlay et supprimer après un délai
    overlayState?.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
  
  String _getMonthName(int month) {
    const monthNames = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return monthNames[month - 1];
  }
  
  int _getMonthNumber(String monthName) {
    const monthNames = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return monthNames.indexOf(monthName) + 1;
  }
}
