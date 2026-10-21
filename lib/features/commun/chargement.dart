import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Vrai tant qu'une liste est lue pour la première fois (aucune valeur encore) : le tableau du module affiche des
/// lignes fantômes et « Chargement… » au lieu de « aucun élément ». Une relecture (après un ajout, une période
/// changée…) garde les lignes précédentes à l'écran.
bool enChargement(AsyncValue<Object?> valeur) => valeur.isLoading && !valeur.hasValue;
