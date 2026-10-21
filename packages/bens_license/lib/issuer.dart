/// Making licences, for tests: an app's tests sign with a throwaway seed. Real
/// licences are signed by the dashboard's API (api/app/Support/LicenseKeys.php),
/// which holds the products' private keys. Apps import `bens_license.dart`.
library;

export 'bens_license.dart';
export 'src/signer.dart';
