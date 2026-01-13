/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support

QtObject {
	id: notificationManager

	property var dataSource: Plasma5Support.DataSource {
		id: dataSource
		engine: "notifications"
		connectedSources: ["org.freedesktop.Notifications"]
	}

	function post(args) {
		// https://github.com/KDE/plasma-workspace/blob/master/dataengines/notifications/notifications.operations
		var service = dataSource.serviceForSource("notification")
		var operation = service.operationDescription("createNotification")
		operation.appName = args.title
		operation.appIcon = args.icon || ''
		operation.summary = args.summary || ''
		operation.body = args.body || ''
		if (typeof args.expireTimeout !== undefined) {
			operation.expireTimeout = args.expireTimeout
		}
		service.startOperationCall(operation)
	}
}
