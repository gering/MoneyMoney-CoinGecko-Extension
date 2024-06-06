[Read this in German](README.de.md)

# MoneyMoney-Crypto-Extension

This extension for MoneyMoney allows you to easily track your crypto assets directly within the MoneyMoney application.

## Goals of this extension

- Provide a simple way to track your crypto assets in MoneyMoney
- Use APIs that do not require API keys
- Support all well-known cryptocurrencies eventually

## Extension Setup

1. Use the symbol of the coin and the address of the wallet. Like so: `BTC(bc1qtez37te8uk8mjfecdtqesg34qent6x04e467fp)`

2. Enter those values into the username field, separated by a colon.
   e.g. `BTC(bc1qtez37te8uk8mjfecdtqesg34qent6x04e467fp), ETH(0x6ea8F3531f785f369FAF6967A778f40215D1A3C7), SOL(Bozp16Pd8qNvZ6puw5Y6J9qkqTmUqtnojCoQE7PkBrt6)`

3. Set the password to `123` or any other value to avoid being nagged by MoneyMoney.

## Supported Coins

I've tested the following coins:

- BTC
- ETH
- SOL

More coins will be added in the future. If a coin you need is missing, please open an issue.

## Which APIs are used?

- **CoinGecko** for the price data
- **Blockcypher** for Bitcoin and Ethereum balances
- **Solana JSON-RPC** for Solana balances

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
