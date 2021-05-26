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
const ETC='ETC'
const ETH='ETH'
const LTC='LTC'

const USD='USD'
const PLN='PLN'
const GBP='GBP'
const EUR='EUR'
const JPY='JPY'
const CZK='CZK'

var currencySymbols = {
	EUR: '€',				// Euro
	GBP: '£',				// British Pound Sterling
	PLN: 'zł',				// Polish Zloty
	USD: '$',				// US Dollar
	JPY: '¥',				// Japanese Yen
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
	},
	ETC: {
		name: 'Ethereum Classic'
	},
}
function getCryptoName(code) {
	return cryptos[code]['name'] + ' (' + code + ')'
}
function getCryptoIcon(code) {
	return code + '.svg'
}

// --------------------------------------------------------------------------------------------

const bitbay_fiats = [
	'PLN',
	'USD',
	'EUR',
	'GBP',
]
const bitstamp_fiats = [
	'USD',
	'EUR',
	'GBP',
]
const coinmate_fiats = [
	'CZK',
	'EUR',
]
const kraken_fiats = [
	'USD',
	'EUR',
	'GBP',
	'JPY',
]

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
			BTC: bitbay_fiats,
			ETH: bitbay_fiats,
			LTC: bitbay_fiats,
			XRP: bitbay_fiats,
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
			BTC: bitstamp_fiats,
			ETH: bitstamp_fiats,
			ETC: bitstamp_fiats,
			LTC: bitstamp_fiats,
			XRP: bitstamp_fiats,
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
			BTC: coinmate_fiats,
			ETH: coinmate_fiats,
			LTC: coinmate_fiats,
			XRP: coinmate_fiats,
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
			BTC: kraken_fiats,
			ETH: kraken_fiats,
			ETC: [
				'USD',
				'EUR',
			],
			LTC: kraken_fiats,
			XRP: kraken_fiats,
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
