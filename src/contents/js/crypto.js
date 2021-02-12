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
	'USD': '$'					// US Dollar
}
function getCurrencyName(code) {
	return `${code} (${currencySymbols[code]})`
}
function getCurrencySymbol(code) {
	return currencySymbols[code]
}

// --------------------------------------------------------------------------------------------

var cryptos = {
	BTC: {
		name: 'Bitcoin'
	},
	ETH: {
		name: 'Ethereum'
	},
	LTC: {
		name: 'Litecoin'
	},
	XRP: {
		name: 'Ripple'
	}
}
function getCryptoName(code) {
	return `${cryptos[code]['name']} (${code})`
}
function getCryptoIcon(code) {
	return `${code}.svg`
}

// --------------------------------------------------------------------------------------------

var exchanges = {
	'bitbay-net': {
		name: 'BitBay',
		homepage: 'https://bitbay.net',
		getRateFromExchangeData: function(data) {
			return data.ask
		},
		getUrl: function(crypto, fiat) {
			return `https://bitbay.net/API/Public/${crypto}${fiat}/ticker.json`
		},
		pairs: {
			BTC: [
				'PLN',
				'USD',
				'EUR',
				'GBP',
			],
			ETH: [
				'PLN',
				'USD',
				'EUR',
				'GBP',
			],
			LTC: [
				'PLN',
				'USD',
				'EUR',
				'GBP',
			],
			XRP: [
				'PLN',
				'USD',
				'EUR',
				'GBP',
			],
		}
	},
	'bitstamp-net': {
		name: 'bitstamp.net',
		homepage: 'https://www.bitstamp.net/',
		getRateFromExchangeData: function(data) {
			return data.ask
		},
		getUrl: function(crypto, fiat) {
			return `https://www.bitstamp.net/api/v2/ticker/${crypto}${fiat}/`
		},
		pairs: {
			BTC: [
				'USD'
			],
			ETH: [
				'USD'
			],
		}
	},
	'kraken-com': {
		name: 'Kraken',
		homepage: 'https://www.kraken.com',
		getRateFromExchangeData: function(data) {
			return data.result.XXBTZUSD.a[0]
		},
		getUrl: function(crypto, fiat) {
			return `https://api.kraken.com/0/public/Ticker?pair=${crypto}${fiat}`
		},
		pairs: {
			BTC: [
				'USD',
			]
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

function isExchangeValid(exchange) {
	return exchange in exchanges
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
		result = (exchanges[exchange]['pairs'][crypto].indexOf(fiat) !== -1)
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
		var fiats = exchanges[exchange]['pairs'][crypto]
		for(var i = 0; i < fiats.length; i++) {
			var key = fiats[i]
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
	request(exchange.getUrl(crypto, fiat), function(data) {
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
