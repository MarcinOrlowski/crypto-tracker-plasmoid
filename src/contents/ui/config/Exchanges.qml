/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

import QtQuick
import QtQuick.Controls as QtControls
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import "../../js/crypto.js" as Crypto
import ".."

import org.kde.kcmutils as KCM

import Qt.labs.qmlmodels

KCM.SimpleKCM {
	id: configExchanges

	Layout.fillWidth: true

	property alias cfg_exchanges: serializedExchanges.text

	Text {
		id: serializedExchanges
		visible: false
		onTextChanged: {
			exchangesModel.clear()
			JSON.parse(serializedExchanges.text).forEach(
				ex => {
					exchangesModel.appendRow(ex)
				}
			)
		}
	}

	ExchangeModel {
		id: exchangesModel
	}

	RowLayout {
		Item {
			id: tableContainer
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.margins: 1
			Layout.rightMargin: 10
		
			QtControls.HorizontalHeaderView {
				id: exchangesTableHeader

				syncView: exchangesTable
				anchors.top: parent.top

				boundsBehavior: Flickable.StopAtBounds

				resizableColumns: false
				resizableRows: false

				columnWidthProvider: exchangesTable.columnWidthProvider
				rowHeightProvider: exchangesTable.rowHeightProvider

				delegate: Rectangle {
					color: palette.button
					QtControls.Label {
						text: {
							switch(column){
								case 0: return "Exchange"
								case 1: return "Crypto"
								case 2: return "Pair"
							}
						}
						font.bold: true
						leftPadding: 4
					}
				}
			}
			TableView {
				id: exchangesTable
				anchors.top: exchangesTableHeader.bottom
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.bottom: parent.bottom
				anchors.topMargin: rowSpacing

				interactive: false

				selectionBehavior: TableView.SelectRows
				selectionModel: ItemSelectionModel {}

				model: exchangesModel
				
				boundsBehavior: Flickable.StopAtBounds				

				columnSpacing: 1
				rowSpacing: 1

				columnWidthProvider: col => {
					return width / columns - (columnSpacing * columns / (columns + 1))
				}
				rowHeightProvider: row => {
					return 20
				}
				
				alternatingRows: true
				
				delegate: Rectangle {
					required property bool current
					required property bool selected

					color: row === selectedRow
						? palette.highlight
						: (exchangesTable.alternatingRows && row % 2 !== 0
						? palette.alternateBase
						: palette.base)
					PlasmaComponents.Label {
						text: {
							switch(column){
								case 0: {
									return Crypto.getExchangeName(display)
								}
								case 1: {
									return Crypto.getCryptoName(display)
								}
								case 2: {
									return Crypto.getCurrencyName(display)
								}
							}
						}
					}
					MouseArea {
						anchors.fill: parent
						onClicked: {
							selectedRow = row
						}
						onDoubleClicked: {
							editExchange(row)
						}
					}
				}		
			} // TableView
		} // TableContainer

		ColumnLayout {
			id: tableActionButtons
			Layout.alignment: Qt.AlignTop

			PlasmaComponents.Button {
				text: i18n("Add")
				icon.name: "list-add"
				onClicked: addExchange()
			}

			PlasmaComponents.Button {
				text: i18n("Edit")
				icon.name: "edit-entry"
				onClicked: editExchange(selectedRow)
				enabled: {
					// TableView seem to have a bug that makes it think row 0 is selected
					// even if there's no data in model and table view is empty. So we need
					// to check for that case here.
					var idx = selectedRow
					return (idx !== -1) && (idx < exchangesModel.rowCount)
				}
			}

			PlasmaComponents.Button {
				text: i18n("Remove")
				icon.name: "list-remove"
				onClicked: removeExchange(selectedRow)
				enabled: {
					// TableView seem to have a bug that makes it think row 0 is selected
					// even if there's no data in model and table view is empty. So we need
					// to check for that case here.
					var idx = selectedRow
					return (idx !== -1) && (idx < exchangesModel.rowCount)
				}
			}

			PlasmaComponents.Button {
				text: i18n("Move Up")
				icon.name: "arrow-up"
				onClicked: {
					var from = selectedRow
					var to = --selectedRow
					//exchangesTable.selection.clear()
					exchangesModel.moveRow(from, to, 1)
					//exchangesTable.selection.select(to)
					saveExchanges()
				}
				enabled: {
					// TableView seem to have a bug that makes it think row 0 is selected
					// even if there's no data in model and table view is empty. So we need
					// to check for that case here.
					var idx = selectedRow
					return (idx > 0) && (idx < exchangesModel.rowCount)
				}
			}

			PlasmaComponents.Button {
				text: i18n("Move Down")
				icon.name: "arrow-down"
				onClicked: {
					var from = selectedRow
					var to = ++selectedRow
					//exchangesTable.selection.clear()
					exchangesModel.moveRow(from, to, 1)
					//exchangesTable.selection.select(to)
					saveExchanges()
				}
				enabled: {
					// TableView seem to have a bug that makes it think row 0 is selected
					// even if there's no data in model and table view is empty. So we need
					// to check for that case here.
					var idx = selectedRow
					return (idx !== -1) && ((idx+1) < exchangesModel.rowCount)
				}
			}
		} // ColumnLayout
	} // RowLayout

	// ------------------------------------------------------------------------------------------------------------------------

	property int selectedRow: -1

	function saveExchanges() {
		var exchanges = []
		for(var i=0; i<exchangesModel.rowCount; i++) {
			exchanges.push(exchangesModel.getRow(i))
		}
		serializedExchanges.text = JSON.stringify(exchanges)
	}

	function addExchange() {
		exchange.init()
		selectedRow = -1
		exchangeEditDialog.visible = true
	}

	function editExchange(idx) {
		if (idx === -1) return

		// TableView seem to have a bug that makes it think row 0 is selected
		// even if there's no data in model and table view is empty. So we need
		// to check for that case here.
		if ((idx+1) > exchangesModel.rowCount) return

		exchange.fromJson(exchangesModel.getRow(idx))

		selectedRow = idx
		exchangeEditDialog.visible = true
	}

	function removeExchange(idx) {
		if (idx === -1) return

		// TableView seem to have a bug that makes it think row 0 is selected
		// even if there's no data in model and table view is empty. So we need
		// to check for that case here.
		if ((idx+1) > exchangesModel.rowCount) return

		exchangesTable.model.removeRow(idx)
		saveExchanges()
	}

	// ------------------------------------------------------------------------------------------------------------------------

	QtControls.Dialog {
		id: exchangeEditDialog
		height: configExchanges.height
		width: configExchanges.width
		visible: false
		title: i18n("Exchange")
		standardButtons: QtControls.DialogButtonBox.Save | QtControls.DialogButtonBox.Cancel

		onAccepted: {
			var ex = exchange.toJson()
			if (selectedRow === -1) {
				exchangesModel.appendRow(ex)
			} else {
				exchangesModel.setRow(selectedRow, ex)
			}
			saveExchanges();
		}

		Flickable{
			anchors.fill: parent
			clip: true
			
			ExchangeConfig {
				height: 100
				anchors.fill: parent
				id: exchange
			}
		}
		
	}

} // Item
