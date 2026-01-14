![Crypto Tracker Logo](img/logo.png)

Crypto Tracker for Plasma 6
===========================
Plasma 6/KDE multi crypto currency price tracker widget, with support for multiple exchanges and currency pairs.

---

## Installation ##

You should be able to install Crypto Tracker widget either using built-in Plasma Add-on installer
or manually, by downloading `*.plasmoid` file either from project
[Github repository](https://github.com/MarcinOrlowski/crypto-tracker-plasmoid/) or
from [KDE Store](https://store.kde.org/p/1481524/)

### Using built-in installer ###

To install widget using Plasma built-in mechanism, press right mouse button over your desktop
or panel and select "Add Widgets..." from the context menu, then "Get new widgets..." eventually
choosing "Download New Plasma Widgets...". Then search for "Crypto Tracker" in "Plasma Add-On Installer" window.

![Plasma Add-On Installer](img/plasma-installer.png)

### Manual installation ###

Download `*.plasmoid` file from [project Release section](https://github.com/MarcinOrlowski/crypto-tracker-plasmoid/releases).
Then you can either install it via Plasmashell's GUI, by clicking right mouse button over your desktop or panel and
selecting "Add widgets...", then "Get new widgets..." eventually choosing "Install from local file..." and pointing to downloaded
`*.plasmoid` file.

Alternatively you can install it using your terminal, with help of `kpackagetool6`:

    kpackagetool6 -t Plasma/Applet --install /PATH/TO/DOWNLOADED/crypto-tracker.plasmoid

## Upgrading ##

If you already have widget running and there's newer release your want to install, use `kpackagetool6`
with `--upgrade` option. This will update current installation while keeping your settings intact:

    kpackagetool6 -t Plasma/Applet --upgrade /PATH/TO/DOWNLOADED/crypto-tracker.plasmoid

**NOTE:** Sometimes, due to Plasma internals, newly installed version may not be instantly seen working,
so you may want to convince Plasma by doing manual reload (this will **NOT** log you out nor affect
other apps):

    systemctl --user restart plasma-plasmashell.service

Alternatively, you can restart the shell manually:

    kquitapp6 plasmashell && kstart plasmashell

