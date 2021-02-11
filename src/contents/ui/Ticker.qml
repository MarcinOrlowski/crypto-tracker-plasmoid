/**
 * Crypto Ticker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-plasmoid
 */

import QtQuick.Layouts 1.1
import org.kde.plasma.components 3.0 as PlasmaComponents
import "../js/crypto.js" as Crypto

ColumnLayout {
	readonly property bool anythingVisible: plasmoid.configuration.running0 | plasmoid.configuration.running1

	PlasmaComponents.Label {
		visible: !anythingVisible
		Layout.alignment: Qt.AlignHCenter
		// textFormat: Text.RichText
		text: "Edit me!"
	}
    
	Exchange {
		running: plasmoid.configuration.running0
		visible: running

		exchange: plasmoid.configuration.exchange0
		crypto: plasmoid.configuration.crypto0
		fiat: plasmoid.configuration.fiat0
		refreshRate: plasmoid.configuration.refreshRate0
		noDecimals: plasmoid.configuration.hidePriceDecimals0
		localeToUse: plasmoid.configuration.useCustomLocale0 ? plasmoid.configuration.customLocaleName0 : ''
	}

	Exchange {
		running: plasmoid.configuration.running1
		visible: running

		exchange: plasmoid.configuration.exchange1
		crypto: plasmoid.configuration.crypto1
		fiat: plasmoid.configuration.fiat1
		refreshRate: plasmoid.configuration.refreshRate1
		noDecimals: plasmoid.configuration.hidePriceDecimals1
		localeToUse: plasmoid.configuration.useCustomLocale1 ? plasmoid.configuration.customLocaleName1 : ''
	}
}
