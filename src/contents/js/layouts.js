/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

// https://doc.qt.io/qt-5/qtqml-javascript-resources.html
.pragma library

const DEFAULT='_default_'

const layouts = {
	'_default_': {
		'name': 'Default',
		'columns': 0,
		'rows': 0,
	},
	'6x1': {
		'name': '6x1',
		'columns': 6,
		'rows': 1,
	},
	'3x2': {
		'name': '3x2',
		'columns': 3,
		'rows': 2,
	},
	'2x3': {
		'name': '2x3',
		'columns': 2,
		'rows': 3,
	},
	'1x6': {
		'name': '1x6',
		'columns': 1,
		'rows': 6,
	},
}

function getLayoutName(key) {
	return layouts[key]['name']
}

function getLayout(key) {
	return layouts[key]
}
