-- m�dulos b�sicos
local _G = _G
local string = string
local table = table

-- fun��es b�sicas
local pairs = pairs
local print = print
local require = require
local tostring = tostring
local type = type

-- m�dulos importados
local m       = require 'lpeg'
local scanner = require 'shake.scanner'
local parser  = require 'shake.parser'
local grammar = require 'shake.grammar'

-- declara��o de m�dulo
module 'shake'

-- FUN��ES E VALORES AUXILIARES ------------

-- casa com um ou mais caracteres "ignor�veis" (espa�os e coment�rios)
local S = scanner.IGNORE

-- casa com todos os caracteres at� achar delim, ignorando espa�os
local function matchUntil(delim)
  delim = m.P(delim) -- garantindo que delim � um padr�o LPeg

  -- evitando capturar espa�os entre a express�o e delim
  return (1 - (S* delim))^0 
end

-- TOKENS ESPECIAIS ------------------------
-- OBS.:
-- espa�os foram incluidos nos tokens para evitar escrever *S* a toda hora

-- abre par�nteses
local OPEN = S* m.P'('

-- fecha par�nteses
local CLOSE = S* m.P')'

-- v�rgula
local COMMA = S* m.P','

-- capturando o operador especial, que pode ser ~= ou ==
local OP = S* m.C(m.P'~=' + m.P'==')

-- casa e captura uma express�o
local EXP = S* m.C(grammar.apply(parser.rules, 
  m.V'_SimpleExp' * (S* (m.V'BinOp' - (m.V'~=' + m.V'==')) *S* m.V'Exp')^0)) 

-- casa e captura a mensagem
local MSG = S* m.C(matchUntil(CLOSE))

-- casa e captura um coment�rio
local COMMENT = m.C((scanner.COMMENT * m.P'\n'^-1) ^ 1)

-- para facilitar a captura de padr�es opcionais
local EPSILON = m.P'' / function() return nil end

-- PADR�ES ---------------------------------

-- um padr�o que casa com EXP OP EXP ou EXP
local LINE = (EXP * (OP * EXP)^-1) / function (exp1, op, exp2)
  return { exp1 = exp1, op = op, exp2 = exp2 }
end

-- um padr�o que casa com uma chamada a assert no nosso formato
local ASSERT = ((COMMENT + EPSILON) * m.Cp() * m.P'assert' * OPEN * LINE 
             * ((COMMA * MSG) + EPSILON) * CLOSE * m.Cp()) 
             / function (comment, start, line, msg, finish)
              return {
                start = start,
                comment = comment,
                exp = line,
                msg = msg,
                finish = finish
              }
            end

-- um padr�o que acha todas as inst�ncias de ASSERT em um dado programa
local ALL = m.Ct((ASSERT + 1)^0)

-- FUN��ES ---------------------------------

-- pega uma captura de ASSERT e produz a chamada new_assert equivalente
local function buildNewAssert(info)
  local exp1, op, exp2 = info.exp.exp1, info.exp.op, info.exp.exp2
  local comment, msg = info.comment, info.msg
  local newassert = ''
  
  local str1 = scanner.text2string(exp1)
  local str2 = (exp2 == nil) and 'nil' or scanner.text2string(exp2)
  local com = (comment == nil) and 'nil' or scanner.text2string(comment)
  return newassert..'___STIR_assert('..exp1
    ..', '..(op and '"'..op..'"' or 'nil')
    ..', '..(exp2 or 'nil')
    ..', '..(msg or 'nil')
    ..', '..str1
    ..', '..str2
    ..', '..com
    ..')'
end

-- substitui a substring de str de i a j pela new_str
local function sub(str, new_str, i, j)
  i, j = i or 1, j or #str
  
  return str:sub(1, i - 1)..new_str..str:sub(j)
end

-- substitui todos os asserts em input pelos new_asserts equivalentes
function stir(input)
  local asserts = ALL:match(input)
  
  for i = #asserts, 1, -1 do
    local v = asserts[i]
    
    input = sub(input, buildNewAssert(v), v.start, v.finish)
  end
  
  return input
end

-- TESTES ----------------------------------
--[===[
-- s� para imprimir o conte�do de uma lista na tela
local function list2string(t, level)
  level = level or 0
  local indent = string.rep('  ', level)
  
  if type(t) == 'string' then
    return string.format('%q', tostring(t))
    --return scanner.text2string(t)
  elseif type(t) ~= 'table' then
    return tostring(t)
  else
    local str = '{'
    
    for k, v in pairs(t) do
      str = str..'\n'..indent..'  ['..list2string(k)..'] = '
        ..list2string(v, level + 1)
    end
    
    return str..'\n'..indent..'}'
  end
end


-- imprimindo o teste abaixo
local input = [==[
local m = require 'lpeg'

local chunk = assert(loadstring('file.luac'), 'The chunk was not loaded!')

--[=[ testando assert
ser� que funciona?
mesmo com --[[ e --]====] no meio? 
--]=]
assert(  exp ~= 8, 
      'slkklajs')

-- aqui n�o captura o coment�rio, n�o � mesmo?
local c = assert((asjksaklj == alklaksj) + a and 4)
]==]

local output = stir(input)


print('input', input)
print('\noutput', output)
--print(list2string { ALL:match(input) })
--]===]