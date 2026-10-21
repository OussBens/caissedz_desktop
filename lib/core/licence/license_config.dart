/// CaisseDZ Desktop dans le tableau de bord BENS (Licence products → Copy app setup) : valeurs
/// publiques. Tant que [licensePublicKey] est vide, toute clé est refusée : créer le produit
/// (id `caissedz-desktop`, préfixe `CD`, Windows, « A PC, with an account », paliers
/// `Basic, Advanced, Ultra`) puis coller ici sa configuration. Jamais la clé d'un tableau de bord
/// local dans une version publiée (bens_ds docs/caissedz-desktop-licence.md).
library;

const licenseProduct = 1;
const licenseSlug = 'caissedz-desktop';
const licensePrefix = 'CD';
const licensePublicKey = 'JgY9yrRq3msvOB+u2A+lgC+LljTi+RPqxsAhRNJDruE=';

/// API BENS (comptes, offres, licences) : `--dart-define=BENS_API_URL=http://localhost:8090/api` en développement.
const bensApiUrl = String.fromEnvironment('BENS_API_URL', defaultValue: 'https://bensds.com/api');

/// WhatsApp de BENS Digital Solutions (envoi du code du poste, du code de récupération).
const bensWhatsApp = '213770951460';
