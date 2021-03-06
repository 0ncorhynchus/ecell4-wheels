#!/usr/bin/env bash

cd ecell4/python/dist

readonly pattern='\(libicu[a-z0-9]*\.[0-9]*\)\.\([0-9]*\)\.dylib'

readonly wheel=$(ls *.whl)
unzip $wheel

echo "Fixing ..."
for dylib in $(ls ecell4/.dylibs/libicu*.dylib); do
    change_option=$(basename "$dylib" | grep -e "$pattern" | sed -e "s:^${pattern}$:@loader_path/\1.dylib @loader_path/\1.\2.dylib:g")
    echo "change_option = $change_option"
    for target in $(ls ecell4/.dylibs/lib*.dylib); do
        test -w "$target" && echo "install_name_tool -change $change_option $target" && install_name_tool -change $change_option $target
    done
done

echo "Checking ..."
for dylib in $(ls ecell4/.dylibs/lib*.dylib); do
  otool -L $dylib
done

rm -rf $wheel
zip -r $wheel $(ls -d ecell*)
