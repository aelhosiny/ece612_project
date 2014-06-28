-------------------------------------------------------------------------------
-- Title      : kogge stone gray cell
-- Project    : 
-------------------------------------------------------------------------------
-- File       : gray_cell.vhd
-- Author     : amr  <amr@amr-laptop>
-- Company    : 
-- Created    : 2014-06-24
-- Last update: 26-06-2014
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-06-24  1.0      amr   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dot_operator is
  port(
    g0 : in  std_logic;
    g1 : in  std_logic;
    p0 : in  std_logic;
    p1 : in  std_logic;
    g2 : out std_logic;
    p2 : out std_logic);
end dot_operator;


architecture behav of dot_operator is

begin  -- behav

  g2 <= g1 or (g0 and p1);
  p2 <= p0 and p1;

end behav;
