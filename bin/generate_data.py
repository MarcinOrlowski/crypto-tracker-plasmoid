#!/usr/bin/env python3

######################################################################
#
# Crypto Tracker widget for KDE
#
# @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
# @copyright 2021-2026 Marcin Orlowski
# @license   http://www.opensource.org/licenses/mit-license.php MIT
# @'LINK'      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
#
######################################################################
#
# Purpose of this script:
# - Validates data integrity and completenes
# - Generates exchange data matrix for the widget
#
# Usage (use -h or --help for more info):
#   generate_data.py -o src/contents/js/crypto_data.js
#
######################################################################

import math
import argparse
import collections
import json
import multiprocessing as mp
import os
import re
import requests as req
import signal
import sys
import time
from typing import Optional, Callable, Dict, List


######################################################################

def abort(msg: str = 'Aborted') -> None:
    print('*** {}'.format(msg))
    sys.exit(1)


# Returns current timestamp in millis
def now() -> int:
    return int(round(time.time() * 1000))


######################################################################

def signal_handler(signal, frame):
    sys.exit(1)


signal.signal(signal.SIGINT, signal_handler)

######################################################################

CACHE_THRESHOLD = '30d'
CACHE_DIR_NAME = '~/.cryto-tracker-plasmoid-gen-cache'


######################################################################

class Config:
    def __init__(self, args):
        self.verbose = args.verbose
        self.use_cache = not args.no_cache
        self.cache_threshold = args.cache_threshold
        self.file = args.file
        self.force = args.force
        self.dry_run = args.dry_run
        self.show = args.show
        self.no_gauge = args.no_gauge
        self.exchange_filter = args.exchange
        self.debug = args.debug

        if self.debug:
            self.no_gauge = True


######################################################################

def threshold(arg_value: str) -> int:
    pat = re.compile(r"^([0-9]{1,3})([hdwmy]?)$")
    match = pat.match(arg_value)
    if not match:
        raise argparse.ArgumentTypeError

    val = int(match.group(1))
    unit = match.group(2)

    if val == 0:
        raise argparse.ArgumentTypeError

    # in millis
    MIN = 60 * 1000
    HOUR = MIN * 60
    DAY = 24 * HOUR

    multiplier = MIN
    if unit != '':
        mm = {
            'h': HOUR,
            'd': DAY,
            'w': 7 * DAY,
            'm': 30 * DAY,
            'y': 365 * DAY,
        }
        multiplier = mm[unit]

    # returning value in millis
    return val * multiplier * 60 * 1000


######################################################################

parser = argparse.ArgumentParser()
ag = parser.add_argument_group('Options')
ag.add_argument('-t', '--threshold', action = 'store', dest = 'cache_threshold', type = threshold, default = CACHE_THRESHOLD,
                help = 'Cache validity threshold in format XXXZ where XXX is number in range 1-999, '
                       'Z is (optional) units specifier: "h", "d", "w", "m", "y". If unit is not specified, '
                       'minutes are used. Default value: {}'.format(CACHE_THRESHOLD))
ag.add_argument('-n', '--nocache', action = 'store_true', dest = 'no_cache', default = False,
                help = 'Ignore validation result cache and always do the full API check.')
ag.add_argument('-o', '--out', action = 'store', dest = 'file', type = str,
                help = 'Optional. Name of JS file to be generated.')
ag.add_argument('-s', '--show', action = 'store_true', dest = 'show', default = False,
                help = 'Output generated JS code to stdout.')
ag.add_argument('-f', '--force', action = 'store_true', dest = 'force',
                help = 'Enforces ignoring certain issues (missing icons, existing target file).')
ag.add_argument('-e', '--exchange', action = 'store', dest = 'exchange', type = str,
                help = 'ID of exchange to process. Only this exchange will be used. In such case, "disabled" is ignored.')
ag.add_argument('-v', '--verbose', action = 'store_true', dest = 'verbose', default = False)
ag.add_argument('-g', '--nogauge', action = 'store_true', dest = 'no_gauge', default = False)
ag.add_argument('-r', '--dry-run', action = 'store_true', dest = 'dry_run', default = False)
ag.add_argument('-d', '--debug', action = 'store_true', dest = 'debug', default = False)
config = Config(parser.parse_args())

if config.file is not None and not config.force and os.path.exists(config.file):
    abort('File already exists: {}'.format(config.file))

