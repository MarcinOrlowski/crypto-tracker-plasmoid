/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQControls
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import "../../js/crypto.js" as Crypto
import ".."


Kirigami.FormLayout {
	Layout.fillWidth: true
	id: controlRoot

	AppInfo { }

	Item {
		Layout.fillWidth: true
		Layout.fillHeight: true
	}
}
