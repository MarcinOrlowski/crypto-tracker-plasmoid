#!/usr/bin/env python3

######################################################################
#
# Crypto Tracker widget for KDE
#
# @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
# @copyright 2021 Marcin Orlowski
# @license   http://www.opensource.org/licenses/mit-license.php MIT
# @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
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

import copy
import argparse
import collections
import json
import multiprocessing as mp
import os
import re
import requests as req
import sys
import time
from typing import Optional, Callable, Dict, List

######################################################################

CACHE_THRESHOLD = '30d'
CACHE_DIR_NAME = '~/.cryto-tracker-plasmoid-gen-cache'


######################################################################

class TestResult:
    def __init__(self, ex_code: str, crypto: str, pair: str, rc: bool = False, stamp: int = None, cached: bool = False,
                 use_cache: bool = True, cache_dir: str = None):
        self.ex_code = ex_code
        self.crypto = crypto
        self.pair = pair

        self.rc = rc
        self.stamp = stamp if stamp else now()
        self.cached = cached
        self.use_cache = use_cache

        # path to target location for cache files for specified exchange that factoried this object
        self.cache_dir = cache_dir

    def cache_load(self, cache_threshold: int) -> bool:
        result = False
        if self.use_cache:
            cache_file = os.path.join(self.cache_dir, '{}-{}'.format(self.crypto, self.pair))
            if os.path.exists(cache_file):
                with open(cache_file, 'r') as fh:
                    cached_data = json.load(fh)
                    if now() < (cached_data['stamp'] + cache_threshold):
                        self.rc = cached_data['rc']
                        self.stamp = cached_data['stamp']
                        self.cached = True
                        result = True
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

class Config:
    def __init__(self, args):
        self.verbose = args.verbose
        self.use_cache = not args.no_cache
        self.cache_threshold = args.cache_threshold
        self.file = args.file
        self.force = args.force
        self.dry_run = args.dry_run
        self.show = args.show


######################################################################

class Exchange():
    def __init__(self, code: str, name: str, url: str, api_url: str, currencies: List[str], functions: Dict[str, str],
                 disabled: bool = False, cache_dir: str = None):
        self.code = code
        self.name = name
        self.url = url
        self.api_url = api_url
        self.currencies = currencies
        self.functions = functions
        self.disabled = disabled

        self.pairs = collections.OrderedDict()
        self.cache_dir = cache_dir

    @property
    def currencies(self) -> List[str]:
        return self._currencies

    @currencies.setter
    def currencies(self, val: List[str]) -> None:
        # cheap trick to remove list duplicates
        items = list(dict.fromkeys(val))
        items.sort()
        self._currencies = items

    def _validate(self, response: req.Response, crypto: str, pair: str) -> bool:
        return response.status_code == req.codes.ok

    def is_ticker_valid(self, response, crypto: str, pair: str) -> bool:
        return self._validate(response, crypto, pair)

    def pair_exists(self, item: str, pair: str) -> bool:
        return item == pair or (item in self.pairs and pair in self.pairs[item])

    def add_pair(self, crypto: str, pair: str):
        if crypto not in self.pairs:
            self.pairs[crypto] = []

        if pair not in self.pairs[crypto]:
            self.pairs[crypto].append(pair)

    def download_ticker(self, crypto, pair):
        url = self.api_url.format(crypto = crypto, pair = pair)
        return req.get(url)

    def build_tr_object(self, crypto: str, pair: str, use_cache: bool, cache_threshold: int) -> "TestResult":
        tr = TestResult(ex_code = self.code, crypto = crypto, pair = pair, use_cache = use_cache, cache_dir = self.cache_dir)
        tr.cache_load(cache_threshold)
        return tr


class Bitbay(Exchange):
    def _validate(self, response: req.Response, crypto: str, pair: str) -> bool:
        if response.status_code != req.codes.ok:
            return False

        resp = json.loads(response.text)
        for field in ['min', 'max', 'last', 'bid', 'ask', ]:
            if field not in resp:
                return False
        return True