######################################################################

currencies = {
    '1INCH': {'name': '1inch', },
    'ADA':   {'name': 'Cardano', },
    'ATOM':  {'name': 'Cosmos', },
    'BCH':   {'name': 'Bitcoin Cash', 'symbol': '฿', },
    'BNB':   {'name': 'Binance Coin', },
    'BNT':   {'name': 'Bancor', },
    'BSV':   {'name': 'Bitcoin SV', },
    'BTC':   {'name': 'Bitcoin', 'symbol': '₿', },
    'BTG':   {'name': 'Bitcoin Gold', },
    'BTT':   {'name': 'BitTorrent', },
    'BUSD':  {'name': 'Binance USD', 'symbol': 'B$', },
    'COMP':  {'name': 'Compound', },
    'CZK':   {'name': 'Czech Krown', 'symbol': 'Kč', },
    'DASH':  {'name': 'Dash', },
    'DOGE':  {'name': 'Dogecoin', },
    'DOT':   {'name': 'Polkadot', },
    'EOS':   {'name': 'EOS', },
    'ETC':   {'name': 'Ethereum Classic', },
    'ETH':   {'name': 'Ethereum', 'symbol': 'Ξ', },
    'EUR':   {'name': 'Euro', 'symbol': '€', },
    'FIL':   {'name': 'Filecoin', },
    'GAME':  {'name': 'GameCredits', },
    'GBP':   {'name': 'British Pound', 'symbol': '£', },
    'GLM':   {'name': 'Golem', },
    'JPY':   {'name': 'Japanese Yen', 'symbol': '¥', },
    'LINK':  {'name': 'Chainlink', },
    'LSK':   {'name': 'Lisk', },
    'LTC':   {'name': 'Litecoin', 'symbol': 'Ł', },
    'LUNA':  {'name': 'Terra', },
    'MKR':   {'name': 'Maker', },
    'PLN':   {'name': 'Polish Zloty', 'symbol': 'zł', },
    'SOL':   {'name': 'Solana', },
    'THETA': {'name': 'Theta', },
    'UNI':   {'name': 'Uniswap', },
    'USD':   {'name': 'US Dollar', 'symbol': '$', },
    'USDC':  {'name': 'USD Coin', 'symbol': '$C', },
    'USDT':  {'name': 'USD Tether', 'symbol': '$T', },
    'WBTC':  {'name': 'Wrapped Bitcoin', },
    'XLM':   {'name': 'Stellar', },
    'XMR':   {'name': 'Monero', },
    'XRP':   {'name': 'Ripple', 'symbol': 'Ʀ', },
    'XTZ':   {'name': 'Tezos', },
    'ZEC':   {'name': 'ZCash', },
    'ZRX':   {'name': '0x', },
}


######################################################################

class TestResult:
    def __init__(self, ex_code: str, crypto: str, pair: str, rc: bool = False, stamp: int = None,
                 cached: bool = False, use_cache: bool = True, cache_dir: str = None):
        self.ex_code = ex_code
        self.crypto = crypto
        self.pair = pair

        self.rc = rc
        self.stamp = stamp if stamp else now()
        self.cached = cached
        self.use_cache = use_cache

        # path to target location for cache files for specified exchange that produced this object
        self.cache_dir = cache_dir

    def cache_load(self, cache_threshold: int) -> bool:
        result = False
        if self.use_cache:
            cache_file = os.path.join(self.cache_dir, '{}-{}'.format(self.crypto, self.pair))
            if os.path.exists(cache_file):
                with open(cache_file, 'r') as fh:
                    try:
                        cached_data = json.load(fh)
                        if now() < (cached_data['stamp'] + cache_threshold):
                            self.rc = cached_data['rc']
                            self.stamp = cached_data['stamp']
                            self.cached = True
                            result = True
                    except json.JSONDecodeError:
                        # In case cache file is corrupted.
                        pass
        return result

    def cache_save(self) -> None:
        if self.use_cache:
            cache_file = os.path.join(self.cache_dir, '{}-{}'.format(self.crypto, self.pair))
            if not os.path.exists(self.cache_dir):
                os.makedirs(self.cache_dir)

            with open(cache_file, 'w') as fh:
                cache = {'rc': self.rc, 'stamp': self.stamp, }
                fh.write(json.dumps(cache))


######################################################################

