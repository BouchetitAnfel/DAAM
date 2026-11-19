# Pharma app – TP3 Ex 01 + Ex 02

## Setup
1. `flutter create .`   (inside this folder – generates android/ios folders, keeps lib/ and pubspec.yaml)
2. `flutter pub get`
3. Edit `lib/config.dart` (port, https on/off, host for a real phone)
4. `flutter run`

## Android permissions
`android/app/src/main/AndroidManifest.xml` must contain (above <application>):
    <uses-permission android:name="android.permission.INTERNET"/>
(Only needed for release builds; debug has it already.)

## SSL – why it failed & the fix
Problems:
1. **Self-signed cert** → Dart throws `HandshakeException: CERTIFICATE_VERIFY_FAILED`.
   Fixed in `lib/services/api_client.dart`: the HttpClient accepts the bad cert ONLY for your own backend host:port.
2. **`localhost` on the Android emulator is the emulator itself** → use `10.0.2.2` (done automatically in config.dart).
   On a real phone use your PC's LAN IP (`kPhysicalDeviceHost`), phone & PC on the same Wi‑Fi, Windows firewall allowing port 3000.
3. Server must listen on all interfaces and the cert should include that IP/host (SAN). Regenerate if needed:

```
openssl req -x509 -newkey rsa:2048 -nodes -keyout key.pem -out cert.pem -days 365 \
  -subj "/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1,IP:10.0.2.2,IP:192.168.1.XX"
```
bin/www (https):
```js
const https = require('https'), fs = require('fs');
const server = https.createServer({ key: fs.readFileSync('key.pem'), cert: fs.readFileSync('cert.pem') }, app);
server.listen(3000, '0.0.0.0');
```
Also: if `kUseHttps = true` but the server is still plain HTTP (or vice-versa) you get a handshake error → they must match.
In production use a real CA cert and remove `badCertificateCallback`.
