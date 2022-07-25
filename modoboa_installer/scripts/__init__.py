"""Installation scripts management."""

import importlib
import sys

from .. import utils


def install(appname, config, upgrade):
    """Install an application."""
    if (config.has_option(appname, "enabled") and
            not config.getboolean(appname, "enabled")):
        return
    utils.printcolor("Installing {}".format(appname), utils.MAGENTA)
    try:
        script = importlib.import_module(
            "modoboa_installer.scripts.{}".format(appname))
    except ImportError:
        print("Unknown application {}".format(appname))
        sys.exit(1)
    try:
        getattr(script, appname.capitalize())(config, upgrade).run()
    except utils.FatalError as inst:
        utils.printcolor(u"{}".format(inst), utils.RED)
        sys.exit(1)

def backup(config, bashArg, nomail):
    """Backup instance"""
    try:
        script = importlib.import_module(
                "modoboa_installer.scripts.backup")
    except ImportError:
        print("Error importing backup")
    try:
        getattr(script, "Backup")(config, bashArg, nomail).run()
    except utils.FatalError as inst:
        utils.printcolor(u"{}".format(inst), utils.RED)
        sys.exit(1)
