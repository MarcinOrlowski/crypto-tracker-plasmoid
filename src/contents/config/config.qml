/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

import QtQuick 2.0
import org.kde.plasma.configuration 2.0

ConfigModel {
	ConfigCategory {
		name: i18n("Exchange 1")
		icon: "view-visible"
		source: "configTicker0.qml"
	}
	ConfigCategory {
		name: i18n("Exchange 2")
		icon: "view-visible"
		source: "configTicker1.qml"
	}
	ConfigCategory {
		name: i18n("Exchange 3")
		icon: "view-visible"
		source: "configTicker2.qml"
	}
	ConfigCategory {
		name: i18n("Exchange 4")
		icon: "view-visible"
		source: "configTicker3.qml"
	}
	ConfigCategory {
		name: i18n("Exchange 5")
		icon: "view-visible"
		source: "configTicker4.qml"
	}
	ConfigCategory {
		name: i18n("Exchange 6")
		icon: "view-visible"
		source: "configTicker5.qml"
	}
}
