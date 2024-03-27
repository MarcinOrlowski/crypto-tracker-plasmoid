/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3
import QtQuick.Dialogs

Dialog {
	visible: false
	title: i18n('Information')
	standardButtons: DialogButtonBox.Ok

	width: 600
	height: 500
	//Layout.minimumWidth: 600
	//Layout.minimumHeight: 500

	AppInfo { }

} // Dialog
