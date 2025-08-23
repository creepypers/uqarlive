import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../screens/messagerie/conversations_ecran.dart';
class WidgetBoutonConversations extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isExtended;
  final double? elevation;
  final EdgeInsetsGeometry? margin;
  const WidgetBoutonConversations({
    super.key,
    this.onPressed,
    this.isExtended = false, 
    this.elevation = 6,
    this.margin,
  });
  @override
  Widget build(BuildContext context) {
  return Container(
        margin: margin,
        child: FloatingActionButton(
          onPressed: onPressed ?? () => _ouvrirConversations(context),
          backgroundColor: CouleursApp.principal,
          foregroundColor: Colors.white,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.chat_bubble_outline),
        ),
      );
    }
  void _ouvrirConversations(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ConversationsEcran(),
      ),
    );
  }
}