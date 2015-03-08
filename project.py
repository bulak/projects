#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Created on  Tue Jan 21 12:39:09 2015
@author: barpat
"""
from __future__ import (absolute_import, division,
                        print_function, unicode_literals)
from builtins import *

import sys
import os
import argparse
import configparser
import logging

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

DEF_PROJECT_HOME = os.path.expanduser('~/.project')
DEF_DB_FILE = 'project.db'
DEF_CONFIG_FILE = 'project.conf'
DEF_LOGGING_FILE = 'project.log'

cur_project_home = os.environ.get('PROJECT_HOME', DEF_PROJECT_HOME)
if not os.path.exists(cur_project_home):
    raise projectError('Could not resolve home directory')

# init logging
cur_log_file = os.path.join(cur_project_home, DEF_LOGGING_FILE)
logging.basicConfig(filename=cur_log_file, level=logging.DEBUG)

# configuration
main_config = configparser.ConfigParser()
try:
    with open(os.path.join(cur_project_home, DEF_CONFIG_FILE), 'r') as main_config_file:
        main_config.read_file(main_config_file)
except FileNotFoundError:
    raise ProjectConfigError('Could not find main configuration file')

print(main_config.sections())
print(main_config['bitbucket.org']['Compression'])
arg_parser = argparse.ArgumentParser(description="manages 'projects' via CLI", prog="project")
arg_parser.add_argument("command", choices=['create', 'activate', 'list', 'log'])
args = arg_parser.parse_args()


if args.command == 'create':
    pass
