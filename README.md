# Címkenyomtató / Label Printer

## 1. Projekt leírás

Android tabletre és mobiltelefonra telepíthető címkenyomtató alkalmazás. Az alkalmazás egyetlen képernyőből áll, ahol a felhasználó megadhatja a nevet, várost, valamint az utcát és házszámot. A beírt adatok élő előnézetben jelennek meg egy címke formájában, majd a "Nyomtatás" gombbal PDF-ként kinyomtathatók az Android nyomtatás dialóguson keresztül.

## 2. Telepítés és futtatás
A projeketből le lett fordítva a készülékre telepíthető `app-release.apk` file, ami a `flutter-apk` mappában található.
AZ APK fájlok telepítése mobilon és tableten akkor lehetséges, ha az Android készüléken engedélyezzük az "ismeretlen forrásból" származó alkalmazások telepítését.

## 3. Használat

1. Indítsa el az alkalmazást Android eszközön.
2. Töltse ki a beviteli mezőket:
   - **Név** (pl. John Doe)
   - **Város** (pl. Hódmezővásárhely)
   - **Utca és házszám** (pl. Kossuth utca 42)
3. Az előnézeti kártyán valós időben láthatja a címke tartalmát.
4. Ha minden mező ki van töltve, akkor a **Nyomtatás** gomb aktívvá válik.
5. A gomb megérintésére megnyílik az Android nyomtatás dialógus, ahol kiválaszthatja a nyomtatót vagy elmentheti PDF-ként.

## 4. Implementált funkciók

- **Adatbevitel:** Három szöveges beviteli mező form validációval (üres mezők nem engedélyezettek)
- **Élő előnézet:** A címke tartalma valós időben frissül a mezők kitöltése közben
- **PDF generálás:** 100×60 mm-es címke méret, Roboto fonttal (magyar ékezetek teljes támogatása)
- **Nyomtatás:** Android natív nyomtatás dialógus a `printing` package segítségével
- **Responzív layout:** Telefonon egymás alatt, tableten vagy landscape nézet mobilon (azaz ≥ 600px) egymás mellett jelenik meg az űrlap és az előnézet

## 5. Technológiai stack
- Flutter - UI keretrendszer
- Dart - Programozási nyelv

Flutter és Dart Package-k:
- pdf - PDF dokumentum generálás
- printing - Nyomtatás dialógus és nyomtató kezelés

Assets:
- Roboto TTF - font, ez a pdf-ben a magyar ékezetes karakterek támogatása miatt szükséges

### Projekt struktúra
```
lib/
├── main.dart                  # Alkalmazás belépési pont
├── models/
│   └── label_data.dart        # Címke adatmodell
├── screens/
│   └── label_screen.dart      # Fő képernyő (bevitel + előnézet + nyomtatás)
└── services/
    └── print_service.dart     # PDF generálás és nyomtatás szolgáltatás
```

## 6. Valós címkenyomtató támogatás

### Miért nem elég a jelenlegi specifikáció?

Az alkalmazás jelenleg az Android natív nyomtatás rendszerét használja (`printing` package), amely az operációs rendszer beépített nyomtatás-kezelőjén keresztül működik - hasonlóan ahhoz, ahogy egy asztali OS-en is a nyomtató driver-en keresztül érjük el a nyomtatót. Ez hálózati és USB nyomtatók esetén működik, amennyiben az Android rendszer ismeri az adott nyomtatót.

**Azonban a valós címkenyomtatók (termál nyomtatók, Zebra, Brother, Dymo stb.) tipikusan nem az OS nyomtatás-kezelőjén keresztül működnek.** Ahogy bármely operációs rendszernél, a különböző típusú nyomtatókhoz egyedi driver (vagy annak megfelelő package/protokoll implementáció) szükséges. Egy Bluetooth termál nyomtató teljesen más protokollon kommunikál, mint egy Zebra ZPL nyomtató vagy egy hálózati ESC/POS eszköz.

Éles környezetben tehát a feladat specifikációját a következőkkel kellene kiegészíteni:
1. **A konkrét nyomtató típus/modell megadása** - ez határozza meg, melyik kommunikációs protokollt és package-et kell használni
2. **A kapcsolódás módja** - Bluetooth, WiFi, USB vagy hálózati (TCP/IP)
3. **A címke mérete és formátuma** - a nyomtató által támogatott címke paraméterek

### Nyomtató beállítási panel szükségessége

Amennyiben az alkalmazásnak több nyomtató típust is támogatnia kell (vagy akár egyetlen konkrét típust), egy **beállítási képernyő (Settings)** elengedhetetlen, ahol a felhasználó konfigurálhatja a nyomtatót:
- WiFi / Hálózat: IP-cím, port szám
- Bluetooth esetén  - eszközpárosítás
- Címke méret (szélesség × magasság mm-ben)
- Nyomtatási sötétség/kontraszt
- Nyomtatási sebesség
- Karakter kódolás és betűtípus (különösen fontos magyar ékezeteknél)
- Automatikus vágás engedélyezése
- stb...

