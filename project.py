#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Created on  Tue Jan 21 12:39:09 2015
@author: barpat
"""

import sys
import os
import argparse
import kaptan
import logging
import json

class ProjectException(Exception):
    """
    Base Exception for Project Errors.
    """

class ProjectConfigError(ProjectException):
    """
    Project configuration failed.
    """
    def __init__(self, m):
        self.message = m

    def __str__(self):
        return self.message

DEF_PROJECT_HOME = os.path.expanduser("~/.project")
DEF_DB_FILE = "project.db"
DEF_DATA = '{"projects": ["foo", {"bar":["baz", null, 1.0, 2]}]'
DEF_LOGGING_FILE = "project.log"
DEF_CONFIG_FILE = "project.conf"
DEF_CONFIG_TYPE = "yaml"
DEF_CONFIG = """
product:
  price:
    value: 12.65
    currency_list:
      - TL
      - EURO
"""

app_home = os.environ.get("PROJECT_HOME", DEF_PROJECT_HOME)
if not os.path.exists(app_home):
    raise ProjectConfigError("Could not resolve home directory")

# init logging
app_log_file = os.path.join(app_home, DEF_LOGGING_FILE)
logging.basicConfig(filename=app_log_file, level=logging.DEBUG)

# configuration
app_config = kaptan.Kaptan(handler=DEF_CONFIG_TYPE)
app_config_file = os.path.join(app_home, DEF_CONFIG_FILE)
if not os.path.exists(app_config_file):
    app_config.import_config(DEF_CONFIG)
    with open(app_config_file, "w") as app_config_handler:
        app_config_handler.write(app_config.export(DEF_CONFIG_TYPE))
else:
    app_config.import_config(app_config_file)

# sync database
app_db = os.path.join(app_home, DEF_DB_FILE)
try:
    with open(app_db) as app_db_handler:
        app_data = json.load(app_db_handler)
arg_parser = argparse.ArgumentParser(description="manages 'projects' via CLI", prog="project")
arg_parser.add_argument("command", choices=["create", "activate", "list", "log"])
arg_parser.add_argument("project", nargs="?")
args = arg_parser.parse_args()


if args.command == "create":
    pass
