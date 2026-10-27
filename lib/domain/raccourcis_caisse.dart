import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Actions de l'écran de caisse déclenchables au clavier (Paramètres › Raccourcis clavier).
enum ActionCaisse {
  aide,
  scanner,
  rechercheAvancee,
  encaisser,
  enregistrer,
  client,
  remise,
  calculatrice,
  vider,
  produits,
  ventesDuJour,
  nouveauPanier,
  panierSuivant,
  entreeRapide,
  retirerLigne,
  quantitePlus,
  quantiteMoins,
  lignePrecedente,
  ligneSuivante;

  /// Actions sur la ligne sélectionnée du panier.
  bool get surLigne => this == retirerLigne || this == quantitePlus || this == quantiteMoins;
}

/// Une touche, avec ou sans Ctrl / Maj / Alt. Les touches du pavé numérique et leur jumelle du clavier principal
/// (`+`, `-`, `*`, `/`, `.`) sont une seule et même touche : chacune déclenche le raccourci de l'autre.
@immutable
class ToucheRaccourci {
  const ToucheRaccourci(this.touche, {this.ctrl = false, this.shift = false, this.alt = false});

  final LogicalKeyboardKey touche;
  final bool ctrl;
  final bool shift;
  final bool alt;

  static final Map<LogicalKeyboardKey, LogicalKeyboardKey> _jumelles = {
    LogicalKeyboardKey.numpadAdd: LogicalKeyboardKey.add,
    LogicalKeyboardKey.numpadSubtract: LogicalKeyboardKey.minus,
    LogicalKeyboardKey.numpadMultiply: LogicalKeyboardKey.asterisk,
    LogicalKeyboardKey.numpadDivide: LogicalKeyboardKey.slash,
    LogicalKeyboardKey.numpadDecimal: LogicalKeyboardKey.period,
    LogicalKeyboardKey.numpadEnter: LogicalKeyboardKey.enter,
    LogicalKeyboardKey.numpadEqual: LogicalKeyboardKey.equal,
  };

  static LogicalKeyboardKey normaliser(LogicalKeyboardKey k) => _jumelles[k] ?? k;

  static final Set<LogicalKeyboardKey> _modificateurs = {
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.controlLeft,
    LogicalKeyboardKey.controlRight,
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.shiftRight,
    LogicalKeyboardKey.alt,
    LogicalKeyboardKey.altLeft,
    LogicalKeyboardKey.altRight,
    LogicalKeyboardKey.meta,
    LogicalKeyboardKey.metaLeft,
    LogicalKeyboardKey.metaRight,
    LogicalKeyboardKey.capsLock,
    LogicalKeyboardKey.numLock,
    LogicalKeyboardKey.scrollLock,
    LogicalKeyboardKey.fn,
  };

  /// Ctrl, Maj, Alt, Windows, verrouillages : ne forment pas un raccourci à eux seuls.
  static bool estModificateur(LogicalKeyboardKey k) => _modificateurs.contains(k);

  static final Set<LogicalKeyboardKey> _edition = {
    LogicalKeyboardKey.delete,
    LogicalKeyboardKey.backspace,
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.home,
    LogicalKeyboardKey.end,
    LogicalKeyboardKey.insert,
    LogicalKeyboardKey.pageUp,
    LogicalKeyboardKey.pageDown,
  };

  bool get _modifiee => ctrl || alt;

  /// Touche qui écrit un caractère dans un champ de saisie (lettre, chiffre, ponctuation, pavé numérique).
  bool get ecritCaractere {
    if (_modifiee) return false;
    final k = normaliser(touche);
    return (k.keyId & LogicalKeyboardKey.planeMask) == LogicalKeyboardKey.unicodePlane ||
        k.keyLabel.startsWith('Numpad');
  }

  /// Lettre ou chiffre (le début possible d'un code saisi ou scanné).
  bool get estAlphanumerique => ecritCaractere && RegExp(r'^[\p{L}\p{N}]$', unicode: true).hasMatch(_caractere);

  String get _caractere {
    final k = normaliser(touche);
    if (k.keyLabel.startsWith('Numpad ')) return k.keyLabel.substring(7);
    return k.keyLabel;
  }

  /// Touche d'édition d'un champ de saisie (Suppr, flèches, Début, Fin…).
  bool get estEdition => !_modifiee && _edition.contains(touche);