class Exchange:
    def __init__(self, code: str, name: str, url: str, api_url: str = None,
                 functions: Dict[str, str] = None, disabled: bool = False, cache_dir: str = None,
                 valid_ticker_pairs: List[str] = None, config: Config = None):
        self.code = code
        self.name = name
        self.url = url
        self.api_url = api_url
        self.functions = functions if functions else {}
        self.disabled = disabled

        self.pairs = collections.OrderedDict()
        self.cache_dir = cache_dir
        self.valid_ticker_pairs = valid_ticker_pairs

        self.config = config

    def is_ticker_valid(self, response) -> bool:
        return response.status_code == req.codes.ok

    def is_ticker_pair_valid(self, crypto: str, pair: str) -> bool:
        # all pairs allowed unless list is explicitly given
        if self.valid_ticker_pairs is None:
            return True
        return crypto + pair in self.valid_ticker_pairs

    def pair_exists(self, item: str, pair: str) -> bool:
        return item == pair or (item in self.pairs and pair in self.pairs[item])

    def add_pair(self, crypto: str, pair: str):
        if crypto not in self.pairs:
            self.pairs[crypto] = []

        if pair not in self.pairs[crypto]:
            self.pairs[crypto].append(pair)

    def build_tr_object(self, crypto: str, pair: str, config: Config) -> "TestResult":
        tr = TestResult(ex_code = self.code, crypto = crypto, pair = pair,
                        use_cache = config.use_cache, cache_dir = self.cache_dir)
        tr.cache_load(config.cache_threshold)
        return tr

    def do_api_call(self, queue, tr: TestResult) -> None:
        url = self.api_url.format(crypto = tr.crypto, pair = tr.pair)
        response = req.get(url)
        tr.rc = self.is_ticker_valid(response)
        self.d('#{sc} isValid:{rc} {url}'.format(url = url, sc = response.status_code, rc = tr.rc))
        queue.put(tr)

    def do_api_call_error_callback(self, msg: str) -> None:
        print('Error Callback: {}'.format(msg))

    def d(self, msg):
        if self.config.debug:
            print(msg)


######################################################################

class Binance(Exchange):
    def is_ticker_valid(self, response: req.Response) -> bool:
        if response.status_code != req.codes.ok:
            return False
        resp = json.loads(response.text)
        if not isinstance(resp, List):
            return False
        for field in ['id', 'price', 'qty', 'quoteQty', 'time', ]:
            if field not in resp:
                return False

        return True

class Bitstamp(Exchange):
    def do_api_call(self, queue, tr: TestResult) -> None:
        url = self.api_url.format(crypto = tr.crypto.lower(), pair = tr.pair.lower())
        response = req.get(url)
        tr.rc = self.is_ticker_valid(response)
        self.d('#{sc} isValid:{rc} {url}'.format(url = url, sc = response.status_code, rc = tr.rc))
        queue.put(tr)

class Bitbay(Exchange):
    def is_ticker_valid(self, response: req.Response) -> bool:
        if response.status_code != req.codes.ok:
            return False

        resp = json.loads(response.text)
        for field in ['min', 'max', 'last', 'bid', 'ask', ]:
            if field not in resp:
                return False
        return True

class Coinmate(Exchange):
    def is_ticker_valid(self, response: req.Response) -> bool:
        if response.status_code != req.codes.ok:
            return False

        resp = json.loads(response.text)
        if resp.get('error', False) or 'data' not in resp:
            return False
        for field in ['ask', 'bid', 'change', 'last', ]:
            if field not in resp['data']:
                return False
        return True


class Kraken(Exchange):
    def is_ticker_valid(self, response: req.Response) -> bool:
        if response.status_code != req.codes.ok:
            return False

        resp = json.loads(response.text)
        if len(resp.get('error', [])) > 0:
            return False
        if 'result' not in resp:
            return False

        key = list(resp['result'].keys())[0]
        if key not in resp['result']:
            return False
        for field in ['a', 'b', 'c', 'l', ]:
            if field not in resp['result'][key]:
                return False
        return True


######################################################################

class ExchangesIterator:
    def __init__(self, container: "Exchanges"):
        self._container = container
        self._index = 0

    def __next__(self) -> Exchange:
        if self._index >= self._container.count():
            raise StopIteration

        ex = self._container.get(self._index)
        self._index += 1
        return ex


