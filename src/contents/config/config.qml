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
		name: i18n("Exchanges")
		icon: "taxes-finances"
		source: "config/Exchanges.qml"
	}
	ConfigCategory {
		name: i18n("Layout")
		icon: "window"
		source: "config/Layout.qml"
	}
	ConfigCategory {
		name: i18n("About")
		icon: "view-visible"
		source: "config/About.qml"
	}

}