  /// Raccourci impossible : touches réservées à la saisie et à la validation (Entrée, Échap, Tab, Retour arrière,
  /// Espace), aux copier-coller des champs (Ctrl+A / C / V / X / Y / Z) et à Windows (Alt+F4, Alt+Tab).
  bool get estInterdite {
    final k = normaliser(touche);
    if (estModificateur(k)) return true;
    if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.escape) return true;
    if (alt && (k == LogicalKeyboardKey.f4 || k == LogicalKeyboardKey.tab)) return true;
    if (!_modifiee &&
        (k == LogicalKeyboardKey.tab || k == LogicalKeyboardKey.backspace || k == LogicalKeyboardKey.space)) {
      return true;
    }
    if (ctrl &&
        !alt &&
        {
          LogicalKeyboardKey.keyA,
          LogicalKeyboardKey.keyC,
          LogicalKeyboardKey.keyV,
          LogicalKeyboardKey.keyX,
          LogicalKeyboardKey.keyY,
          LogicalKeyboardKey.keyZ,
        }.contains(k)) {
      return true;
    }
    return false;
  }

  /// Maj est ignorée pour un symbole sans Ctrl / Alt (`+` s'obtient avec ou sans Maj selon le clavier).
  bool get _shiftIgnore => !_modifiee && ecritCaractere && !estAlphanumerique;

  /// L'événement clavier [k] (avec l'état des modificateurs) déclenche-t-il ce raccourci ?
  bool correspond(LogicalKeyboardKey k, {required bool ctrl, required bool shift, required bool alt}) =>
      normaliser(k) == normaliser(touche) &&
      ctrl == this.ctrl &&
      alt == this.alt &&
      (_shiftIgnore || shift == this.shift);

  /// Forme stockée (table `parametre`) : `ctrl+shift+alt+<keyId hexadécimal>`.
  String encoder() =>
      [if (ctrl) 'ctrl', if (shift && !_shiftIgnore) 'shift', if (alt) 'alt', touche.keyId.toRadixString(16)].join('+');

  static ToucheRaccourci? decoder(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    final parties = s.trim().split('+');
    final id = int.tryParse(parties.last, radix: 16);
    if (id == null) return null;
    final touche = LogicalKeyboardKey.findKeyByKeyId(id) ?? LogicalKeyboardKey(id);
    final mods = parties.sublist(0, parties.length - 1).toSet();
    return ToucheRaccourci(
      touche,
      ctrl: mods.contains('ctrl'),
      shift: mods.contains('shift'),
      alt: mods.contains('alt'),
    );
  }

  static final Map<LogicalKeyboardKey, String> _noms = {
    LogicalKeyboardKey.delete: 'Suppr',
    LogicalKeyboardKey.insert: 'Inser',
    LogicalKeyboardKey.home: 'Début',
    LogicalKeyboardKey.end: 'Fin',
    LogicalKeyboardKey.pageUp: 'Pg↑',
    LogicalKeyboardKey.pageDown: 'Pg↓',
    LogicalKeyboardKey.arrowUp: '↑',
    LogicalKeyboardKey.arrowDown: '↓',
    LogicalKeyboardKey.arrowLeft: '←',
    LogicalKeyboardKey.arrowRight: '→',
    LogicalKeyboardKey.tab: 'Tab',
    LogicalKeyboardKey.space: 'Espace',
    LogicalKeyboardKey.enter: 'Entrée',
    LogicalKeyboardKey.escape: 'Échap',
    LogicalKeyboardKey.backspace: '⌫',
    LogicalKeyboardKey.add: '+',
    LogicalKeyboardKey.minus: '−',
    LogicalKeyboardKey.asterisk: '*',
    LogicalKeyboardKey.slash: '/',
  };

  /// Libellé affiché (`Ctrl+N`, `F4`, `Suppr`, `+`…).
  String get libelle {
    final k = normaliser(touche);
    final nom = _noms[k] ?? (k.keyLabel.startsWith('Numpad ') ? 'Num ${k.keyLabel.substring(7)}' : k.keyLabel);
    return [
      if (ctrl) 'Ctrl',
      if (shift && !_shiftIgnore) 'Maj',
      if (alt) 'Alt',
      nom.length == 1 ? nom.toUpperCase() : nom,
    ].join('+');
  }

  @override
  bool operator ==(Object other) =>
      other is ToucheRaccourci &&
      normaliser(other.touche) == normaliser(touche) &&
      other.ctrl == ctrl &&
      other.alt == alt &&
      (other.shift == shift || _shiftIgnore);

  @override
  int get hashCode => Object.hash(normaliser(touche), ctrl, alt, _shiftIgnore ? null : shift);

  @override
  String toString() => libelle;
}

/// Raccourcis clavier de la caisse : exactement une touche par action, et une touche ne sert qu'à une action.
@immutable
class RaccourcisCaisse {
  const RaccourcisCaisse._(this._touches);

  final Map<ActionCaisse, ToucheRaccourci> _touches;

  static const String prefixe = 'raccourci_caisse_';
  static String cle(ActionCaisse a) => '$prefixe${a.name}';
  static List<String> get cles => [for (final a in ActionCaisse.values) cle(a)];