class Exchanges:
    def __init__(self, config: Config, cache_dir: str = None):
        self._container = collections.OrderedDict()
        self.config = config
        self.cache_dir = os.path.expanduser(CACHE_DIR_NAME) if cache_dir is None else cache_dir
        self._queue = mp.Manager().Queue()

    def __iter__(self):
        return ExchangesIterator(self)

    def count(self) -> int:
        return len(self._container)

    def add(self, ex: Exchange) -> None:
        """
        Adds new Exchange to Exchanges container. Also populates its cache_dir root folder

        :param ex: subclass of Exchange to be added
        :return: None
        """
        if ex.code in self._container:
            raise ValueError('Exchange with key "{}" already exists.'.format(ex.code))

        ex.cache_dir = os.path.join(self.cache_dir, ex.code)
        ex.config = self.config
        self._container[ex.code] = ex

    def get(self, idx_or_key) -> Optional[Exchange]:
        if isinstance(idx_or_key, int):
            return self._get_by_index(idx_or_key)
        elif isinstance(idx_or_key, str):
            return self._get_by_key(idx_or_key)

    def _get_by_key(self, key: str) -> Optional[Exchange]:
        return self._container[key]

    def _get_by_index(self, idx: int) -> Optional[Exchange]:
        if idx >= len(self._container):
            raise IndexError
        keys = list(self._container.keys())
        return self._container.get(keys[idx])

    def filter_exchanges(self) -> None:
        """
        Cleans up exchange container either removing disabled exchanges, or if config.exchange_filter
        is set, removing all but matching the filter.

        :return:
        """
        to_be_removed = []
        if self.config.exchange_filter is None:
            for _, ex in self._container.items():
                if ex.disabled:
                    to_be_removed.append(ex)
        else:
            ex_filter = self.config.exchange_filter
            self.verbose('Filtering exchanges: "{}"'.format(ex_filter))
            for _, ex in self._container.items():
                if ex.code.find(ex_filter) >= 0 or ex.name.find(ex_filter) >= 0:
                    self.verbose('  {} ({}) matches'.format(ex.name, ex.code))
                    ex.disabled = False
                else:
                    to_be_removed.append(ex.code)

        for code in to_be_removed:
            del self._container[code]

    def process_exchanges(self, currencies: Dict[str, Dict]) -> None:
        # Cycling thru all exchanges we need to check to avoid doing single API endpoint flood
        total_number_of_checks = 0

        self.filter_exchanges()

        pool = mp.Pool(processes = 6)
        for curr_key, curr_data in currencies.items():
            for pair_key, pair_data in currencies.items():
                for _, ex in self._container.items():
                    if not ex.is_ticker_pair_valid(curr_key, pair_key):
                        continue

                    tr = ex.build_tr_object(curr_key, pair_key, config)
                    if tr.cached:
                        self._queue.put(tr)
                    else:
                        pool.apply_async(func = ex.do_api_call, args = (self._queue, tr,),
                                         error_callback = ex.do_api_call_error_callback)
                    total_number_of_checks += 1

        # No more pool submissions
        pool.close()

        # Waiting for processes to complete...
        pair_success_cnt = pair_skipped_cnt = pair_from_cache = 0
        cnt = 0
        msg = ''
        while cnt < total_number_of_checks:
            response: TestResult = self._queue.get()
            if response.rc:
                ex = self.get(response.ex_code)
                ex.add_pair(response.crypto, response.pair)
                pair_success_cnt += 1
            else:
                pair_skipped_cnt += 1

            if response.cached:
                pair_from_cache += 1
            elif not config.dry_run:
                response.cache_save()

            if not config.no_gauge:
                gauge_max = 60
                gauge_progress = math.floor(gauge_max * (cnt / total_number_of_checks))
                # first char in msg is space so console cursor mimics first block (usually)
                msg = ' {}{}: {} of {}'.format('█' * gauge_progress, '░' * (gauge_max - gauge_progress),
                                               cnt, total_number_of_checks)
                print(msg, end = '\r')

            cnt += 1

        # clear last progress message
        print(' ' * len(msg), end = '\r')

        # to ensure we do not leave too early (should not happen though)
        pool.join()

        # Summary
        print('Total {total} pairs ({cache_percent:>.0f}% cached), invalid: {skipped}, confirmed: {paired}'.format(
            total = cnt, paired = pair_success_cnt, skipped = pair_skipped_cnt,
            cache_cnt = pair_from_cache, cache_percent = (pair_from_cache * 100) / cnt))

    def d(self, msg):
        if self.config.debug:
            print(msg)

    def verbose(self, msg):
        if self.config.verbose:
            print(msg)


