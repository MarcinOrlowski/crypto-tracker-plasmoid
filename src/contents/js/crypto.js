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

var currencySymbols = {
	'CZK': 'Kč',				// Czech Coruna
	'EUR': '€',					// Euro
	'GBP': '£',					// British Pound Sterling
	'JPY': '¥',					// Japanese Yen
	'KRW': '₩',					// South Korean Won
	'PLN': 'zł',				// Polish Zloty
	'USD': '$',					// US Dollar
	'USDT': 'T$',					// USDT
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
			'BTC': {
				'PLN': { url: 'https://bitbay.net/API/Public/BTCPLN/ticker.json' },
				'USD': { url: 'https://bitbay.net/API/Public/BTCUSD/ticker.json' },
				'EUR': { url: 'https://bitbay.net/API/Public/BTCEUR/ticker.json' }
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
			'BTC': { 
				'USD': { url: 'https://www.bitstamp.net/api/v2/ticker/BTCUSD/' }
			},
			'ETH': {
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
			'BTC': {
				'USD': { url: 'https://api.kraken.com/0/public/Ticker?pair=XXBTZUSD' }
			}
		}
	}
}

function getExchangeName(id) {
	return exchanges[id]['name']
}

// --------------------------------------------------------------------------------------------

function downloadExchangeRate(exchangeId, crypto, fiat, callback) {
	var exchange = exchanges[exchangeId]
	request(exchange['pairs'][crypto][fiat].url, function(data) {
		if(data.length !== 0) {
			callback(exchange.getRateFromExchangeData(JSON.parse(data)))
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
