/**
 * Crypto Ticker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-plasmoid
 */

import QtQuick.Layouts 1.1
import "../js/crypto.js" as Crypto

ColumnLayout {
	Ticker {
		exchange: 'bitstamp'
		crypto: Crypto.BTC
		fiat: 'USD'
		refreshRate: plasmoid.configuration.refreshRate
		noDecimals: true
	}

	Ticker {
		exchange: 'bitbay'
		crypto: Crypto.BTC
		fiat: 'PLN'
		localeToUse: 'pl'
		refreshRate: plasmoid.configuration.refreshRate
		noDecimals: true
	}
}