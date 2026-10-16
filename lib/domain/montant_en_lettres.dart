/// Montant en toutes lettres (mention de la facture : « Arrêtée la présente facture à la somme de … »).
abstract final class MontantEnLettres {
  static const _unites = [
    'zéro', 'un', 'deux', 'trois', 'quatre', 'cinq', 'six', 'sept', 'huit', 'neuf', 'dix', 'onze', 'douze', //
    'treize', 'quatorze', 'quinze', 'seize', 'dix-sept', 'dix-huit', 'dix-neuf',
  ];
  static const _dizaines = ['', '', 'vingt', 'trente', 'quarante', 'cinquante', 'soixante'];

  /// Français : « mille deux cent cinquante dinars algériens et cinquante centimes ».
  static String fr(double montant, {String monnaie = 'dinars algériens', String centimes = 'centimes'}) {
    final cts = (montant.abs() * 100).round();
    final entier = cts ~/ 100;
    final reste = cts % 100;
    final texte = '${nombreFr(entier)} $monnaie';
    return reste == 0 ? texte : '$texte et ${nombreFr(reste)} $centimes';
  }

  /// Nombre entier en lettres (orthographe traditionnelle avec traits d'union).
  static String nombreFr(int n) {
    if (n < 0) return 'moins ${nombreFr(-n)}';
    if (n < 100) return _moinsDeCent(n);
    if (n < 1000) return _centaines(n, finale: true);
    final parties = <String>[];
    var reste = n;
    for (final (valeur, nom) in [(1000000000, 'milliard'), (1000000, 'million'), (1000, 'mille')]) {
      final q = reste ~/ valeur;
      reste %= valeur;
      if (q == 0) continue;
      if (valeur == 1000) {
        parties.add(q == 1 ? 'mille' : '${_centaines(q, finale: false)} mille');
      } else {
        parties.add('${_centaines(q, finale: true)} $nom${q > 1 ? 's' : ''}');
      }
    }
    if (reste > 0) parties.add(_centaines(reste, finale: true));
    return parties.join(' ');
  }

  /// [finale] : « cents » / « quatre-vingts » prennent le pluriel en fin de nombre seulement.
  static String _centaines(int n, {required bool finale}) {
    final c = n ~/ 100;
    final r = n % 100;
    if (c == 0) return _moinsDeCent(r, finale: finale);
    final cent = c == 1 ? 'cent' : '${_unites[c]} cent${r == 0 && finale ? 's' : ''}';
    return r == 0 ? cent : '$cent ${_moinsDeCent(r, finale: finale)}';
  }

  static String _moinsDeCent(int n, {bool finale = true}) {
    if (n < 20) return _unites[n];
    final d = n ~/ 10;
    final u = n % 10;
    if (d == 7 || d == 9) {
      final base = d == 7 ? 'soixante' : 'quatre-vingt';
      final suite = _unites[10 + u];
      return d == 7 && u == 1 ? 'soixante et onze' : '$base-$suite';
    }
    if (d == 8) return u == 0 ? 'quatre-vingt${finale ? 's' : ''}' : 'quatre-vingt-${_unites[u]}';
    if (u == 0) return _dizaines[d];
    if (u == 1) return '${_dizaines[d]} et un';
    return '${_dizaines[d]}-${_unites[u]}';
  }
}
