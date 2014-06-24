-------------------------------------------------------------------------------
-- Title      : basic functions
-- Project    : 
-------------------------------------------------------------------------------
-- File       : basic_functions.vhd
-- Author     : amr  <amr@amr-laptop>
-- Company    : 
-- Created    : 2014-06-24
-- Last update: 2014-06-24
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-06-24  1.0      amr	Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- Package Declaration ----------------------------------
package basic_functions is

  function log2 (inlength : integer) return integer;
  function and_reduce (x  : std_logic_vector) return std_logic;
  function or_reduce (x   : std_logic_vector) return std_logic;
  
end;

package body basic_functions is
  -----------------------------------------------------------------------------
  --log2 function
  -----------------------------------------------------------------------------
  function log2 (inlength : integer) return integer is
    variable i : integer := 1;
  begin
    while 2**i < inlength loop
      i := i+1;
    end loop;  -- i
    return i;
  end function log2;
  --------------------------------------------------------------------
  -- OR Reduce Function.
  --------------------------------------------------------------------
  function or_reduce (x : std_logic_vector) return std_logic is
    variable tmp : std_logic := '0';
  begin
    for ii in x'range loop
      tmp := tmp or x(ii);
    end loop;
    return tmp;
  end function;
  --------------------------------------------------------------------
  -- AND Reduce Function.
  --------------------------------------------------------------------
  function and_reduce (x : std_logic_vector) return std_logic is
    variable tmp : std_logic := '1';
  begin
    for ii in x'range loop
      tmp := tmp and x(ii);
    end loop;
    return tmp;
  end function;

  
end package body basic_functions;
