-------------------------------------------------------------------------------
-- Test suite for Shake
--
-- Authors: Andre Carregal
-- Copyright (c) 2007 Kepler Project
--
-- $Id: test_multiple_ok.lua,v 1.2 2008/07/16 18:32:10 carregal Exp $
-------------------------------------------------------------------------------

-- Testing the use of multiple files for tests

local func, msg

func, msg = loadfile("test1_ok.lua")
print("first ok?")
assert(func)
func()

func, msg = loadfile("test2_ok.lua")
print("second ok?")
assert(func)
func()
