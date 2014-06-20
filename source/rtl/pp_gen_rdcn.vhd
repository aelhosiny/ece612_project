-------------------------------------------------------------------------------
-- Title      : partial product generation and reduction
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
-- 2014-06-20  1.0      amr   Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pp_gen_rdcn is
  
  port (
    multiplicand : in  std_logic_vector(31 downto 0);
    multiplier   : in  std_logic_vector(31 downto 0);
    adder_in1    : out std_logic_vector(63 downto 0);
    adder_in2    : out std_logic_vector(63 downto 0));

end pp_gen_rdcn;

architecture behav of pp_gen_rdcn is

  component sdn_gen
    port (
      mult_bits : in  std_logic_vector(2 downto 0);
      sdn_out   : out std_logic_vector(2 downto 0));
  end component;

  constant ppn_c : integer := 17;

  type   sdn_t is array (0 to ppn_c-1) of std_logic_vector(2 downto 0);
  signal sdn_s                          : sdn_t;
  signal multiplicand_s                 : std_logic_vector(32 downto 0);
  signal multiplier_s                   : std_logic_vector(34 downto 0);
  signal pp_2y, pp_y, pp_negy, pp_neg2y : std_logic_vector(32 downto 0);
  type   pp_t is array (0 to ppn_c-1) of std_logic_vector(32 downto 0);
  signal pp_intrm_s                     : pp_t;
  type   pp_all_t is array (0 to ppn_c-1) of std_logic_vector(63 downto 0);
  signal pp_all_s                       : pp_all_t;
  signal sign_vec_s                     : std_logic_vector(ppn_c-1 downto 0);
  
begin  -- behav

  -- extend multiplier by extra lsb for booth encoding  
  multiplier_s   <= "00" & multiplier & '0';
  -- extend multiplicand by extra msb to allow shift
  multiplicand_s <= '0' & multiplicand;

  -- Generate sdn for each three bits of the multiplicand
  sdngen : for i in 0 to ppn_c-1 generate
    sdn_gen_inst : sdn_gen
      port map (
        mult_bits => multiplier_s(2*i+2 downto 2*i),
        sdn_out   => sdn_s(i));
  end generate sdngen;


  -- generate Y, 2Y, -Y, -2Y
  pp_y     <= multiplicand_s;
  pp_2y    <= multiplicand_s(multiplicand_s'length-2 downto 0) & '0';
  pp_negy  <= not(pp_y);
  pp_neg2y <= not(pp_2y);

  -----------------------------------------------------------------------------
  -- generate all PP's - Without sign extension yet
  -- Select PP value between 0, Y, 
  -----------------------------------------------------------------------------
  -- generate all PP's - Without sign extension yet
  pp_gen_all : for i in 0 to ppn_c-1 generate
    with sdn_s(i) select
      pp_intrm_s(i) <=
      (others => '0') when 000,
      (others => '0') when 001,
      pp_2y           when 010,
      pp_neg2y        when 011,
      pp_y            when 100,
      pp_negy         when 101,
      (others => 'X') when others;
    with sdn_s(i) select
      sign_vec_s(i) <=
      '1' when 011,
      '1' when 101,
      '0' when 100,
      '0' when 010,
      'X' when others;
  end generate pp_gen_all;

  -----------------------------------------------------------------------------
  -- Mapp partial products to their respective position in array
  -- Add sign extension and to left and right
  -----------------------------------------------------------------------------

  -- sign extension
  pp_signed_gen : for i in 0 to ppn_c-1 generate
    
    pp0_gen : if i = 0 generate
      pp_all_s(i)(35 downto 0) <= not(sign_vec_s(i)) & sign_vec_s(i) & sign_vec_s(i) & pp_intrm_s(i);
    end generate pp0_gen;

    pp1_14_gen : if (i > 0 and i < 15) generate
      pp_all_s(i)(2*i-2)             <= sign_vec_s(i-1);
      pp_all_s(i)(2*i+34 downto 2*i) <= '1' & not(sign_vec_s(i)) & pp_all_s(i);
    end generate pp1_14_gen;
    
    pp15_gen : if (i = 15) generate
      pp_all_s(i)(2*i-2)             <= sign_vec_s(i-1);
      pp_all_s(i)(2*i+33 downto 2*i) <= not(sign_vec_s(i)) & pp_all_s(i);
    end generate pp1_14_gen;
    
    pp16_gen : if (i = 16) generate
      pp_all_s(i)(2*i-2)             <= sign_vec_s(i-1);
      pp_all_s(i)(2*i+32 downto 2*i) <= pp_all_s(i);
    end generate pp1_14_gen;
  end generate pp_signed_gen;

  -----------------------------------------------------------------------------
  -- Begin Partial Product Reduction Phase
  -----------------------------------------------------------------------------
-------------------------------------------------------------------------------
  
end behav;
