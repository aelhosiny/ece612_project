-------------------------------------------------------------------------------
-- Title      : three to two compressor
-- Project    : 
-------------------------------------------------------------------------------
-- File       : three2two.vhd
-- Author     : amr  <amr@amr-laptop>
-- Company    : 
-- Created    : 2014-06-20
-- Last update: 2014-06-20
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: carry save adder module - compress a,b,cin to s,cout
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-06-20  1.0      amr   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity three2two is
  
  port (
    a    : in  std_logic;
    b    : in  std_logic;
    cin  : in  std_logic;
    sum  : out std_logic;
    cout : out std_logic);

end three2two;


architecture behav of three2two is


begin  -- behav

  sum  <= a xor b xor cin;
  cout <= (a and b) or (a and cin) or (b and cin);
  

end behav;
