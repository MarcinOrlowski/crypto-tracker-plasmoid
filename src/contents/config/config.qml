/**
 * Crypto Ticker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-plasmoid
 */

import QtQuick 2.0
import org.kde.plasma.configuration 2.0

ConfigModel {
	ConfigCategory {
		name: i18n("Ticker 1")
		icon: "view-visible"
		source: "configTicker0.qml"
	}
	ConfigCategory {
		name: i18n("Ticker 2")
		icon: "view-visible"
		source: "configTicker1.qml"
	}
}
