[Lesen Sie dies auf Englisch](README.md)

# MoneyMoney-Krypto-Erweiterung

Diese Erweiterung für MoneyMoney ermöglicht es dir, deine Krypto-Assets direkt in der MoneyMoney-Anwendung zu verfolgen.

## 🚀 Hauptfunktionen

- **Auto-Erkennung**: SOL Wallets erkennen automatisch alle SPL-Token
- **Multi-Wallet-Support**: Verfolge mehrere Adressen pro Kryptowährung
- **Keine API-Schlüssel nötig**: Nutzt kostenlose öffentliche APIs
- **Echtzeitpreise**: Powered by CoinGecko Preisdaten
- **Breite Kompatibilität**: Unterstützt Bitcoin, Ethereum, Solana + alle SPL-Token

## Einrichtung der Erweiterung

1. **Wallet-Adressen konfigurieren**: Verwende das Coin-Symbol gefolgt von Wallet-Adresse(n) in Klammern:
   ```
   BTC(bc1qtez37te8uk8mjfecdtqesg34qent6x04e467fp)
   ETH(0x6ea8F3531f785f369FAF6967A778f40215D1A3C7) 
   SOL(Bozp16Pd8qNvZ6puw5Y6J9qkqTmUqtnojCoQE7PkBrt6)
   ```

2. **In Benutzerfeld eingeben**: Kombiniere mehrere Wallets mit Komma und Leerzeichen:
   ```
   BTC(bc1q...), ETH(0x6ea8...), SOL(Bozp16...)
   ```

3. **Mehrere Adressen**: Für mehrere Adressen pro Coin, trenne mit Kommas:
   ```
   BTC(adresse1, adresse2), ETH(addr1, addr2)
   ```
   Guthaben von mehreren Adressen werden automatisch summiert.

4. **Beliebiges Passwort setzen**: Verwende `123` oder einen beliebigen Wert für MoneyMoney.

## 🪙 **SOL Auto-Erkennung**

**NEU**: Wenn du eine SOL Wallet hinzufügst, erkennt die Erweiterung automatisch ALLE SPL-Token in dieser Wallet! 

Einfach hinzufügen: `SOL(deine-wallet-adresse)` und erhalte:
- ✅ SOL Guthaben
- ✅ Alle SPL-Token (PSOL, BONK, USDC, mSOL, etc.)  
- ✅ Echtzeitpreise für alle erkannten Token
- ✅ Keine manuelle Konfiguration jedes Tokens nötig

## Unterstützte Kryptowährungen

### Native Blockchains
- **Bitcoin (BTC)** - Direkte Guthaben-Abfrage
- **Ethereum (ETH)** - Direkte Guthaben-Abfrage  
- **Solana (SOL)** - Direkte Guthaben-Abfrage + **automatische SPL-Token-Erkennung**

### SPL-Token (Solana)
**Automatisch erkannt** wenn du eine SOL Wallet hinzufügst:
- Alle SPL-Token mit Guthaben > 0
- Beliebte Token: PSOL, BONK, USDC, USDT, mSOL, jSOL, RAY, etc.
- Powered by Jupiter API für Token-Metadaten

### ERC20-Token (Ethereum)
- **USDT** - Manuelle Konfiguration erforderlich

### Legacy-Unterstützung
- LTC, DOGE, BCH, BSV, IOTA - Preisverfolgung über CoinGecko

## Welche APIs werden verwendet?

- **CoinGecko API** - Preisdaten für alle Kryptowährungen
- **Blockcypher API** - Bitcoin- und Ethereum-Guthaben-Abfragen
- **Solana JSON-RPC** - SOL-Guthaben und SPL-Token-Erkennung
- **Jupiter API** - SPL-Token-Metadaten und CoinGecko-ID-Mapping

## Entwicklung

### Was tun, wenn deine Kryptowährung nicht unterstützt wird

**Für Native Coins (BTC, ETH, etc.):**
Wenn deine Kryptowährung nicht unterstützt wird, kannst du beitragen:

1. Forke dieses Repository
2. Füge die neue Münze zur `coins`-Tabelle hinzu (Name und CoinGecko-ID)
3. Erweitere `nativeCoinConfig` mit der entsprechenden API-Konfiguration
4. Implementiere ggf. eine neue Balance-Abfrage-Funktion
5. Reiche einen Pull-Request mit detaillierter Beschreibung ein

**Für SPL-Token (Solana):**
Keine Arbeit nötig! SPL-Token werden automatisch erkannt, wenn sie in deiner SOL-Wallet sind.

**Für ERC20-Token (Ethereum):**
Für die häufigsten ERC20-Token können wir gerne Unterstützung hinzufügen:

1. Erstelle ein Issue mit dem Token-Namen und Contract-Adresse
2. Oder füge den Token zur `contractERC20Addresses`-Tabelle hinzu
3. Reiche einen Pull-Request ein

### Wie du beitragen kannst

1. **Forke** dieses Repository
2. **Erstelle** einen neuen Branch für dein Feature oder Bugfix
3. **Implementiere** deine Änderungen mit klaren Commit-Nachrichten
4. **Teste** deine Änderungen mit echten Wallet-Adressen
5. **Pushe** deine Änderungen in deinen Fork
6. **Öffne** einen Pull-Request mit detaillierter Beschreibung

### Entwickler-Tipps

- **Keine API-Schlüssel verwenden** - Die Extension soll kostenlos bleiben
- **Fehlermeldungen auf Deutsch** - Nutze MM.localizeText wenn möglich
- **Teste mit echten Wallets** - Verwende deine eigenen Adressen zum Testen
- **Performance beachten** - Nur Token mit Guthaben > 0 anzeigen

## Spenden

Wenn dir diese Erweiterung gefällt, erwäge bitte eine Spende an die folgenden Adressen:

- **Bitcoin (BTC)**: `bc1qtez37te8uk8mjfecdtqesg34qent6x04e467fp`
- **Ethereum (ETH)**: `0x6ea8F3531f785f369FAF6967A778f40215D1A3C7`
- **Solana (SOL)**: `Bozp16Pd8qNvZ6puw5Y6J9qkqTmUqtnojCoQE7PkBrt6`
