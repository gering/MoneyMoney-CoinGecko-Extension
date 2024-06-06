[Lesen Sie dies auf Englisch](README.md)

# MoneyMoney-Krypto-Erweiterung

Diese Erweiterung für MoneyMoney ermöglicht es dir, deine Krypto-Assets direkt in der MoneyMoney-Anwendung zu verfolgen.

## Ziele dieser Erweiterung

- Eine einfache Möglichkeit bieten, deine Krypto-Assets in MoneyMoney zu verfolgen
- APIs verwenden, die keine API-Schlüssel erfordern
- Schließlich alle bekannten Kryptowährungen unterstützen

## Einrichtung der Erweiterung

1. Verwende das Symbol der Münze und die Adresse der Wallet.
2. Gib diese Werte in das Benutzerfeld ein, getrennt durch einen Doppelpunkt.
3. Setze das Passwort auf `123` oder einen anderen Wert, um von MoneyMoney nicht genervt zu werden.

## Unterstützte Coins

Ich habe die folgenden Coins getestet:

- BTC
- ETH
- SOL

Weitere Coins werden in Zukunft hinzugefügt. Falls ein Coin fehlt, den du benötigst, erstelle bitte ein Issue.

## Welche APIs werden verwendet?

- **CoinGecko** für die Preisdaten
- **Blockcypher** für Bitcoin- und Ethereum-Guthaben
- **Solana JSON-RPC** für Solana-Guthaben

## Entwicklung

### Was tun, wenn deine Münze nicht unterstützt wird

Wenn deine Münze nicht unterstützt wird, kannst du beitragen, indem du die folgenden Schritte ausführst:

1. Forke dieses Repository.
2. Füge Unterstützung für die neue Münze hinzu, indem du die `coins`-Tabelle aktualisierst und notwendige API-Aufrufe hinzufügst.
3. Reiche einen Pull-Request mit einer detaillierten Beschreibung deiner Änderungen ein.

### Wie du beitragen kannst

1. Forke dieses Repository.
2. Erstelle einen neuen Branch für dein Feature oder deinen Bugfix.
3. Nimm deine Änderungen vor und committe sie mit klaren Nachrichten.
4. Pushe deine Änderungen in deinen Fork.
5. Öffne einen Pull-Request und beschreibe deine Änderungen im Detail.

## Spenden

Wenn dir diese Erweiterung gefällt, erwäge bitte eine Spende an die folgenden Adressen:

- **Bitcoin (BTC)**: `bc1qtez37te8uk8mjfecdtqesg34qent6x04e467fp`
- **Ethereum (ETH)**: `0x6ea8F3531f785f369FAF6967A778f40215D1A3C7`
- **Solana (SOL)**: `Bozp16Pd8qNvZ6puw5Y6J9qkqTmUqtnojCoQE7PkBrt6`