### Szerviz réteg architektúra

Több nyomtató típus támogatása esetén az alkalmazás architektúráját úgy kell kialakítani, hogy minden nyomtató típushoz **külön szerviz implementáció** tartozzon, egy közös interfész mögött:

```
lib/
├── services/
│   ├── printer_service.dart          # Absztrakt interfész (közös API)
│   ├── android_print_service.dart    # Android natív nyomtatás (jelenlegi, PDF alapú)
│   ├── bluetooth_print_service.dart  # Bluetooth termál nyomtatók
│   ├── zebra_print_service.dart      # Zebra ZPL nyomtatók
│   └── escpos_print_service.dart     # ESC/POS hálózati nyomtatók
├── screens/
│   ├── label_screen.dart             # Fő képernyő (jelenlegi)
│   └── printer_settings_screen.dart  # Nyomtató beállítások képernyő
└── models/
    ├── label_data.dart               # Címke adatmodell (jelenlegi)
    └── printer_config.dart           # Nyomtató konfiguráció modell
```

Az absztrakt `PrinterService` interfész biztosítja, hogy az alkalmazás üzleti logikája ne függjön a konkrét nyomtatótól:

```dart
abstract class PrinterService {
  Future<List<PrinterDevice>> discoverPrinters();
  Future<void> connect(PrinterDevice device);
  Future<void> printLabel(LabelData label);
  Future<void> disconnect();
}
```

Minden nyomtató típushoz ennek az interfésznek a saját implementációja készül, a megfelelő package és protokoll használatával.

### Például elérhető Flutter package-ek nyomtató típusonként
A lista a teljesség igénye nélkül készült, próbáltam aktívan karbantartott package-eket keresni.
#### Bluetooth termál nyomtatók
- **[`flutter_bluetooth_printer`](https://pub.dev/packages/flutter_bluetooth_printer)**: Bluetooth termál nyomtatók támogatása
  - Képalapú nyomtatás Bluetooth termál nyomtatókra
  - PDF és kép közvetlen nyomtatása
  - ESC/POS parancs támogatás

#### Zebra nyomtatók
- **[`zebrautil`](https://pub.dev/packages/zebrautil)**: Flutter plugin Zebra nyomtatók kezeléséhez
  - Bluetooth és WiFi printer discovery (Android), Bluetooth (iOS)
  - ZPL (Zebra Programming Language) parancsok küldése
  - Média típus beállítás (Label, Journal, BlackMark), sötétség, kalibrálás

#### ESC/POS hálózati nyomtatók
- **[`esc_pos_printer_plus`](https://pub.dev/packages/esc_pos_printer_plus)**: Az `esc_pos_printer` aktívan karbantartott továbbfejlesztése
  - POS blokk- és címkenyomtatók támogatása
  - Hálózati (WiFi/Ethernet) kapcsolat
  - Szöveg formázás (félkövér, aláhúzott, igazítás, méretezés)
  - QR kód és kép nyomtatás
  - Speciális karakter kódolás támogatás

## 7. Fejlesztési javaslatok

- **Backend integráció:** A címke adatok REST API-n keresztül is betölthetők lennének (pl. raktári rendszerből, CRM-ből)
- **Bejelentkezés:** API-n keresztüli hitelesítés, hogy a felhasználó a saját címkéit láthassa
- **Tömeges nyomtatás:** Több címke egyszerre történő nyomtatása listából
- **Címke sablonok:** Különböző címke méretek és elrendezések támogatása
- **Nyomtatási előzmények:** Korábban nyomtatott címkék mentése és újranyomtatása
- **Vonalkód/QR kód:** Vonalkód vagy QR kód hozzáadása a címkéhez
- **Offline mód:** Helyi adatbázisban tárolt címkék nyomtatása internetkapcsolat nélkül

## 8. Fejlesztői jegyzetek

Ez az alkalmazás egy felvételi feladat részeként készült, ahol a követelmény PHP ismereteket is tartalmazott. Ezért érdemes említést tenni a **NativePHP**-ről, ami támogtaja a mobil fejlesztést PHP alapakon.

### NativePHP Mobile
A [NativePHP](https://nativephp.com/docs/mobile/3/getting-started/introduction) egy viszonylag új keretrendszer. A mobil támogatása nemrég vált ingyenessé.

**Előnyök:**
- PHP/Laravel fejlesztők számára ismerős szintaxis és koncepciók
- Meglévő Laravel backend kód részleges újrafelhasználása
- Webes és mobil alkalmazás közös kódbázisból

**Hátrányok:**
- Még nem széles körben elterjedt, a közösség kisebb
- Kevesebb natív eszköz integráció (pl. Bluetooth nyomtatók)
- Kevesebb dokumentáció és harmadik féltől származó package

A NativePHP-val egyenlőre nincs tapasztalatom, így olyan technológiát választottam, amit ismerek. 
Szerintem a Flutter-ben való fejlesztés mellett szól a rengetek package (különösen a nyomtató integráció terén) és hogy széleskörben elterjedt és kiforrottabb.


