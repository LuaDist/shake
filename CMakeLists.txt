# Copyright (C) 2007-2012 LuaDist.
# Submitted by David Manura
# Redistribution and use of this file is allowed according to the terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
# Please note that the package source code is licensed under its own license.

project ( shake NONE )
cmake_minimum_required ( VERSION 2.8 )
include ( cmake/dist.cmake )

install_lua_module ( shake src/shake/shake.lua )
install_lua_module ( shake.stir src/shake/stir.lua )
install_data ( README )
install_data ( src/apps )
install_lua_executable ( shake src/bin/shake )
install_doc ( doc/ )
install_test ( tests/ )

#FIX-paths: add_lua_test ( tests/test.lua )
