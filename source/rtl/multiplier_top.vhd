-------------------------------------------------------------------------------
-- Title      : multiplier top level
-- Project    : 
-------------------------------------------------------------------------------
-- File       : multiplier_top.vhd
-- Author     : amr  <amr@amr-laptop>
-- Company    : 
-- Created    : 2014-06-20
-- Last update: 2014-06-25
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
  generic (
    -- enable/disable pipelining
    en_pipe : boolean := true;
    -- number of pipeline stages - minimum = 2
    stages  : integer := 3
    );
  port (
    rstn         : in  std_logic;
    clk          : in  std_logic;
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

  component cpa
    generic (
      width : integer);
    port (
      opa    : in  std_logic_vector(width-1 downto 0);
      opb    : in  std_logic_vector(width-1 downto 0);
      result : out std_logic_vector(width-1 downto 0));
  end component;


  signal adder_in1 : std_logic_vector(63 downto 0);
  signal adder_in2 : std_logic_vector(63 downto 0);

  -----------------------------------------------------------------
  -- IO Registers
  -----------------------------------------------------------------
  signal multiplier_reg_s   : std_logic_vector(31 downto 0);
  signal multiplicand_reg_s : std_logic_vector(31 downto 0);
  signal result_reg_s       : std_logic_vector(63 downto 0);
  -----------------------------------------------------------------
  -- Optional Pipelining Registers
  -----------------------------------------------------------------
  type   pipe_t is array (0 to stages-2) of std_logic_vector(31 downto 0);
  signal multiplier_pipe    : pipe_t;
  signal multiplicand_pipe  : pipe_t;


  signal multiplier_s, multiplicand_s : std_logic_vector(31 downto 0);
  signal result_s                     : std_logic_vector(63 downto 0);
  
begin  -- struct



  pipe_false : if (en_pipe = false) generate
    multiplicand_s <= multiplicand;
    multiplier_s   <= multiplier;
    result         <= result_s;
  end generate pipe_false;

  pipe_true : if (en_pipe = true) generate

    clk_pr : process(clk, rstn)
    begin
      if (rstn = '0') then
        multiplier_reg_s   <= (others => '0');
        multiplicand_reg_s <= (others => '0');
        result_reg_s       <= (others => '0');
      elsif (rising_edge(clk)) then
        multiplier_reg_s   <= multiplier;
        multiplicand_reg_s <= multiplicand;
        result_reg_s       <= result_s;
      end if;
    end process clk_pr;

    multiplicand_s <= multiplicand_reg_s;
    multiplier_s   <= multiplier_reg_s;
    result         <= result_reg_s;
  end generate pipe_true;


  pp_gen_rdcn_1 : pp_gen_rdcn
    port map (
      multiplicand => multiplicand_s,
      multiplier   => multiplier_s,
      addin_1      => adder_in1,
      addin_2      => adder_in2);

  cpa_1 : cpa
    generic map (
      width => 64)
    port map (
      opa    => adder_in1,
      opb    => adder_in2,
      result => result_s);



  --result_s <= std_logic_vector(unsigned(adder_in1) + unsigned(adder_in2));

end struct;
