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
};

var sources = [
	{
		id: 'bitbay',
		name: 'BitBay ',
		url: 'https://bitbay.net/API/Public/BTCPLN/ticker.json',
		homepage: 'https://bitbay.net',
		currency: 'PLN',
		getRate: function(data) {
			return data.ask;
		}
	},
	{
		id: 'bitstamp',
		name: 'BitStamp.com',
		url: 'https://www.bitstamp.net/api/ticker',
		homepage: 'https://www.bitstamp.net/',
		currency: 'USD',
		getRate: function(data) {
			return data.ask;
		}
	},
	{
		id: 'kraken',
		name: 'Kraken',
		url: 'https://api.kraken.com/0/public/Ticker?pair=XXBTZUSD',
		homepage: 'https://www.kraken.com',
		currency: 'USD',
		getRate: function(data) {
			return data.result.XXBTZUSD.a[0];
		}
	},
];

var currencyApiUrl = 'https://api.exchangeratesapi.io';

function getRate(source, currency, callback) {
	if (typeof source === 'undefined') return false
	
	source = getExchangeById(source)
	if(source === null) return false
	
	request(source.url, function(data) {
		if(data.length === 0) return false;

		data = JSON.parse(data)
		var rate = source.getRate(data)
		if(source.currency != currency) {
			convertCurrency(rate, source.currency, currency, callback)
		} else {
			callback(rate)
		}
	});
	
	return true
}

function getExchangeById(id) {
	for(var i = 0; i < sources.length; i++) {
		if(sources[i].id == id) {
			return sources[i]
		}
	}
	
	return null
}

function getAllCurrencies() {
	var currencies = [];
	
	Object.keys(currencySymbols).forEach(function eachKey(key) {
		currencies.push(key);
	});
	
	return currencies;
}

function convertCurrency(value, from, to, callback) {
	request(currencyApiUrl + '/latest?base=' + from, function(data) {
		data = JSON.parse(data);
		var rate = data['rates'][to];
		
		callback(value * rate);
	});
}

function request(url, callback) {
	var xhr = new XMLHttpRequest();
	xhr.onreadystatechange = function() {
		if(xhr.readyState === 4) {
			callback(xhr.responseText);
		}
	};
	xhr.open('GET', url, true);
	xhr.send('');
}
