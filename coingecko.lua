-- CoinGecko Extension for MoneyMoney
-- Fetches balance from your crypto wallets using CoinGecko API
--
-- Specify your crypto wallet addresses as username
-- Username: BTC(addr1, addr2), ETH(addr3, addr4), SOL(addr5), ...
--
-- Copyright (c) 2024 Robert Gering
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

WebBanking {
  version = 1.1,
  country = "de",
  url = "https://api.coingecko.com",
  description = string.format(MM.localizeText("Fetch balances from your crypto wallet using CoinGecko and list them as securities")),
  services = { "CoinGecko" },
}

-- State
local wallets
local allCoins
local prices

-- Constants
local currency = "EUR"
local coins = {
  btc = { id = "bitcoin", name = "Bitcoin" },
  eth = { id = "ethereum", name = "Ethereum" },
  ltc = { id = "litecoin", name = "Litecoin" },
  doge = { id = "dogecoin", name = "Dogecoin" },
  bch = { id = "bitcoin-cash", name = "Bitcoin Cash" },
  bsv = { id = "bitcoin-cash-sv", name = "Bitcoin Cash SV" },
  iot = { id = "iota", name = "IOTA" },
  usdt = { id = "tether", name = "Tether" },
  sol = { id = "solana", name = "Solana" },
}
local contractERC20Addresses = {
  usdt = "0xdac17f958d2ee523a2206206994597c13d831ec7"
}

function SupportsBank(protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "CoinGecko"
end

function InitializeSession(protocol, bankCode, username, username2, password, username3)
  wallets = parseAddresses(username)
  if wallets == nil or next(wallets) == nil then
    MM.printStatus("Wallet Adressen konnten nicht ermittelt werden")
    return LoginFailed
  end

  prices = fetchPrices(wallets)
  if prices == nil then
    MM.printStatus("Preise konnten nicht geladen werden")
    return LoginFailed
  end
end

function ListAccounts(knownAccounts)
  local account = {
    name = "CoinGecko",
    accountNumber = "Wallet",
    currency = currency,
    portfolio = true,
    type = AccountTypePortfolio
  }

  return {account}
end

function RefreshAccount(account, since)
  local s = {}
  local balances = fetchBalances(wallets)

  for symbol, balance in pairs(balances) do
    local coin = lookupCoin(symbol)
    local name = coin.name .. " (" .. symbol:upper() .. ")"
    MM.printStatus("Verarbeite: " .. name .. ") ")
    local price = prices[coin.id].eur
    local amount = balance * price

    table.insert(s, {
      name = name,
      market = "CoinGecko",
      quantity = balance,
      price = price,
      currency = nil,
      amount = amount
    })
  end

  return {securities = s}
end

function EndSession()
  -- NOP
end

-- API Functions

function fetchAllCoins()
  MM.printStatus("Lade Crypto Coins von CoinGecko")

  local connection = Connection()
  local content = connection:request("GET", "https://api.coingecko.com/api/v3/coins/list")
  local coinList = JSON(content):dictionary()
  local coins = {}

  for _, coin in ipairs(coinList) do
    coins[coin.symbol] = coin
  end

  return coins
end

function fetchPrices(wallets)
  MM.printStatus("Lade Preise von CoinGecko")

  local ids = {}
  for symbol in pairs(wallets) do
    table.insert(ids, lookupCoin(symbol).id)
  end

  local connection = Connection()
  local idsParam = table.concat(ids, ",")
  local currencyParam = currency:lower()
  local url = string.format("https://api.coingecko.com/api/v3/simple/price?ids=%s&vs_currencies=%s", idsParam, currencyParam)
  local content = connection:request("GET", url)
  local json = JSON(content)
  return json:dictionary()
end

function fetchBalances(wallets)
  local balances = {}
  for symbol, address_list in pairs(wallets) do
    local total_balance = 0
    for _, address in ipairs(address_list) do
      local balance = fetchBalance(symbol, address)
      total_balance = total_balance + balance
    end
    balances[symbol] = total_balance
  end
  return balances
end

function fetchBalance(symbol, address)
  local connection = Connection()
  local url

  return switch(symbol, address, {
      btc = function(coin, address)
        local satoshi = fetchBlockcypherBalance(coin, address)
        return satoshi / 100000000 -- Convert Satoshi to BTC
      end,
      eth = function(coin, address)
        local wei = fetchBlockcypherBalance(coin, address)
        return wei / 1000000000000000000 -- Convert Wei to ETH
      end,
      sol = fetchSolanaBalance,
      erc20 = fetchERC20Balance,
      usdt = fetchERC20Balance,
      default = function(coin, address)
          MM.printStatus("Nicht unterstützer Coin: " .. coin:upper())
          return 0
      end
  })
end

function fetchBlockcypherBalance(symbol, address)
  MM.printStatus("Lade " .. symbol:upper() .. " Bestand von Blockcypher API")
  local connection = Connection()
  local url = string.format("https://api.blockcypher.com/v1/%s/main/addrs/%s/balance", symbol, address)
  local content = connection:request("GET", url)
  return JSON(content):dictionary()["final_balance"]
end

function fetchSolanaBalance(symbol, address)
  MM.printStatus("Lade " .. symbol:upper() .. " Bestand von Solana API")
  local connection = Connection()
  local url = "https://api.mainnet-beta.solana.com"
  local payload = {
      jsonrpc = "2.0", id = 1,
      method = "getBalance",
      params = {address}
  }
  local content = connection:request("POST", url, JSON():set(payload):json(), "application/json")
  return JSON(content):dictionary()["result"]["value"] / 1000000000 -- Convert Lamports to SOL
end

function fetchERC20Balance(symbol, address)
  MM.printStatus("Lade " .. symbol:upper() .. " Bestand von CoinGecko API")
  local contractAddress = contractERC20Addresses[symbol]
  if contractAddress then
      url = string.format("https://api.coingecko.com/api/v3/simple/token_price/ethereum?contract_addresses=%s&vs_currencies=%s", contractAddress, currency:lower())
      local content = connection:request("GET", url)
      local json = JSON(content)
      local balance = json:dictionary()[contractAddress] and json:dictionary()[contractAddress][currency:lower()]
      if balance then
          return balance
      end
  end
  return 0
end

-- Helper

-- Parse the username string and extract wallet addresses
-- Expected format: BTC(addr1, addr2), ETH(addr3, addr4), SOL(addr5), ...
function parseAddresses(username)
  local addresses = {}
  for symbol, address_str in string.gmatch(username, "([A-Z]+)%(([^)]+)%)") do
    local symbol_lower = symbol:lower()
    addresses[symbol_lower] = {}
    for address in string.gmatch(address_str, "%s*([^,]+)%s*") do
      table.insert(addresses[symbol_lower], address)
      MM.printStatus("Gefunden: " .. symbol:upper() .. " (" .. address .. ")")
    end
  end
  return addresses
end

function lookupCoin(symbol)
  -- first, try hardcoded local coins
  local coin = coins[symbol]

  if coin == nil then
    -- if not found, try to fetch all coins from CoinGecko
    if allCoins == nil then
      allCoins = fetchAllCoins()
      if allCoins == nil then
        MM.printStatus("Crypto Coins konnten nicht geladen werden")
        return nil
      end
    end
    coin = allCoins[symbol]
  end

  if coin == nil then
    MM.printStatus("Nicht gefunden: " .. symbol:upper())
    return nil
  end

  return coin
end

function switch(symbol, address, cases)
  local case = cases[symbol]
  if case then
      return case(symbol, address)
  end
  if cases.default then
      return cases.default(symbol, address)
  end
end
