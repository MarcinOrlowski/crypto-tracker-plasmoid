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
	'USD': '$'					// US Dollar
}

var exchanges = {
	'bitbay': {
		name: 'BitBay ',
		url: 'https://bitbay.net/API/Public/BTCPLN/ticker.json',
		homepage: 'https://bitbay.net',
		currency: 'PLN',
		getRateFromExchangeData: function(data) {
			return data.ask
		}
	},
	'bitstamp': {
		name: 'BitStamp.com',
		url: 'https://www.bitstamp.net/api/ticker',
		homepage: 'https://www.bitstamp.net/',
		currency: 'USD',
		getRateFromExchangeData: function(data) {
			return data.ask
		}
	},
	'kraken': {
		name: 'Kraken',
		url: 'https://api.kraken.com/0/public/Ticker?pair=XXBTZUSD',
		homepage: 'https://www.kraken.com',
		currency: 'USD',
		getRateFromExchangeData: function(data) {
			return data.result.XXBTZUSD.a[0]
		}
	}
}

// var currencyApiUrl = 'https://api.exchangeratesapi.io';

function getRate(exchangeId, callback) {
// function getRate(exchangeId, currency, callback) {
	var exchange = exchanges[exchangeId]
	request(exchange.url, function(data) {
		if(data.length === 0) return false

		data = JSON.parse(data)
		var rate = exchange.getRateFromExchangeData(data)
		// if(source.currency != currency) {
		// 	convertCurrency(rate, source.currency, currency, callback)
		// } else {
		// 	callback(rate)
		// }

		callback(rate)
	})
	
	return true
}

// function getAllCurrencies() {
// 	var currencies = []
	
// 	Object.keys(currencySymbols).forEach(function eachKey(key) {
// 		currencies.push(key)
// 	})
	
// 	return currencies;
// }

function convertCurrency(value, from, to, callback) {
	request(currencyApiUrl + '/latest?base=' + from, function(data) {
		data = JSON.parse(data)
		var rate = data['rates'][to];
		
		callback(value * rate);
	})
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