######################################################################

exchanges = Exchanges(config, os.path.expanduser(CACHE_DIR_NAME))
exchanges.add(
    Binance(
        # disabled = True,
        code = 'binance-com',
        name = 'Binance',
        url = 'https://binance.com/',
        api_url = 'https://api1.binance.com/api/v3/ticker/price?symbol={crypto}{pair}',

        functions = {
            'getRateFromExchangeData': 'return data.price',
            # https://www.binance.com/en/markets
            'getUrl': 'return `https://api1.binance.com/api/v3/ticker/price?symbol=${crypto}${pair}`',
        },
    ))

exchanges.add(
    Bitstamp(
        # disabled = True,
        code = 'bitstamp-net',
        name = 'Bitstamp',
        url = 'https://bitstamp.net/',
        api_url = 'https://www.bitstamp.net/api/v2/ticker/{crypto}{pair}',

        # as per GET method docs https://www.bitstamp.net/api/#ticker
        valid_ticker_pairs = [
            'BTCUSD', 'BTCEUR', 'BTCGBP', 'BTCPAX', 'BTCUSDC', 'GBPUSD', 'GBPEUR', 'EURUSD', 'ETHUSD', 'ETHEUR', 'ETHBTC', 'ETHGBP',
            'ETHPAX', 'ETHUSDC', 'XRPUSD', 'XRPEUR', 'XRPBTC', 'XRPGBP', 'XRPPAX', 'UNIUSD', 'UNIEUR', 'UNIBTC', 'LTCUSD', 'LTCEUR',
            'LTCBTC', 'LTCGBP', 'LINKUSD', 'LINKEUR', 'LINKGBP', 'LINKBTC', 'LINKETH', 'XLMBTC', 'XLMUSD', 'XLMEUR', 'XLMGBP',
            'BCHUSD', 'BCHEUR', 'BCHBTC', 'BCHGBP', 'AAVEUSD', 'AAVEEUR', 'AAVEBTC', 'ALGOUSD', 'ALGOEUR', 'ALGOBTC', 'SNXUSD',
            'SNXEUR', 'SNXBTC', 'BATUSD', 'BATEUR', 'BATBTC', 'MKRUSD', 'MKREUR', 'MKRBTC', 'ZRXUSD', 'ZRXEUR', 'ZRXBTC', 'YFIUSD',
            'YFIEUR', 'YFIBTC', 'UMAUSD', 'UMAEUR', 'UMABTC', 'OMGUSD', 'OMGEUR', 'OMGGBP', 'OMGBTC', 'KNCUSD', 'KNCEUR', 'KNCBTC',
            'CRVUSD', 'CRVEUR', 'CRVBTC', 'AUDIOUSD', 'AUDIOEUR', 'AUDIOBTC', 'USDCUSD', 'USDCEUR', 'DAIUSD', 'PAXUSD', 'PAXEUR',
            'PAXGBP', 'ETH2ETH', 'GUSDUSD',
        ],

        functions = {
            'getRateFromExchangeData': 'return data.ask',
            'getUrl': 'return `https://www.bitstamp.net/api/v2/ticker/${crypto.toLowerCase()}${pair.toLowerCase()}`'
        },
    ))

exchanges.add(
    Bitbay(
        # disabled = True,
        code = 'bitbay-net',
        name = 'BitBay',
        url = 'https://bitbay.net/',
        api_url = 'https://api.zonda.exchange/rest/trading/ticker/{crypto}-{pair}',

        functions = {
            'getRateFromExchangeData': 'return data.ask',
            'getUrl': 'return `https://api.zonda.exchange/rest/trading/ticker/${crypto}-${pair}`'
        },
    ))

exchanges.add(
    Coinmate(
        # disabled = True,
        code = 'coinmate-io',
        name = 'Coinmate',
        url = 'https://coinmate.io/',
        api_url = 'https://coinmate.io/api/ticker?currencyPair={crypto}_{pair}',

        # https://coinmate.io/trade
        functions = {
            'getRateFromExchangeData': 'return data.data.ask',
            'getUrl': 'return `https://coinmate.io/api/ticker?currencyPair=${crypto}_${pair}`',
        },
    ))

