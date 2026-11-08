# The Fuck settings file
#
# The rules are defined as in the example bellow:
#
# rules = ['cd_parent', 'git_push', 'python_command', 'sudo']
#
# The default values are as follows. Uncomment and change to fit your needs.
# See https://github.com/nvbn/thefuck#settings for more information.
#

# rules = [<const: All rules enabled>]
# exclude_rules = []
# wait_command = 3
# require_confirmation = True
# no_colors = False
# debug = False
# priority = {}
# history_limit = None
# alter_history = True
# wait_slow_command = 15
# slow_commands = ['lein', 'react-native', 'gradle', './gradlew', 'vagrant']
# repeat = False
# instant_mode = False
# num_close_matches = 3
# env = {'LC_ALL': 'C', 'LANG': 'C', 'GIT_TRACE': '1'}
# excluded_search_path_prefixes = []

# fix_file reads "/bin/sh: line 1: …" in error messages as "file:line" and offers
# to open /bin/sh in the editor instead of fixing the typo. Disabled.
exclude_rules = ['fix_file']
require_confirmation = True
