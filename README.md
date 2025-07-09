[Read this in German](README.de.md)

# MoneyMoney-Crypto-Extension

This extension for MoneyMoney allows you to easily track your crypto assets directly within the MoneyMoney application.

## 🚀 Key Features

- **Auto-Discovery**: SOL wallets automatically discover all SPL tokens
- **Multi-Wallet Support**: Track multiple addresses per cryptocurrency
- **No API Keys Required**: Uses free public APIs
- **Real-time Prices**: Powered by CoinGecko price data
- **Wide Compatibility**: Supports Bitcoin, Ethereum, Solana + all SPL tokens

## Extension Setup

1. **Configure Wallet Addresses**: Use the coin symbol followed by wallet address(es) in parentheses:
   ```
   BTC(bc1qtez37te8uk8mjfecdtqesg34qent6x04e467fp)
   ETH(0x6ea8F3531f785f369FAF6967A778f40215D1A3C7) 
   SOL(Bozp16Pd8qNvZ6puw5Y6J9qkqTmUqtnojCoQE7PkBrt6)
   ```

2. **Enter in Username Field**: Combine multiple wallets with comma and space:
   ```
   BTC(bc1q...), ETH(0x6ea8...), SOL(Bozp16...)
   ```

3. **Multiple Addresses**: For multiple addresses per coin, separate with commas:
   ```
   BTC(address1, address2), ETH(addr1, addr2)
   ```
   Balances from multiple addresses are automatically summed.

4. **Set Any Password**: Use `123` or any value to satisfy MoneyMoney requirements.

## 🪙 **SOL Auto-Discovery**

**NEW**: When you add a SOL wallet, the extension automatically discovers and tracks ALL SPL tokens in that wallet! 

Just add: `SOL(your-wallet-address)` and get:
- ✅ SOL balance
- ✅ All SPL tokens (PSOL, BONK, USDC, mSOL, etc.)  
- ✅ Real-time prices for all discovered tokens
- ✅ No need to manually add each token

## Supported Cryptocurrencies

### Native Blockchains
- **Bitcoin (BTC)** - Direct balance fetching
- **Ethereum (ETH)** - Direct balance fetching  
- **Solana (SOL)** - Direct balance fetching + **automatic SPL token discovery**

### SPL Tokens (Solana)
**Automatically discovered** when you add a SOL wallet:
- All SPL tokens with balance > 0
- Popular tokens: PSOL, BONK, USDC, USDT, mSOL, jSOL, RAY, etc.
- Powered by Jupiter API for token metadata

### ERC20 Tokens (Ethereum)
- **USDT** - Manual configuration required

### Legacy Support
- LTC, DOGE, BCH, BSV, IOTA - Price tracking via CoinGecko

## Which APIs are used?

- **CoinGecko API** - Price data for all cryptocurrencies
- **Blockcypher API** - Bitcoin and Ethereum balance queries
- **Solana JSON-RPC** - SOL balances and SPL token discovery
- **Jupiter API** - SPL token metadata and CoinGecko ID mapping

## Development

### What to do if your coin is not supported

If your coin is not supported, you can contribute by following the steps below:

1. Fork this repository.
2. Add support for the new coin by updating the `coins` table and adding necessary API calls.
3. Submit a pull request with a detailed description of your changes.

### How to contribute

1. Fork this repository.
2. Create a new branch for your feature or bugfix.
3. Make your changes and commit them with clear messages.
4. Push your changes to your fork.
5. Open a pull request and describe your changes in detail.

## Donations

If you like this extension, please consider a donation to the following addresses:

- **Bitcoin (BTC)**: `bc1qtez37te8uk8mjfecdtqesg34qent6x04e467fp`
- **Ethereum (ETH)**: `0x6ea8F3531f785f369FAF6967A778f40215D1A3C7`
- **Solana (SOL)**: `Bozp16Pd8qNvZ6puw5Y6J9qkqTmUqtnojCoQE7PkBrt6`