  static final Map<ActionCaisse, ToucheRaccourci> touchesDefaut = {
    ActionCaisse.aide: const ToucheRaccourci(LogicalKeyboardKey.f1),
    ActionCaisse.scanner: const ToucheRaccourci(LogicalKeyboardKey.f2),
    ActionCaisse.rechercheAvancee: const ToucheRaccourci(LogicalKeyboardKey.f3),
    ActionCaisse.encaisser: const ToucheRaccourci(LogicalKeyboardKey.f4),
    ActionCaisse.enregistrer: const ToucheRaccourci(LogicalKeyboardKey.f6),
    ActionCaisse.client: const ToucheRaccourci(LogicalKeyboardKey.f7),
    ActionCaisse.remise: const ToucheRaccourci(LogicalKeyboardKey.f8),
    ActionCaisse.calculatrice: const ToucheRaccourci(LogicalKeyboardKey.f9),
    ActionCaisse.vider: const ToucheRaccourci(LogicalKeyboardKey.f10),
    ActionCaisse.produits: const ToucheRaccourci(LogicalKeyboardKey.f11),
    ActionCaisse.ventesDuJour: const ToucheRaccourci(LogicalKeyboardKey.f12),
    ActionCaisse.nouveauPanier: const ToucheRaccourci(LogicalKeyboardKey.keyN, ctrl: true),
    ActionCaisse.panierSuivant: const ToucheRaccourci(LogicalKeyboardKey.tab, ctrl: true),
    ActionCaisse.entreeRapide: const ToucheRaccourci(LogicalKeyboardKey.keyE),
    ActionCaisse.retirerLigne: const ToucheRaccourci(LogicalKeyboardKey.delete),
    ActionCaisse.quantitePlus: const ToucheRaccourci(LogicalKeyboardKey.numpadAdd),
    ActionCaisse.quantiteMoins: const ToucheRaccourci(LogicalKeyboardKey.numpadSubtract),
    ActionCaisse.lignePrecedente: const ToucheRaccourci(LogicalKeyboardKey.arrowUp),
    ActionCaisse.ligneSuivante: const ToucheRaccourci(LogicalKeyboardKey.arrowDown),
  };

  static final RaccourcisCaisse defaut = RaccourcisCaisse._(Map.unmodifiable(touchesDefaut));

  /// Lecture des clés `raccourci_caisse_*` : une valeur absente, illisible, interdite ou déjà prise par une autre
  /// action reprend sa touche par défaut (une collision éventuelle rend [valide] faux : l'écran Paramètres la
  /// signale et refuse de l'enregistrer).
  factory RaccourcisCaisse.depuisCles(Map<String, String?> m) {
    final touches = <ActionCaisse, ToucheRaccourci>{};
    final lues = <ActionCaisse, ToucheRaccourci>{
      for (final a in ActionCaisse.values)
        if (ToucheRaccourci.decoder(m[cle(a)]) case final t? when !t.estInterdite) a: t,
    };
    for (final a in ActionCaisse.values) {
      final t = lues[a];
      if (t != null && !touches.containsValue(t)) touches[a] = t;
    }
    for (final a in ActionCaisse.values) {
      touches.putIfAbsent(a, () => touchesDefaut[a]!);
    }
    return RaccourcisCaisse._(Map.unmodifiable(touches));
  }

  Map<String, String> versCles() => {for (final MapEntry(:key, :value) in _touches.entries) cle(key): value.encoder()};

  ToucheRaccourci touche(ActionCaisse a) => _touches[a] ?? touchesDefaut[a]!;

  /// Libellé de la touche de [a] (`F4`, `Ctrl+N`…), pour les infobulles et l'aide.
  String libelle(ActionCaisse a) => touche(a).libelle;

  bool estDefaut(ActionCaisse a) => touche(a) == touchesDefaut[a];

  bool get toutParDefaut => ActionCaisse.values.every(estDefaut);

  /// L'autre action qui utilise déjà [t], le cas échéant.
  ActionCaisse? utiliseePar(ToucheRaccourci t, {ActionCaisse? sauf}) =>
      _touches.entries.where((e) => e.key != sauf && e.value == t).firstOrNull?.key;

  RaccourcisCaisse avec(ActionCaisse a, ToucheRaccourci t) => RaccourcisCaisse._(Map.unmodifiable({..._touches, a: t}));

  /// L'action déclenchée par l'événement clavier (touche + modificateurs enfoncés).
  ActionCaisse? actionPour(LogicalKeyboardKey k, {required bool ctrl, required bool shift, required bool alt}) =>
      _touches.entries.where((e) => e.value.correspond(k, ctrl: ctrl, shift: shift, alt: alt)).firstOrNull?.key;

  /// Chaque action a une touche autorisée, et aucune touche n'est partagée.
  bool get valide {
    final vues = <ToucheRaccourci>{};
    for (final a in ActionCaisse.values) {
      final t = _touches[a];
      if (t == null || t.estInterdite || !vues.add(t)) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      other is RaccourcisCaisse && ActionCaisse.values.every((a) => other.touche(a) == touche(a));

  @override
  int get hashCode => Object.hashAll([for (final a in ActionCaisse.values) touche(a)]);
}
