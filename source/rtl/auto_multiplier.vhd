-------------------------------------------------------------------------------
-- Title      : multiplier implemented by the tool
-- Project    : 
-------------------------------------------------------------------------------
-- File       : multiplier_top.vhd
-- Author     : amr  <amr@amr-laptop>
-- Company    : 
-- Created    : 2014-06-20
-- Last update: 30-06-2014
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Default multiplier implemented by synthesis tool
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

entity auto_multiplier is
  generic (
    -- enable/disable pipelining
    en_pipe : boolean := false;
    -- number of pipeline stages - minimum = 2
    stages  : integer := 3
    );
  port (
    rstn         : in  std_logic;
    clk          : in  std_logic;
    multiplicand : in  std_logic_vector(31 downto 0);
    multiplier   : in  std_logic_vector(31 downto 0);
    result       : out std_logic_vector(63 downto 0));

end auto_multiplier;


architecture struct of auto_multiplier is

  -----------------------------------------------------------------
  -- IO Registers
  -----------------------------------------------------------------
  signal multiplier_reg_s   : std_logic_vector(31 downto 0);
  signal multiplicand_reg_s : std_logic_vector(31 downto 0);
  signal result_reg_s       : std_logic_vector(63 downto 0);
  -----------------------------------------------------------------
  -- Optional Pipelining Registers
  -----------------------------------------------------------------
  type pipe_t is array (0 to stages-2) of std_logic_vector(31 downto 0);
  signal multiplier_pipe    : pipe_t;
  signal multiplicand_pipe  : pipe_t;


  signal multiplier_s, multiplicand_s : std_logic_vector(31 downto 0);
  signal result_s                     : std_logic_vector(63 downto 0);
  
begin  -- struct


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

  pipe_false : if (en_pipe = false) generate
    multiplicand_s <= multiplicand_reg_s;
    multiplier_s   <= multiplier_reg_s;
    result_reg_s   <= result_s;
  end generate pipe_false;


  result   <= result_reg_s;
  result_s <= std_logic_vector(unsigned(multiplier_s) * unsigned(multiplicand_s));

end struct;
