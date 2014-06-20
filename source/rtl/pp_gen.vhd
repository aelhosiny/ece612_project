-------------------------------------------------------------------------------
-- Title      : partial product generation and compression
-- Project    : 
-------------------------------------------------------------------------------
-- File       : pp_gen.vhd
-- Author     : amr  <amr@amr-laptop>
-- Company    : 
-- Created    : 2014-06-20
-- Last update: 2014-06-20
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Generate and Compress partial products
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-06-20  1.0      amr	Created
-------------------------------------------------------------------------------

entity pp_gen is
  
  port (
    multiplicand : in  std_logic_vector(31 downto 0);
    multiplier   : in  std_logic_vector(31 downto 0);
    adder_in1    : out std_logic_vector(63 downto 0);
    adder_in2    : out std_logic_vector(63 downto 0));

end pp_gen;

architecture behav of pp_gen is

begin  -- behav

  

end behav;
