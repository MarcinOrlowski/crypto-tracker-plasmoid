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
		text: i18n("Edit me!")
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

		showPriceChangeMarker: plasmoid.configuration.showPriceChangeMarker0
		showTrendingMarker: plasmoid.configuration.showTrendingMarker0
    	trendingTimeSpan: plasmoid.configuration.trendingTimeSpan0

		flashOnPriceRaise: plasmoid.configuration.flashOnPriceRaise0
		flashOnPriceDrop: plasmoid.configuration.flashOnPriceDrop0
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

		showPriceChangeMarker: plasmoid.configuration.showPriceChangeMarker1
		showTrendingMarker: plasmoid.configuration.showTrendingMarker1
    	trendingTimeSpan: plasmoid.configuration.trendingTimeSpan1

		flashOnPriceRaise: plasmoid.configuration.flashOnPriceRaise1
		flashOnPriceDrop: plasmoid.configuration.flashOnPriceDrop1
	}

	Exchange {
		running: plasmoid.configuration.running2
		visible: running

		exchange: plasmoid.configuration.exchange2
		crypto: plasmoid.configuration.crypto2
		fiat: plasmoid.configuration.fiat2
		refreshRate: plasmoid.configuration.refreshRate2
		noDecimals: plasmoid.configuration.hidePriceDecimals2
		localeToUse: plasmoid.configuration.useCustomLocale2 ? plasmoid.configuration.customLocaleName2 : ''

		showPriceChangeMarker: plasmoid.configuration.showPriceChangeMarker2
		showTrendingMarker: plasmoid.configuration.showTrendingMarker2
    	trendingTimeSpan: plasmoid.configuration.trendingTimeSpan2

		flashOnPriceRaise: plasmoid.configuration.flashOnPriceRaise2
		flashOnPriceDrop: plasmoid.configuration.flashOnPriceDrop2
	}

	Exchange {
		running: plasmoid.configuration.running3
		visible: running

		exchange: plasmoid.configuration.exchange3
		crypto: plasmoid.configuration.crypto3
		fiat: plasmoid.configuration.fiat3
		refreshRate: plasmoid.configuration.refreshRate3
		noDecimals: plasmoid.configuration.hidePriceDecimals3
		localeToUse: plasmoid.configuration.useCustomLocale3 ? plasmoid.configuration.customLocaleName3 : ''

		showPriceChangeMarker: plasmoid.configuration.showPriceChangeMarker3
		showTrendingMarker: plasmoid.configuration.showTrendingMarker3
    	trendingTimeSpan: plasmoid.configuration.trendingTimeSpan3

		flashOnPriceRaise: plasmoid.configuration.flashOnPriceRaise3
		flashOnPriceDrop: plasmoid.configuration.flashOnPriceDrop3
	}

	Exchange {
		running: plasmoid.configuration.running4
		visible: running

		exchange: plasmoid.configuration.exchange4
		crypto: plasmoid.configuration.crypto4
		fiat: plasmoid.configuration.fiat4
		refreshRate: plasmoid.configuration.refreshRate4
		noDecimals: plasmoid.configuration.hidePriceDecimals4
		localeToUse: plasmoid.configuration.useCustomLocale4 ? plasmoid.configuration.customLocaleName4 : ''

		showPriceChangeMarker: plasmoid.configuration.showPriceChangeMarker4
		showTrendingMarker: plasmoid.configuration.showTrendingMarker4
    	trendingTimeSpan: plasmoid.configuration.trendingTimeSpan4

		flashOnPriceRaise: plasmoid.configuration.flashOnPriceRaise4
		flashOnPriceDrop: plasmoid.configuration.flashOnPriceDrop4
	}

	Exchange {
		running: plasmoid.configuration.running5
		visible: running

		exchange: plasmoid.configuration.exchange5
		crypto: plasmoid.configuration.crypto5
		fiat: plasmoid.configuration.fiat5
		refreshRate: plasmoid.configuration.refreshRate5
		noDecimals: plasmoid.configuration.hidePriceDecimals5
		localeToUse: plasmoid.configuration.useCustomLocale5 ? plasmoid.configuration.customLocaleName5 : ''

		showPriceChangeMarker: plasmoid.configuration.showPriceChangeMarker5
		showTrendingMarker: plasmoid.configuration.showTrendingMarker5
    	trendingTimeSpan: plasmoid.configuration.trendingTimeSpan5

		flashOnPriceRaise: plasmoid.configuration.flashOnPriceRaise5
		flashOnPriceDrop: plasmoid.configuration.flashOnPriceDrop5
	}

} // ColumnLayout
