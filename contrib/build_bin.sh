#! /bin/bash
# Script for building standalone binary releases deterministically

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
pip install -U pip
pip install poetry

# Setup poetry and install the dependencies
poetry install

# We now need to remove debugging symbols and build id from the hidapi SO file
so_dir=`dirname $(dirname $(poetry run which python))`/lib/python3.6/site-packages
find ${so_dir} -name '*.so' -type f -execdir strip '{}' \;
if [[ $OSTYPE != *"darwin"* ]]; then
    find ${so_dir} -name '*.so' -type f -execdir strip -R .note.gnu.build-id '{}' \;
fi

# We also need to change the timestamps of all of the base library files
lib_dir=`pyenv root`/versions/3.6.8/lib/python3.6
TZ=UTC find ${lib_dir} -name '*.py' -type f -execdir touch -t "201901010000.00" '{}' \;

# Make the standalone binary
export PYTHONHASHSEED=42
poetry run pyinstaller hwi.spec
unset PYTHONHASHSEED
