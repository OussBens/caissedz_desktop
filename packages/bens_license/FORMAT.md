# Licence format v1

The dashboard's Licences sign with it on the server
(`api/app/Support/LicenseKeys.php`); apps check it with this package. How a
licence goes from the app to the dashboard and back: [Licences](../../docs/licences.md).

A BENS licence is a small record **signed with Ed25519** (RFC 8032) by the
product's private key. The app holds only the matching **public key**: it can
check licences but can't make one, so finding it in the app (it isn't hidden)
gives nobody a key generator. Each product has its own key pair.

## Device code

What the customer sends to get a licence, e.g. `SV-W8SW-VMYS`. It names what
the licence is bound to: a device, or for an app with accounts, the account.

```
prefix "-" group4( base32( SHA-256( utf8("<slug>:device:<raw id>") )[0..5] ) )
```

- `slug`: the product's id (`suivi-vidange`), `prefix` its code prefix (`SV`).
- `raw id`, bound to a **device**: Android `Settings.Secure.ANDROID_ID`;
  Windows `HKLM\SOFTWARE\Microsoft\Cryptography\MachineGuid`; Linux
  `/etc/machine-id` (`desktopMachineId()` in `package:bens_license/machine_id.dart`).
  It never leaves the device.
- `raw id`, bound to an **account** (CaisseDZ Mobile): the account's verified
  phone number in E.164 (`+213555123456`). The licence then works on any phone
  signed in to that account, and survives a new phone or a reinstall.
- 5 bytes (40 bits) → 8 characters.

## Base32

Crockford's alphabet `0123456789ABCDEFGHJKMNPQRSTVWXYZ` (no I, L, O, U), most
significant bit first, the last character padded with zero bits. Reading
input: upper-case it, drop everything but letters and digits, read `O` as `0`
and `I`/`L` as `1`. A decoder rejects non-zero padding bits.

## Payload (18 bytes, big-endian)

| Offset | Size | Field |
|---|---|---|
| 0 | 1 | version = `1` |
| 1 | 2 | product number (given by the dashboard when the product is added; in its app setup) |
| 3 | 4 | serial (the licence's number within its product) |
| 7 | 1 | tier number (0 when a product has one tier) |
| 8 | 2 | issue day: days since 2020-01-01 UTC |
| 10 | 2 | last valid day: days since 2020-01-01 UTC, `0` = never expires |
| 12 | 5 | device code bytes |
| 17 | 1 | flags: `0` (reserved; a v1 reader rejects anything else) |

## Signature and key

```
signature = Ed25519-sign(private key, utf8("BENS-LICENSE-1") ‖ payload)    // 64 bytes
key       = group4( base32( payload ‖ signature ) )                       // 82 bytes → 132 characters
```

The `BENS-LICENSE-1` prefix (domain separation) means no other signature made
with the key can pass for a licence.

## Checking (in the app)

1. Decode the key to 82 bytes; anything else is **invalid**.
2. Version 1 and flags 0, else **invalid**.
3. Verify the signature over `"BENS-LICENSE-1" ‖ payload` with the product's
   public key, else **invalid**.
4. Product number ≠ the app's: **wrong product**.
5. Device bytes ≠ this device's code (constant-time compare): **wrong device**.
6. If the app stored a later date than now (minus 2 days of tolerance):
   **clock rollback**. After each check the app stores `max(stored, now)`.
7. Now later than the end of the last valid day (UTC): **expired**.
8. Otherwise **valid**: unlock the tier.

`LicenseVerifier.check` in `package:bens_license` does exactly this.

## Test vectors

[`test/vectors.json`](test/vectors.json): seeds, licences, payloads and the
keys they must produce. They are checked by the Dart tests and were checked
against libsodium (PyNaCl), and by the API's tests (the PHP signing, with a
copy in `api/tests/fixtures/license-vectors.json`). Their seeds are public:
never use them for a product.

PHP (libsodium is built in):

```php
$raw = crockford_decode($key);                      // 82 bytes
$payload = substr($raw, 0, 18);
$sig = substr($raw, 18, 64);
$ok = sodium_crypto_sign_verify_detached($sig, 'BENS-LICENSE-1' . $payload, base64_decode($publicKey));
// signing, on a server: sodium_crypto_sign_detached($msg, sodium_crypto_sign_seed_keypair($seed) secret key)
```

## Limits (by design)

- An offline licence can't be revoked: once in the app, it works until it
  expires. Use expiry for subscriptions; apps that go online (Smart Scan) can
  also be refused by the server.
- The check runs on the customer's device: someone determined can patch it out
  of the app. Signed licences stop key generators and key sharing, not that.
  Release builds with `--obfuscate --split-debug-info` make patching harder.