class Coinmate(Exchange):
    def _validate(self, response: req.Response, crypto: str, pair: str) -> bool:
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
    def _validate(self, response: req.Response, crypto: str, pair: str) -> bool:
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
    def __init__(self, cache_dir: str = None):
        self._container = collections.OrderedDict()
        self.cache_dir = os.path.expanduser(CACHE_DIR_NAME) if cache_dir is None else cache_dir
        self.config = None

        self._queue = None
        self._pool = None

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

    def init(self, config: Config):
        self.config = config

        self._pool = mp.Pool(processes = 6)
        self._queue = mp.Manager().Queue()

    def do_api_call(self, tr: TestResult) -> None:
        ex = self.get(tr.ex_code)
        response = ex.download_ticker(tr.crypto, tr.pair)
        tr.rc = ex.is_ticker_valid(response, tr.crypto, tr.pair)
        self._queue.put(tr)

    def do_api_call_error_callback(self, msg: str) -> None:
        print('Error Callback: {}'.format(msg))

    def process_single_exchange(self, ex: Exchange) -> int:
        """
        Pair all currencies of given Exchange (each with each other).

        :param ex:

        :return: Number of elements queued for API checks.
        """

        if self.config.verbose:
            print('  Processing {}'.format(ex.code))
        total_number_of_checks = 0
        for item in ex.currencies:
            for pair in ex.currencies:
                if ex.pair_exists(item, pair):
                    continue

                tr = ex.build_tr_object(item, pair, self.config.use_cache, self.config.cache_threshold)
                if tr.cached:
                    self._queue.put(tr)
                else:
                    self._pool.apply_async(func = self.do_api_call, args = (tr,),
                                           error_callback = self.do_api_call_error_callback)
                total_number_of_checks += 1

        return total_number_of_checks

    def process_exchanges(self) -> None:
        # remove non enabled exchanges
        disabled = [key for key, ex in self._container.items() if ex.disabled]
        for key in disabled:
            del self._container[key]

        total_number_of_checks = 0
        for _, ex in self._container.items():
            total_number_of_checks += self.process_single_exchange(ex)

        # No more pool submissions
        self._pool.close()

        # Waiting for processes to complete...
        pair_success_cnt = pair_skipped_cnt = pair_from_cache = 0
        cnt = 0
        while cnt < total_number_of_checks:
            response: TestResult = self._queue.get()
            if response.rc:
                ex = self.get(response.ex_code)
                ex.add_pair(response.crypto, response.pair)
                pair_success_cnt += 1
            else:
                pair_skipped_cnt += 1

            if not response.cached:
                if not config.dry_run:
                    response.cache_save()
            else:
                pair_from_cache += 1

            cnt += 1
            print('  {} of {}...'.format(cnt, total_number_of_checks), end = '\r')

        # to ensure we do not leave too early (should not happen though)
        self._pool.join()

        # Summary
        print('Total {total} pairs ({cache_percent:>.0f}% cached), invalid: {skipped}, confirmed: {paired}'.format(
            total = cnt, paired = pair_success_cnt, skipped = pair_skipped_cnt,
            cache_cnt = pair_from_cache, cache_percent = (pair_from_cache * 100) / cnt))


######################################################################

ada = 'ADA'
bch = 'BCH'
bsv = 'BSV'
btc = 'BTC'
btg = 'BTG'
comp = 'COMP'
dash = 'DASH'
dot = 'DOT'
etc = 'ETC'
eth = 'ETH'
eur = 'EUR'
game = 'GAME'
gbp = 'GBP'
link = 'LINK'
lsk = 'LSK'
ltc = 'LTC'
luna = 'LUNA'
mkr = 'MKR'
pln = 'PLN'
usd = 'USD'
usdt = 'USDT'
xrp = 'XRP'
zec = 'ZEC'
doge = 'DOGE'
bnb = 'BNB'
fil = 'FIL'
czk = 'CZK'
jpy = 'JPY'
busd = 'BUSD'
usdc = 'USDC'
uni = 'UNI'
xmr = 'XMR'
atom = 'ATOM'
xlm = 'XLM'

######################################################################

name = 'name'
symbol = 'symbol'

