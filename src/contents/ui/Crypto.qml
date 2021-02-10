/**
 * Crypto Ticker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-plasmoid
 */

import QtQuick.Layouts 1.1

ColumnLayout {
	Ticker {
		exchange: 'bitstamp'
		crypto: 'BTC'
		fiat: 'USD'
		refreshRate: 5
		noDecimals: true
	}

	Ticker {
		exchange: 'bitbay'
		crypto: 'BTC'
		fiat: 'PLN'
		localeToUse: 'pl'
		refreshRate: 5
		noDecimals: true
	}
}