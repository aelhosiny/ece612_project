-------------------------------------------------------------------------------
-- Title      : partial product generation and reduction
-- Project    : 
-------------------------------------------------------------------------------
-- File       : pp_gen.vhd
-- Author     : amr  <amr@amr-laptop>
-- Company    : 
-- Created    : 2014-06-20
-- Last update: 2014-07-01
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
    addin_1      : out std_logic_vector(63 downto 0);
    addin_2      : out std_logic_vector(63 downto 0));

end pp_gen_rdcn;

architecture behav of pp_gen_rdcn is

  -----------------------------------------------------------------------------
  -- Component Declaration
  -----------------------------------------------------------------------------
  
  component sdn_gen
    port (
      mult_bits : in  std_logic_vector(2 downto 0);
      sdn_out   : out std_logic_vector(2 downto 0));
  end component;
  -----------------------------------------------------------------------------
  component pp_rdcn
    port (
      pp1     : in  std_logic_vector(63 downto 0);
      pp2     : in  std_logic_vector(63 downto 0);
      pp3     : in  std_logic_vector(63 downto 0);
      pp4     : in  std_logic_vector(63 downto 0);
      pp5     : in  std_logic_vector(63 downto 0);
      pp6     : in  std_logic_vector(63 downto 0);
      pp7     : in  std_logic_vector(63 downto 0);
      pp8     : in  std_logic_vector(63 downto 0);
      pp9     : in  std_logic_vector(63 downto 0);
      pp10    : in  std_logic_vector(63 downto 0);
      pp11    : in  std_logic_vector(63 downto 0);
      pp12    : in  std_logic_vector(63 downto 0);
      pp13    : in  std_logic_vector(63 downto 0);
      pp14    : in  std_logic_vector(63 downto 0);
      pp15    : in  std_logic_vector(63 downto 0);
      pp16    : in  std_logic_vector(63 downto 0);
      pp17    : in  std_logic_vector(63 downto 0);
      addin_1 : out std_logic_vector(63 downto 0);
      addin_2 : out std_logic_vector(63 downto 0));
  end component;

  constant ppn_c : integer := 17;
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Signals Declaration
  -----------------------------------------------------------------------------

  type   sdn_t is array (0 to ppn_c-1) of std_logic_vector(2 downto 0);
  signal sdn_s                          : sdn_t;
  signal multiplicand_s                 : std_logic_vector(32 downto 0);
  signal multiplier_s                   : std_logic_vector(34 downto 0);
  signal pp_2y, pp_y, pp_negy, pp_neg2y : std_logic_vector(32 downto 0);
  type   pp_t is array (0 to ppn_c-1) of std_logic_vector(32 downto 0);
  signal pp_intrm_s                     : pp_t;
  type   pp_all_t is array (0 to ppn_c-1) of std_logic_vector(63 downto 0);
  signal pp_all_s                       : pp_all_t;  -- := (others => (others => '0'));
  signal sign_vec_s                     : std_logic_vector(ppn_c-1 downto 0);

  signal result_test : unsigned(63 downto 0);
  
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
    pp_intrm_s(i) <= (others => '0') when sdn_s(i) = "000" or sdn_s(i) = "001" else
                     pp_2y    when sdn_s(i) = "010" else
                     pp_neg2y when sdn_s(i) = "011" else
                     pp_y     when sdn_s(i) = "100" else
                     pp_negy  when sdn_s(i) = "101" else
                     (others => '0');
    sign_vec_s(i) <= '1' when sdn_s(i) = "011" or sdn_s(i) = "101" else
                     '0' when sdn_s(i) = "100" or sdn_s(i) = "010" or sdn_s(i) = "001" or sdn_s(i) = "000" else
                     'X';
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
      pp_all_s(i)(2*i+34 downto 2*i) <= '1' & not(sign_vec_s(i)) & pp_intrm_s(i);
    end generate pp1_14_gen;

    pp15_gen : if (i = 15) generate
      pp_all_s(i)(2*i-2)             <= sign_vec_s(i-1);
      pp_all_s(i)(2*i+33 downto 2*i) <= not(sign_vec_s(i)) & pp_intrm_s(i);
    end generate pp15_gen;

    pp16_gen : if (i = 16) generate
      pp_all_s(i)(2*i-2)             <= sign_vec_s(i-1);
      pp_all_s(i)(2*i+31 downto 2*i) <= pp_intrm_s(i)(31 downto 0);
    end generate pp16_gen;
  end generate pp_signed_gen;

  -----------------------------------------------------------------------------
  -- Begin Partial Product Reduction Phase
  -----------------------------------------------------------------------------

  pp_rdcn_1 : pp_rdcn
    port map (
      pp1     => pp_all_s(0),
      pp2     => pp_all_s(1),
      pp3     => pp_all_s(2),
      pp4     => pp_all_s(3),
      pp5     => pp_all_s(4),
      pp6     => pp_all_s(5),
      pp7     => pp_all_s(6),
      pp8     => pp_all_s(7),
      pp9     => pp_all_s(8),
      pp10    => pp_all_s(9),
      pp11    => pp_all_s(10),
      pp12    => pp_all_s(11),
      pp13    => pp_all_s(12),
      pp14    => pp_all_s(13),
      pp15    => pp_all_s(14),
      pp16    => pp_all_s(15),
      pp17    => pp_all_s(16),
      addin_1 => addin_1,
      addin_2 => addin_2);

-------------------------------------------------------------------------------

-- pragma synthesis_off
  testres : process(pp_all_s)
    variable result_v : unsigned(63 downto 0) := (others => '0');
  begin
    result_v := (others => '0');
    for i in 0 to 16 loop
      result_v := unsigned(pp_all_s(i)) + result_v;
    end loop;  -- i
    result_test <= result_v;
  end process testres;
-- pragma synthesis_on
  
end behav;
