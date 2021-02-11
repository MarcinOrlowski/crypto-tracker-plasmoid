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
	Exchange {
		exchange: plasmoid.configuration.exchange0
		crypto: plasmoid.configuration.crypto0
		fiat: plasmoid.configuration.fiat0
		refreshRate: plasmoid.configuration.refreshRate0
		noDecimals: plasmoid.configuration.hidePriceDecimals0
		localeToUse: plasmoid.configuration.useCustomLocale0 ? plasmoid.configuration.customLocaleName0 : ''
	}

	Exchange {
		exchange: plasmoid.configuration.exchange1
		crypto: plasmoid.configuration.crypto1
		fiat: plasmoid.configuration.fiat1
		refreshRate: plasmoid.configuration.refreshRate1
		noDecimals: plasmoid.configuration.hidePriceDecimals1
		localeToUse: plasmoid.configuration.useCustomLocale1 ? plasmoid.configuration.customLocaleName1 : ''
	}
}
