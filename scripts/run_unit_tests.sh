#!/bin/bash

# Runs the unit tests for the project.
# This is meant to be hooked up into .git/hooks/pre-commit

# Example pre-commit hook:
# #!/bin/sh
# #
# # Runs the unit tests for the project.
# ./scripts/run_unit_tests.sh

./addons/gdUnit4/runtest.sh -a test