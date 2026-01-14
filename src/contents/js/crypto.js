/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021-2026 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

// https://doc.qt.io/qt-5/qtqml-javascript-resources.html
.pragma library

.import 'crypto_data.js' as Data

// OBSOLETE: Remove config panes that using this
const BTC='BTC'
const USD='USD'

const currencies = Data.currencies

function getCurrencyName(code) {
	if (code in currencies) {
		var c = currencies[code]
		var name = (c['name'] != code) ? c['name'] : ''
		var symbol = ('symbol' in c ) ? c['symbol'] : ''
		var full_name = code
		if (name + symbol != '') {
			var extra = ''
			if (symbol != '') extra += symbol
			if (extra != '') extra += ' '
			if (name != '') extra += name
			full_name += ' (' + extra + ')'
		}
		return full_name
	} else {
		return 'UNKNOWN! ' + code
	}
}
function getCurrencySymbol(code) {
	return ('symbol' in currencies[code])
		? currencies[code]['symbol']
		: code
}

// --------------------------------------------------------------------------------------------

function getCryptoName(code) {
	var name = ('name' in currencies[code])
		? currencies[code]['name']
		: code
	return name + ' (' + code + ')'
}
function getCryptoIcon(code) {
	return code.toLowerCase() + '.svg'
}

// --------------------------------------------------------------------------------------------

const exchanges = Data.exchanges

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

function isPairSupported(exchange, crypto, pair) {
	var result = false
	if (isCryptoSupported(exchange, crypto)) {
		result = (exchanges[exchange]['pairs'][crypto].indexOf(pair) !== -1)
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
function getPairsForCrypto(exchange, crypto) {
	var currencyModel = null
	if (isCryptoSupported(exchange, crypto)) {
		currencyModel = []
		var pairs = exchanges[exchange]['pairs'][crypto]
		for(var i = 0; i < pairs.length; i++) {
			var key = pairs[i]
			currencyModel.push({'value': key, 'text': getCurrencyName(key)})
		}
	} else {
		var exName = getExchangeName(exchange)
		console.error("Can't get pair for '" + crypto + "' on '" + exchange + "' (" + exName + ")")
	}
	return currencyModel
}
