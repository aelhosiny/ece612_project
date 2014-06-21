-------------------------------------------------------------------------------
-- Title      : multiplier top level
-- Project    : 
-------------------------------------------------------------------------------
-- File       : multiplier_top.vhd
-- Author     : amr  <amr@amr-laptop>
-- Company    : 
-- Created    : 2014-06-20
-- Last update: 2014-06-21
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: multiplier top level. Instaniates the pp gen and reduction
--              Introduces the reduced PP's to the final CPA
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

entity multiplier_top is
  
  port (
    multiplicand : in  std_logic_vector(31 downto 0);
    multiplier   : in  std_logic_vector(31 downto 0);
    result       : out std_logic_vector(63 downto 0));

end multiplier_top;


architecture struct of multiplier_top is

  component pp_gen_rdcn
    port (
      multiplicand : in  std_logic_vector(31 downto 0);
      multiplier   : in  std_logic_vector(31 downto 0);
      addin_1      : out std_logic_vector(63 downto 0);
      addin_2      : out std_logic_vector(63 downto 0));
  end component;

  signal adder_in1 : std_logic_vector(63 downto 0);
  signal adder_in2 : std_logic_vector(63 downto 0);
  
begin  -- struct

  pp_gen_rdcn_1 : pp_gen_rdcn
    port map (
      multiplicand => multiplicand,
      multiplier   => multiplier,
      addin_1      => adder_in1,
      addin_2      => adder_in2);

  result <= std_logic_vector(unsigned(adder_in1) + unsigned(adder_in2));

end struct;