currencies = {
    ada:  {name: 'Cardano', },
    atom: {name: 'Cosmos', },
    bch:  {name: 'Bitcoin Cash', symbol: '฿', },
    bnb:  {name: 'Binance Coin', },
    bsv:  {name: 'Bitcoin SV', },
    btc:  {name: 'Bitcoin', symbol: '₿', },
    btg:  {name: 'Bitcoin Gold', },
    busd: {name: 'Binance USD', symbol: 'B$', },
    comp: {name: 'Compound', },
    czk:  {name: 'Czech Krown', symbol: 'Kč', },
    dash: {name: 'Dash', },
    doge: {name: 'Dogecoin', },
    dot:  {name: 'Polkadot', },
    etc:  {name: 'Ethereum Classic', },
    eth:  {name: 'Ethereum', symbol: 'Ξ', },
    eur:  {name: 'Euro', symbol: '€', },
    fil:  {name: 'Filecoin', },
    game: {name: 'GameCredits', },
    gbp:  {name: 'British Pound', symbol: '£', },
    jpy:  {name: 'Japanese Yen', symbol: '¥', },
    link: {name: 'Chainlink', },
    lsk:  {name: 'Lisk', },
    ltc:  {name: 'Litecoin', symbol: 'Ł', },
    luna: {name: 'Terra', },
    mkr:  {name: 'Maker', },
    pln:  {name: 'Polish Zloty', symbol: 'zł', },
    uni:  {name: 'Uniswap', },
    usd:  {name: 'US Dollar', symbol: '$', },
    usdc: {name: 'USD Coin', symbol: '$C', },
    usdt: {name: 'USD Tether', symbol: '$T', },
    xlm:  {name: 'Stellar', },
    xmr:  {name: 'Monero', },
    xrp:  {name: 'Ripple', symbol: 'Ʀ', },
    zec:  {name: 'ZCash', },
}

exchanges = Exchanges(cache_dir = os.path.expanduser(CACHE_DIR_NAME))
exchanges.add(
    Exchange(
        # disabled = True,
        code = 'binance-com',
        name = 'Binance',
        url = 'https://binance.com/',
        api_url = 'https://api1.binance.com/api/v3/trades?limit=1&symbol={crypto}{pair}',

        # https://www.binance.com/en/markets
        currencies = [
            btc, etc, eth, xrp, ada, bnb, doge, fil, link, ltc, xmr, atom, xlm,
            usdt, eur, gbp, bnb, busd,
        ],

        functions = {
            'getRateFromExchangeData': 'return data[0].price',
        },
    ))

exchanges.add(
    Exchange(
        # disabled = True,
        code = 'bitstamp-net',
        name = 'Bitstamp',
        url = 'https://bitstamp.net/',
        api_url = 'https://www.bitstamp.net/api/v2/ticker/{crypto}{pair}',

        # https://www.bitstamp.net/markets/
        currencies = [
            btc, etc, ltc, xrp, uni, eth,
            usd, eur, gbp, usdc
        ],

        functions = {
            'getRateFromExchangeData': 'return data.ask',
        },
    ))

exchanges.add(
    Bitbay(
        # disabled = True,
        code = 'bitbay-net',
        name = 'BitBay',
        url = 'https://bitbay.net/',
        api_url = 'https://bitbay.net/API/Public/{crypto}{pair}/ticker.json',

        currencies = [
            btc, bsv, btg, comp, dash, dot, etc, eth, game, link, lsk, ltc, luna, mkr, xrp, zec, xlm,
            eur, gbp, pln, usd,
        ],

        functions = {
            'getRateFromExchangeData': 'return data.ask',
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
        currencies = [
            btc, eth, ltc, xrp, dash, bch,
            czk, eur,
        ],

        functions = {
            'getRateFromExchangeData': 'return data.data.ask',
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
        currencies = [
            btc, eth, ltc, xrp, ada, doge, dot, etc, zec, atom, xlm,
            usd, eur, gbp, jpy, usdt,
        ],

        functions = {
            # some tricks to work around odd asset naming used in returned response as main key
            'getRateFromExchangeData': "return data.result[Object.keys(data['result'])[0]].a[0]",
        },
    ))


######################################################################


def abort(msg: str = 'Aborted') -> None:
    print('*** {}'.format(msg))
    sys.exit(1)


# Returns current timestamp in millis
def now() -> int:
    return int(round(time.time() * 1000))


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
            '\t\t"api_url": "{}",'.format(ex.api_url),
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
    img_dir = 'src/contents/images/'

    ignored = [czk, eur, gbp, jpy, pln, usd, ]

    cnt = skipped = 0
    header_shown = False
    for pair in currencies:
        if pair in ignored:
            skipped += 1
            continue

        icon_file = os.path.join(img_dir, '{}.svg'.format(pair))
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
ag.add_argument(
    '-t', '--threshold', action = 'store', dest = 'cache_threshold', type = threshold, default = CACHE_THRESHOLD,
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
ag.add_argument('-v', '--verbose', action = 'store_true', dest = 'verbose', default = False)
ag.add_argument('-d', '--dry-run', action = 'store_true', dest = 'dry_run', default = False)
config = Config(parser.parse_args())

if config.file is not None and not config.force and os.path.exists(config.file):
    abort('File already exists: {}'.format(config.file))

exchanges.init(config)
exchanges.process_exchanges()

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
