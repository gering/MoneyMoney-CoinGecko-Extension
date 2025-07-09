-- CoinGecko Extension for MoneyMoney
-- Fetches balance from your crypto wallets using CoinGecko API
--
-- Specify your crypto wallet addresses as username
-- Username: BTC(addr1, addr2), ETH(addr3, addr4), SOL(addr5), ...
-- SOL automatically discovers all SPL tokens in the wallet!
--
-- Copyright (c) 2024-2025 Robert Gering
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
  version = 2.0,
  country = "de",
  url = "https://api.coingecko.com",
  description = string.format(MM.localizeText("Track Bitcoin, Ethereum, Solana + auto-discover all SPL tokens. Powered by CoinGecko prices.")),
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

-- Configuration for native coins and their fetch methods
local nativeCoinConfig = {
  btc = {
    fetchMethod = "blockcypher",
    decimals = 100000000  -- Satoshi to BTC
  },
  eth = {
    fetchMethod = "blockcypher",
    decimals = 1000000000000000000  -- Wei to ETH
  },
  sol = {
    fetchMethod = "solana",
    decimals = 1000000000  -- Lamports to SOL
  }
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

  -- Prices will be fetched in RefreshAccount after token discovery
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

  -- Now fetch prices for all discovered coins (including dynamic SPL tokens)
  prices = fetchPrices(balances)
  if prices == nil then
    MM.printStatus("Preise konnten nicht geladen werden")
    return {}
  end

  for symbol, balance in pairs(balances) do
    local coin = lookupCoin(symbol)
    if not coin then
      MM.printStatus("Coin nicht gefunden: " .. symbol:upper())
      goto continue
    end

    local name = coin.name .. " (" .. symbol:upper() .. ")"
    MM.printStatus("Verarbeite: " .. name .. ") ")

    local priceData = prices[coin.id]
    if not priceData or not priceData.eur then
      MM.printStatus("Keine Preisdaten für: " .. coin.id)
      goto continue
    end

    local price = priceData.eur
    local amount = balance * price

    table.insert(s, {
      name = name,
      market = "CoinGecko",
      quantity = balance,
      price = price,
      currency = nil,
      amount = amount
    })

    ::continue::
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

function fetchPrices(balances)
  MM.printStatus("Lade Preise von CoinGecko")

  local ids = {}
  for symbol in pairs(balances) do
    local coin = lookupCoin(symbol)
    if coin and coin.id then
      table.insert(ids, coin.id)
    end
  end

  if #ids == 0 then
    MM.printStatus("Keine gültigen Coin-IDs gefunden")
    return {}
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

    if symbol == "sol" then
      -- Special handling for SOL: get SOL balance + all SPL tokens
      for _, address in ipairs(address_list) do
        -- Add SOL balance
        local solBalance = fetchBalance(symbol, address)
        total_balance = total_balance + solBalance

        -- Find all SPL tokens for this wallet
        local tokens = fetchAllSolanaTokens(address)
        for mintAddress, tokenBalance in pairs(tokens) do
          -- Get token info from Jupiter
          local tokenInfo = fetchTokenInfoFromJupiter(mintAddress)
          if tokenInfo then
            -- Store token balance with symbol as key
            local tokenSymbol = tokenInfo.symbol:lower()
            balances[tokenSymbol] = (balances[tokenSymbol] or 0) + tokenBalance

            -- Add token to coins registry for price lookup
            if not coins[tokenSymbol] then
              coins[tokenSymbol] = tokenInfo
            end
          end
        end
      end
      balances[symbol] = total_balance
    else
      -- Regular token handling
      for _, address in ipairs(address_list) do
        local balance = fetchBalance(symbol, address)
        total_balance = total_balance + balance
      end
      balances[symbol] = total_balance
    end
  end
  return balances
end

function fetchBalance(symbol, address)
  -- Check if it's a native coin
  local nativeConfig = nativeCoinConfig[symbol]
  if nativeConfig then
    if nativeConfig.fetchMethod == "blockcypher" then
      local rawBalance = fetchBlockcypherBalance(symbol, address)
      return rawBalance / nativeConfig.decimals
    elseif nativeConfig.fetchMethod == "solana" then
      return fetchSolanaBalance(symbol, address)
    end
  end

  -- Check if it's an ERC20 token
  if contractERC20Addresses[symbol] then
    return fetchERC20Balance(symbol, address)
  end

  MM.printStatus("Nicht unterstützter Coin: " .. symbol:upper())
  return 0
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
  local lamports = JSON(content):dictionary()["result"]["value"]
  local decimals = nativeCoinConfig[symbol] and nativeCoinConfig[symbol].decimals or 1000000000
  return lamports / decimals
end

function fetchAllSolanaTokens(address)
  MM.printStatus("Lade alle Token für SOL Wallet")
  local connection = Connection()
  local url = "https://api.mainnet-beta.solana.com"

  -- Get all token accounts for this wallet
  local payload = {
      jsonrpc = "2.0", id = 1,
      method = "getTokenAccountsByOwner",
      params = {
          address,
          {programId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"},
          {encoding = "jsonParsed"}
      }
  }

  local content = connection:request("POST", url, JSON():set(payload):json(), "application/json")
  local result = JSON(content):dictionary()
  local tokens = {}

  if result["result"] and result["result"]["value"] then
      for _, tokenAccount in ipairs(result["result"]["value"]) do
          local mintAddress = tokenAccount["account"]["data"]["parsed"]["info"]["mint"]
          local balance = tonumber(tokenAccount["account"]["data"]["parsed"]["info"]["tokenAmount"]["uiAmount"]) or 0

          if balance > 0 then  -- Only include tokens with balance
              tokens[mintAddress] = balance
          end
      end
  end

  return tokens
end

function fetchTokenInfoFromJupiter(mintAddress)
  MM.printStatus("Lade Token Info für " .. mintAddress:sub(1, 8) .. "...")
  local connection = Connection()
  local url = "https://lite-api.jup.ag/tokens/v1/token/" .. mintAddress
  local content = connection:request("GET", url)
  local tokenInfo = JSON(content):dictionary()

  if tokenInfo and tokenInfo["symbol"] and tokenInfo["name"] then
      -- Try to get CoinGecko ID from extensions, fallback to mint address
      local coingeckoId = mintAddress  -- Default fallback
      if tokenInfo["extensions"] and tokenInfo["extensions"]["coingeckoId"] then
          coingeckoId = tokenInfo["extensions"]["coingeckoId"]
      end

      return {
          symbol = tokenInfo["symbol"],
          name = tokenInfo["name"],
          id = coingeckoId
      }
  end

  return nil
end


function fetchERC20Balance(symbol, address)
  MM.printStatus("Lade " .. symbol:upper() .. " Bestand von CoinGecko API")
  local connection = Connection()
  local contractAddress = contractERC20Addresses[symbol]
  if contractAddress then
      local url = string.format("https://api.coingecko.com/api/v3/simple/token_price/ethereum?contract_addresses=%s&vs_currencies=%s", contractAddress, currency:lower())
      local content = connection:request("GET", url)
      local json = JSON(content)
      local balance = json:dictionary()[contractAddress] and json:dictionary()[contractAddress][currency:lower()]
      return tonumber(balance) or 0
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

-- SIGNATURE: MC0CFQChuawHomRm7VIp8xTEVNOB3L5QBgIUFLxmuAbfocj9lZNZDcJapn4/wgA=
