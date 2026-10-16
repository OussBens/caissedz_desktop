import 'package:flutter/widgets.dart';

import '../../core/design_system/design_system.dart';
import '../../domain/referentiel/referentiel.dart';

/// Libellé d'une valeur stockée du référentiel dans la langue de l'interface.
String libelleRef(BuildContext context, ListeReferentiel liste, String stocke) =>
    liste.libelle(stocke, Localizations.localeOf(context));

/// Liste déroulante d'une liste du référentiel : la valeur renvoyée est la valeur stockée (FR).
class DsSelectReferentiel extends StatelessWidget {
  const DsSelectReferentiel({
    super.key,
    required this.liste,
    required this.valeur,
    required this.onChanged,
    this.placeholder,
    this.actif = true,
    this.cle,
    this.valeurs,
  });
  final ListeReferentiel liste;
  final String? valeur;
  final ValueChanged<String?> onChanged;
  final String? placeholder;
  final bool actif;
  final Key? cle;

  /// Sous-ensemble des valeurs stockées proposées (par défaut : toute la liste).
  final List<String>? valeurs;

  @override
  Widget build(BuildContext context) => DsSelect<String>(
    cle: cle,
    valeur: valeur,
    options: valeurs ?? liste.valeurs.map((v) => v.stocke).toList(),
    libelle: (v) => libelleRef(context, liste, v),
    placeholder: placeholder,
    actif: actif,
    onChanged: onChanged,
  );
}
