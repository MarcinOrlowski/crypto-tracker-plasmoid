/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

// https://doc.qt.io/qt-5/qtqml-javascript-resources.html
.pragma library

const BTC='BTC'
const ETH='ETH'
const LTC='LTC'

const USD='USD'
const PLN='PLN'
const GBP='GBP'
const EUR='EUR'
const JPY='JPY'
const CZK='CZK'

var currencySymbols = {
	EUR: '€',					// Euro
	GBP: '£',					// British Pound Sterling
	PLN: 'zł',				// Polish Zloty
	USD: '$',					// US Dollar
	JPY: '¥',					// Japanese Yen
	CZK: 'Kč',				// Czech Krown
}
function getCurrencyName(code) {
	return code + ' (' + currencySymbols[code] + ')'
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
	return cryptos[code]['name'] + ' (' + code + ')'
}
function getCryptoIcon(code) {
	return code + '.svg'
}

// --------------------------------------------------------------------------------------------

var exchanges = {
	'bitbay-net': {
		name: 'BitBay',
		url: 'https://bitbay.net/',
		getRateFromExchangeData: function(data, crypto, fiat) {
			return data.ask
		},
		getUrl: function(crypto, fiat) {
			return 'https://bitbay.net/API/Public/' + crypto + fiat + '/ticker.json'
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
		name: 'BitStamp',
		url: 'https://www.bitstamp.net/',
		getRateFromExchangeData: function(data, crypto, fiat) {
			return data.ask
		},
		getUrl: function(crypto, fiat) {
			return 'https://www.bitstamp.net/api/v2/ticker/' + crypto + fiat
		},
		pairs: {
			BTC: [
				'USD',
				'EUR',
				'GBP',
			],
			ETH: [
				'USD',
				'EUR',
				'GBP',
			],
			LTC: [
				'USD',
				'EUR',
				'GBP',
			],
			XRP: [
				'USD',
				'EUR',
				'GBP',
			],
		}
	},
	'coinmate-io': {
		name: 'Coinmate',
		url: 'https://coinmate.io/',
		getRateFromExchangeData: function(data, crypto, fiat) {
			return data.data.ask
		},
		getUrl: function(crypto, fiat) {
			return 'https://coinmate.io/api/ticker?currencyPair=' + crypto + '_' + fiat
		},
		pairs: {
			BTC: [
				'CZK',
				'EUR',
			],
			ETH: [
				'CZK',
				'EUR',
			],
			LTC: [
				'CZK',
				'EUR',
			],
			XRP: [
				'CZK',
				'EUR',
			],
		}
	},
	'kraken-com': {
		name: 'Kraken',
		url: 'https://www.kraken.com/',
		getRateFromExchangeData: function(data, crypto, fiat) {
			// FIXME hardcoded mapping
			switch (crypto) {
				case 'BTC':
					crypto = 'XBT'
					break
				default:
					// do nothing
					break
			}
			return data.result['X' + crypto + 'Z' + fiat].a[0]
		},
		getUrl: function(crypto, fiat) {
			return 'https://api.kraken.com/0/public/Ticker?pair=' + crypto + fiat
		},
		pairs: {
			BTC: [
				'USD',
				'EUR',
				'GBP',
				'JPY',
			],
			ETH: [
				'USD',
				'EUR',
				'GBP',
				'JPY',
			],
			LTC: [
				'USD',
				'EUR',
				'GBP',
				'JPY',
			],
			XRP: [
				'USD',
				'EUR',
				'GBP',
				'JPY',
			],
		}
	}
}

function exchangeExists(exchange) {
	return exchange in exchanges
}

function getExchageIds() {
	return Object.keys(exchanges)
}

function getExchange(exchange) {
	var result = exchangeExists(exchange) ? exchanges[exchange] : undefined
	if (typeof result === 'undefined') console.error("Invalid exchange id: '" + exchange + "'")
	return result
}

function getExchangeName(exchange) {
	var result = exchangeExists(exchange) ? exchanges[exchange]['name'] : undefined
	if (typeof result === 'undefined') console.error("Invalid exchange id: '" + exchange + "'")
	return result
}

function getExchangeUrl(exchange) {
	var result = exchangeExists(exchange) ? exchanges[exchange]['url'] : undefined
	if (typeof result === 'undefined') console.error("Invalid exchange id: '" + exchange + "'")
	return result
}

function isCryptoSupported(exchange, crypto) {
	var result = false
	if (exchangeExists(exchange)) {
		result = crypto in exchanges[exchange]['pairs']
	} else {
		console.error("Invalid exchange id: '" + exchange + "'")
	}
	return result
}

function isFiatSupported(exchange, crypto, fiat) {
	var result = false
	if (isCryptoSupported(exchange, crypto)) {
		result = (exchanges[exchange]['pairs'][crypto].indexOf(fiat) !== -1)
	} else {
		console.error("Invalid crypto '" + crypto + "' on '" + exchange + "'")
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
		console.error("Invalid exchange id: '" + exchange + "'")
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
		console.error("Can't get fiat pairs for '" + crypto + "' on '" + exchange + "' (" + exName + ")")
	}
	return currencyModel
}
