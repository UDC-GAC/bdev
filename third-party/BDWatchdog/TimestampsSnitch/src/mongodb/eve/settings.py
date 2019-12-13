# Copyright (c) 2019 Universidade da Coruña
# Authors:
#     - Jonatan Enes [main](jonatan.enes@udc.es, jonatan.enes.alvarez@gmail.com)
#     - Roberto R. Expósito
#     - Juan Touriño
#
# This file is part of the BDWatchdog framework, from
# now on referred to as BDWatchdog.
#
# BDWatchdog is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 3
# of the License, or (at your option) any later version.
#
# BDWatchdog is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with BDWatchdog. If not, see <http://www.gnu.org/licenses/>.


experiments_schema = {
    # Schema definition, based on Cerberus grammar. Check the Cerberus project
    # (https://github.com/pyeve/cerberus) for details.
    'experiment_id': {
        'type': 'string',
        'minlength': 1,
        'required': True,
    },
    'username': {
        'type': 'string',
        'minlength': 1,
        'required': True,
    },
    'start_time': {
        'type': 'integer',
        'min': 1,
    },
    'end_time': {
        'type': 'integer',
        'min': 1,
    },
}

tests_schema = {
    # Schema definition, based on Cerberus grammar. Check the Cerberus project
    # (https://github.com/pyeve/cerberus) for details.
    'experiment_id': {
        'type': 'string',
        'minlength': 1,
        'required': True,
    },
    'username': {
        'type': 'string',
        'minlength': 1,
        'required': True,
    },
    'start_time': {
        'type': 'integer',
        'min': 1,
    },
    'end_time': {
        'type': 'integer',
        'min': 1,
    },
    'tags': {
        'type': 'list',
        'min': 0,
    },
    'test_name': {
         'type': 'string',
          'minlength': 1,
         'required': True,
    },
    'test_id': {
         'type': 'string',
          'minlength': 1,
         'required': True,
     },
}

experiments = {
    # 'title' tag used in item links. Defaults to the resource title minus
    # the final, plural 's' (works fine in most cases but not for 'people')
    'item_title': 'experiment',

    'additional_lookup': {
        'url': 'regex("[0-9-]+:\w+")',
        'field': 'experiment_id'
    },

    # We choose to override global cache-control directives for this resource.
    'cache_control': 'max-age=10,must-revalidate',
    'cache_expires': 10,

    # most global settings can be overridden at resource level
    'resource_methods': ['GET', 'POST', 'DELETE'],

    'schema': experiments_schema
}

tests = {
    # 'title' tag used in item links. Defaults to the resource title minus
    # the final, plural 's' (works fine in most cases but not for 'people')
    'item_title': 'test',

    'additional_lookup': {
	'url': 'regex("[0-9-]+:\w+")',
       # 'url': 'regex("[\w_0-9]+")',
        'field': 'test_id'
    },

    # We choose to override global cache-control directives for this resource.
    'cache_control': 'max-age=10,must-revalidate',
    'cache_expires': 10,

    # most global settings can be overridden at resource level
    'resource_methods': ['GET', 'POST', 'DELETE'],


    'schema': tests_schema
}


DOMAIN = {'experiments': experiments, 'tests': tests}

# Let's just use the local mongod instance. Edit as needed.

# Please note that MONGO_HOST and MONGO_PORT could very well be left
# out as they already default to a bare bones local 'mongod' instance.
MONGO_HOST = "0.0.0.0"
MONGO_PORT = 27017

# Skip these if your db has no auth. But it really should.
#MONGO_USERNAME = '<your username>'
#MONGO_PASSWORD = '<your password>'

MONGO_DBNAME = 'timestamping'
# Enable reads (GET), inserts (POST) and DELETE for resources/collections
# (if you omit this line, the API will default to ['GET'] and provide
# read-only access to the endpoint).
RESOURCE_METHODS = ['GET', 'POST', 'DELETE']

# Enable reads (GET), edits (PATCH), replacements (PUT) and deletes of
# individual items  (defaults to read-only item access).
ITEM_METHODS = ['GET', 'PATCH', 'PUT', 'DELETE']

X_DOMAINS = ['*']
X_HEADERS = ['Content-Type','If-Match']