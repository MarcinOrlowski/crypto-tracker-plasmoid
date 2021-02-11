/**
 * Crypto Ticker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-plasmoid
 */

// https://doc.qt.io/qt-5/qtqml-javascript-resources.html
.pragma library

const BTC='BTC'
const ETH='ETH'
const LTC='LTC'

var currencySymbols = {
	'EUR': '€',					// Euro
	'GBP': '£',					// British Pound Sterling
	'JPY': '¥',					// Japanese Yen
	'PLN': 'zł',				// Polish Zloty
	'USD': '$',					// US Dollar
	'USDT': 'T$',				// USDT
}
function getCurrencyName(code) {
	return `${code} (${currencySymbols[code]})`
}
function getCurrencySymbol(code) {
	return currencySymbols[code]
}

// --------------------------------------------------------------------------------------------

var cryptoNames = {
	BTC: {
		name: 'Bitcoin'
	},
	ETH: {
		name: 'Ethereum'
	},
	LTC: {
		name: 'Litecoin'
	}
}
function getCryptoName(code) {
	return `${cryptoNames[code]['name']} (${code})`
}

// --------------------------------------------------------------------------------------------

var exchanges = {
	'bitbay': {
		name: 'BitBay',
		homepage: 'https://bitbay.net',
		getRateFromExchangeData: function(data) {
			return data.ask
		},
		pairs: {
			BTC: {
				'PLN': { url: 'https://bitbay.net/API/Public/BTCPLN/ticker.json' },
				'USD': { url: 'https://bitbay.net/API/Public/BTCUSD/ticker.json' },
				'EUR': { url: 'https://bitbay.net/API/Public/BTCEUR/ticker.json' },
				'GBP': { url: 'https://bitbay.net/API/Public/BTCGBP/ticker.json' }
			},
			ETH: {
				'PLN': { url: 'https://bitbay.net/API/Public/ETHPLN/ticker.json' },
				'USD': { url: 'https://bitbay.net/API/Public/ETHUSD/ticker.json' },
				'EUR': { url: 'https://bitbay.net/API/Public/ETHEUR/ticker.json' },
				'GBP': { url: 'https://bitbay.net/API/Public/ETHGBP/ticker.json' }
			},
			LTC: {
				'PLN': { url: 'https://bitbay.net/API/Public/LTCPLN/ticker.json' },
				'USD': { url: 'https://bitbay.net/API/Public/LTCUSD/ticker.json' },
				'EUR': { url: 'https://bitbay.net/API/Public/LTCEUR/ticker.json' },
				'GBP': { url: 'https://bitbay.net/API/Public/LTCGBP/ticker.json' }
			}
		}
	},
	'bitstamp': {
		name: 'BitStamp.com',
		homepage: 'https://www.bitstamp.net/',
		getRateFromExchangeData: function(data) {
			return data.ask
		},
		pairs: {
			BTC: { 
				'USD': { url: 'https://www.bitstamp.net/api/v2/ticker/BTCUSD/' }
			},
			ETH: {
				'USD': { url: 'https://www.bitstamp.net/api/v2/ticker/ETHUSD/' }
			}
		}
	},
	'kraken': {
		name: 'Kraken',
		homepage: 'https://www.kraken.com',
		getRateFromExchangeData: function(data) {
			return data.result.XXBTZUSD.a[0]
		},
		pairs: {
			BTC: {
				'USD': { url: 'https://api.kraken.com/0/public/Ticker?pair=XXBTZUSD' }
			}
		}
	}
}

function exchangeExists(exchange) {
	return exchange in exchanges
}

function getExchangeName(exchange) {
	var result = exchangeExists(exchange) ? exchanges[exchange]['name'] : undefined
	if (typeof result === 'undefined') console.error(`Invalid exchange id: '${exchange}`)
	return result
}

function isCryptoSupported(exchange, crypto) {
	var result = false
	if (exchangeExists(exchange)) {
		result = crypto in exchanges[exchange]['pairs']
	} else {
		console.error(`Invalid exchange id: '${exchange}'`)
	}
	return result
}

function isFiatSupported(exchange, crypto, fiat) {
	var result = false
	if (isCryptoSupported(exchange, crypto)) {
		result = fiat in exchanges[exchange]['pairs'][crypto]
	} else {
		console.error(`Invalid crypto '${crypto}' on '${exchange}'`)
	}
	return result
}


// --------------------------------------------------------------------------------------------

function getAllExchangeCryptos(exchange) {
	var cryptoModel = null
	if (exchangeExists(exchange)) {
		cryptoModel = []
		for(const key in exchanges[exchange]['pairs']) {
			cryptoModel.push({'value': key, 'text': getCryptoName(key)})
		}
	} else {
		console.error(`Invalid exchange id: '${exchange}'`)
	}
	return cryptoModel
}
function getFiatsForCrypto(exchange, crypto) {
	var currencyModel = null
	if (isCryptoSupported(exchange, crypto)) {
		currencyModel = []
		for(const key in exchanges[exchange]['pairs'][crypto]) {
			currencyModel.push({'value': key, 'text': getCurrencyName(key)})
		}
	} else {
		var exName = getExchangeName(exchange)
		console.error(`Can't get fiat pairs for '${crypto}' on '${exchange}' (${exName})`)
	}
	return currencyModel
}

// --------------------------------------------------------------------------------------------

function downloadExchangeRate(exchangeId, crypto, fiat, callback) {
	var exchange = exchanges[exchangeId]
	request(exchange['pairs'][crypto][fiat].url, function(data) {
		if(data.length !== 0) {
			try {
				var json = JSON.parse(data)
				callback(exchange.getRateFromExchangeData(json))
			} catch (error) {
				console.error(`Failed parsing response from '${exchangeId}': '${error}'`)
				console.error(`Response data: '${data}'`)
			}
		}
	})
	return true
}

function request(url, callback) {
	var xhr = new XMLHttpRequest()
	xhr.onreadystatechange = function() {
		if(xhr.readyState === 4) {
			callback(xhr.responseText)
		}
	}
	xhr.open('GET', url, true)
	xhr.send('')
}
