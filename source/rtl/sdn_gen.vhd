-------------------------------------------------------------------------------
-- Title      : single, doble, negate generation
-- Project    : 
-------------------------------------------------------------------------------
-- File       : sdn_gen.vhd
-- Author     : amr  <amr@amr-laptop>
-- Company    : 
-- Created    : 2014-06-20
-- Last update: 2014-06-20
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: This module generates the single, double and negate signals
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-06-20  1.0      amr   Created
-------------------------------------------------------------------------------

entity sdn_gen is
  
  port (
    mult_bits : in  std_logic_vector(2 downto 0);  -- input three bits of multiplier to calculate sdn for
    sdn_out   : out std_logic_vector(2 downto 0));  -- generated single, double, negate

end sdn_gen;

architecture behav of sdn_gen is

  signal single_s : std_logic;
  signal double_s : std_logic;
  signal negate_s : std_logic;
  
begin  -- behav

  -- single
  single_s <= mult_bits(0) xor mult_bits(1);
  -- double
  double_s <= mult_bits(2) and not(mult_bits(1)) and not(mult_bits(0)) or
              not(mult_bits(2)) and mult_bits(1) and mult_bits(0);
  -- negate
  negate_s <= mult_bits(2);

  -- assign signals to output
  sdn_out <= single_s & double_s & negate_s;
end behav;
