#!/bin/bash
#
# Copyright (C) 2011 Colin Walters <walters@verbum.org>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA.

set -euo pipefail

. $(dirname $0)/libtest.sh

echo "1..3"

setup_repo
install_repo
setup_sdk_repo
install_sdk_repo

cp -a $(dirname $0)/configure.test .
echo "version1" > app-data
xdg-app-builder --repo=repo --force-clean appdir $(dirname $0)/test.json

assert_file_has_content appdir/files/share/app-data version1
assert_file_has_content appdir/metadata shared=network;
assert_file_has_content appdir/metadata tags=test;

assert_not_has_file appdir/files/cleanup/a_filee
assert_not_has_file appdir/files/bin/file.cleanup

assert_has_file appdir/files/cleaned_up > out

${XDG_APP} build appdir /app/bin/hello2.sh > hello_out2
assert_file_has_content hello_out2 '^Hello world2, from a sandbox$'

echo "ok build"

${XDG_APP} --user install test-repo org.test.Hello2 master
run org.test.Hello2 > hello_out3
assert_file_has_content hello_out3 '^Hello world2, from a sandbox$'

run --command=cat org.test.Hello2 /app/share/app-data > app_data_1
assert_file_has_content app_data_1 version1

echo "ok install+run"

echo "version2" > app-data
xdg-app-builder --repo=repo --force-clean appdir $(dirname $0)/test.json
assert_file_has_content appdir/files/share/app-data version2

${XDG_APP} --user update org.test.Hello2 master

run --command=cat org.test.Hello2 /app/share/app-data > app_data_2
assert_file_has_content app_data_2 version2

echo "ok update"