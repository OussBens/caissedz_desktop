/// Fiches qui se suppriment quand elles n'ont aucun historique, et s'archivent sinon (migration v43).
///
/// - [table] : table SQL de la fiche (aussi l'entité journalisée dans `historique`).
/// - [colonnes] : noms des colonnes qui portent son code ailleurs (avec ou sans clé étrangère).
/// - [possedees] : tables de détail qui appartiennent à la fiche (photos, droits, rattachements…) ; supprimées
///   avec elle, elles ne comptent pas comme un historique.
/// - [colonneNom] : nom unique parmi les fiches non archivées (une fiche archivée libère son nom).
enum EntiteArchivable {
  produit(
    'produit',
    'designation',
    {'produit_code'},
    {'produit_code_detail', 'produit_photo', 'colis', 'favori_caisse'},
  ),
  pack('pack', 'designation', {'pack_code'}, {'pack_ligne'}),
  client('client', 'nom', {'client_code'}),
  fournisseur('fournisseur', 'nom', {'fournisseur_code'}),
  magasin('magasin', 'nom', {'magasin_code', 'magasin_source', 'magasin_destination'}, {'utilisateur_magasin'}),
  caisse('caisse', 'nom', {'caisse_code', 'caisse_source', 'caisse_destination'}),
  utilisateur(
    'utilisateur',
    'identifiant',
    {
      'utilisateur_code',
      'cree_par',
      'modifie_par',
      'annule_par',
      'annulee_par',
      'archive_par',
      'responsable_code',
      'dernier_utilisateur',
    },
    {'utilisateur_magasin', 'appareil_mobile', 'audit_contexte'},
  ),
  role('role', 'nom', {'role_code'}, {'role_permission', 'role_module'});

  const EntiteArchivable(this.table, this.colonneNom, this.colonnes, [this.possedees = const {}]);

  final String table;
  final String colonneNom;
  final Set<String> colonnes;
  final Set<String> possedees;
}

/// Raison pour laquelle une fiche ne peut être ni supprimée ni archivée (ou restaurée).
enum BlocageArchivage {
  /// Élément système (MAG0000, CIS0000, CLN0000, FOR0000, compte et rôle Admin…).
  systeme,
  inconnu,

  /// Produit ou magasin : du stock reste (le ramener à zéro par un inventaire ou un transfert d'abord).
  stockNonNul,

  /// Produit : composant d'un pack non archivé.
  dansPack,

  /// Client ou fournisseur : solde non nul (crédit ou avance à régler d'abord).
  soldeNonNul,

  /// Magasin : magasin principal d'un utilisateur.
  magasinPrincipal,

  /// Caisse : session ouverte.
  sessionOuverte,

  /// Caisse : solde non nul (à transférer d'abord).
  soldeCaisse,

  /// Utilisateur : compte connecté.
  compteCourant,

  /// Rôle : des comptes non archivés l'utilisent.
  utilisateursRattaches,

  /// Restauration : le palier de la licence n'a plus de place (magasins, caisses, caissiers).
  limiteLicence,

  /// Restauration : une fiche active porte déjà ce nom (renommer l'une des deux d'abord).
  nomPris,

  /// Archivage d'une fiche déjà archivée, ou restauration d'une fiche qui ne l'est pas.
  etatInchange,
}

/// Ce que la suppression fera d'une fiche : la supprimer (aucun historique), l'archiver, ou rien ([blocage]).
class IssueSuppression {
  const IssueSuppression({required this.code, required this.archivage, this.blocage});
  final String code;

  /// Vrai : la fiche a un historique, elle sera archivée au lieu d'être supprimée.
  final bool archivage;
  final BlocageArchivage? blocage;
}

class ArchivageException implements Exception {
  const ArchivageException(this.blocage, this.code);
  final BlocageArchivage blocage;
  final String code;
  @override
  String toString() => 'ArchivageException($blocage, $code)';
}
