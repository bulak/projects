#!/usr/bin/env python2
# -*- coding: utf-8 -*-

"""Updates the config file of jrnl
"""


import sys
import os
import jrnl


__author__ = "Bulak Arpat"
__copyright__ = "Copyright 2017, Bulak Arpat"
__license__ = "GPLv3"
__version__ = "0.0.1"
__maintainer__ = "Bulak Arpat"
__email__ = "Bulak.Arpat@unil.ch"
__status__ = "Development"


CONFIG_PATH = jrnl.cli.CONFIG_PATH


def _read_config():
    return jrnl.util.load_and_fix_json(CONFIG_PATH)


def _add_new_jrnl(config, jrnl_name, jrnl_path):
    jrnl_file = os.path.join(jrnl_path, "{}_journal.txt".format(jrnl_name))
    config['journals'].update({jrnl_name: jrnl_file})


def _save_config(config):
    jrnl.install.save_config(config, config_path=CONFIG_PATH)


def main():
    jrnl_name = None
    jrnl_path = None
    if len(sys.argv) == 2:
        jrnl_path = sys.argv[1]
    elif len(sys.argv) > 2:
        jrnl_name = sys.argv[1]
        jrnl_path = sys.argv[2]
    try:
        jrnl_name = jrnl_name or os.environ['PROJECT_NAME']
        jrnl_path = jrnl_path or os.environ['PROJECT_HOME']
    except KeyError:
        print "Couldn't add a new journal; PROJECT_NAME or PROJECT_PATH missing"
    else:
        config = _read_config()
        _add_new_jrnl(config, jrnl_name, jrnl_path)
        _save_config(config)


if __name__ == '__main__':
    main()