exchanges.add(
    Kraken(
        # disabled = True,

        code = 'kraken-com',
        name = 'Kraken',
        url = 'https://kraken.com/',
        api_url = 'https://api.kraken.com/0/public/Ticker?pair={crypto}{pair}',

        # https://support.kraken.com/hc/en-us/articles/360001185506
        # https://support.kraken.com/hc/en-us/articles/201893658-Currency-pairs-available-for-trading-on-Kraken

        functions = {
            # some tricks to work around odd asset naming used in returned response as main key
            'getRateFromExchangeData': "return data.result[Object.keys(data['result'])[0]].a[0]",
            'getUrl': 'return `https://api.kraken.com/0/public/Ticker?pair=${crypto}${pair}`',
        },
    ))


######################################################################

def build_header() -> List[str]:
    return [
        '// This file is auto-generated. DO NOT EDIT BY HAND',
        '// Use generate_data.py to rebuild this file if needed',
        '',
        '// https://doc.qt.io/qt-5/qtqml-javascript-resources.html',
        '.pragma library',
        '',
    ]


def build_currencies(currencies: Dict[str, Dict]) -> List[str]:
    # currency and token info
    result = [
        'var currencies = {',
    ]

    keys = list(currencies.keys())
    keys.sort()
    for key in keys:
        data: Dict = currencies[key]
        symbol = None if 'symbol' not in data else '"{}"'.format(data['symbol'])

        row = '\t"{}": {{'.format(key)
        code = key.upper()

        row += '"code": "{}", '.format(code)
        if data['name'] != code:
            row += '"name": "{}", '.format(data['name'])
        if symbol:
            row += '"symbol": {}, '.format(symbol)
        row += '},'
        result.append(row)
    result.append('}')

    return result


def build_exchanges(exchanges: List[Exchange]) -> List[str]:
    result = [
        'var exchanges = {',
    ]

    for ex in exchanges:
        result += [
            '\t"{}": {{'.format(ex.code),
            '\t\t"name": "{}",'.format(ex.name),
            '\t\t"url": "{}",'.format(ex.url),
            '\t\t"getUrl": function(crypto, pair) {',
            '\t\t\t{}'.format(ex.functions['getUrl']),
            '\t\t},',
            '\t\t"getRateFromExchangeData": function(data, crypto, pair) {',
            '\t\t\t{}'.format(ex.functions['getRateFromExchangeData']),
            '\t\t},',
        ]
        result.append('\t\t"pairs": {')
        for crypto, pairs in ex.pairs.items():
            pairs.sort()
            row = '\t\t\t"{crypto}": ['.format(crypto = crypto)
            row += ''.join(['"{}",'.format(pair) for pair in pairs])
            row += '],'
            result.append(row)
        result += [
            '\t\t},',
            '\t},',
        ]

    result += ['}', '']

    return result


######################################################################

def check_icons(currencies: List[str]) -> int:
    my_dir = os.path.dirname(os.path.realpath(__file__))
    img_dir = os.path.join(my_dir, '../src/contents/images/')

    ignored = ['CZK', 'EUR', 'GBP', 'JPY', 'PLN', ]

    cnt = skipped = 0
    header_shown = False
    for pair in currencies:
        if pair in ignored:
            skipped += 1
            continue

        icon_file = os.path.join(img_dir, '{}.svg'.format(pair.lower()))
        res = os.path.exists(icon_file)
        if not res:
            if not header_shown:
                print('  Missing icons:')
                header_shown = True
            print('    {}'.format(icon_file))
            cnt += 1
    print('Total {} coins in use, {} icons skipped, {} missing'.format(len(currencies), skipped, cnt))
    return cnt


######################################################################


exchanges.process_exchanges(currencies)

# check for icons of used coins
curr = list(currencies.keys())
curr.sort()
missing_icons_cnt = check_icons(curr)
if missing_icons_cnt != 0 and not config.force:
    abort('Missing {} currency icons.'.format(missing_icons_cnt))

if config.show or config.file is not None:
    buffer = build_header()
    buffer += build_currencies(currencies)
    buffer += build_exchanges(exchanges)

    if config.show:
        print('\n'.join(buffer))

    if config.file is not None and not config.dry_run:
        try:
            with open(config.file, 'w') as fh:
                fh.writelines('\n'.join(buffer))
        except IOError:
            abort('Failed writing to: {}'.format(config.file))
