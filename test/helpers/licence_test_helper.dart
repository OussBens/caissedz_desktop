import 'package:bens_license/issuer.dart';
import 'package:caissedz_desktop/application/licence_service.dart';
import 'package:caissedz_desktop/core/db/app_database.dart';
import 'package:caissedz_desktop/core/licence/compte_bens_api.dart';
import 'package:caissedz_desktop/core/licence/license_config.dart';
import 'package:caissedz_desktop/data/licence_repository.dart';
import 'package:caissedz_desktop/domain/permissions.dart';

/// Identifiant brut du poste des tests (son code : [codePosteTest]).
const String machineTest = 'POSTE-TEST';

/// Le poste des tests, sans lire le registre Windows.
class MachineLicenceTest implements MachineLicence {
  const MachineLicenceTest([this.id = machineTest]);
  final String id;
  @override
  Future<String> lire(LicenceRepository repo) async => id;
}

/// Signataire jetable des tests (jamais la clé du produit) : bens_ds docs/caissedz-desktop-licence.md → Tests.
Future<LicenseSigner> signataireTest() => LicenseSigner.fromSeed(List.filled(32, 1));

Future<LicenseVerifier> verificateurTest() async =>
    LicenseVerifier(product: licenseProduct, publicKey: (await signataireTest()).publicKey);

String codePosteTest([String rawId = machineTest]) =>
    '${DeviceCode.fromRawId(slug: licenseSlug, prefix: licensePrefix, rawId: rawId)}';

/// Une licence signée pour [poste] au palier [n] ; [fin] : son dernier jour (null : permanente).
Future<String> cleTest(
  NiveauLicence n, {
  DateTime? fin,
  String poste = machineTest,
  int produit = licenseProduct,
}) async => (await signataireTest()).sign(
  License(
    product: produit,
    serial: 1,
    tier: n.index,
    issuedOn: DateTime.utc(2026, 10, 1),
    expiresOn: fin,
    device: DeviceCode.fromRawId(slug: licenseSlug, prefix: licensePrefix, rawId: poste).bytes,
  ),
);

/// Le service de licence des tests : poste fixe, clés du signataire jetable, [api] (null : hors ligne).
Future<LicenceService> licenceServiceTest(AppDatabase base, {CompteBensApi? api, DateTime Function()? horloge}) async =>
    LicenceService(
      base.db,
      machine: const MachineLicenceTest(),
      verifier: await verificateurTest(),
      api: api,
      horloge: horloge,
    );
