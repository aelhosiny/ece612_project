-------------------------------------------------------------------------------
-- Title      : opb test bench
-- Project    : 
-------------------------------------------------------------------------------
-- File       : cpa_tb.vhd
-- Author     : amr  <amr@amr-laptop>
-- Company    : 
-- Created    : 2014-06-20
-- Last update: 26-06-2014
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Multiplier test bench
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
use IEEE.std_logic_textio.all;
use std.textio.all;


entity cpa_tb is

end entity cpa_tb;


architecture behav of cpa_tb is

  constant width_c : integer := 16;

  -----------------------------------------------------------------------------
  -- Components declarations
  -----------------------------------------------------------------------------
  component cpa is
    generic (
      width : integer);
    port (
      opa    : in  std_logic_vector(width-1 downto 0);
      opb    : in  std_logic_vector(width-1 downto 0);
      result : out std_logic_vector(width-1 downto 0));
  end component cpa;
  -----------------------------------------------------------------------------
  -- Signals declarations
  -----------------------------------------------------------------------------
  signal   opa          : std_logic_vector(width_c-1 downto 0) := (others => '0');
  signal   opb          : std_logic_vector(width_c-1 downto 0) := (others => '0');
  signal   result       : std_logic_vector(width_c-1 downto 0);
  signal   feed_s       : std_logic                            := '0';
  signal   rst_n        : std_logic                            := '0';  -- [in]
  signal   sim_end_s    : std_logic                            := '0';
  signal   result_s     : std_logic_vector(width_c-1 downto 0);
  signal   result_ref_s : std_logic_vector(width_c-1 downto 0);
  -----------------------------------------------------------------------------
  -- Constants declarations
  -----------------------------------------------------------------------------
  constant tclk_c       : time                                 := 10 ns;
  signal   sys_clk      : std_logic                            := '0';
  signal   error_s      : std_logic                            := '0';
  signal   check_acc    : std_logic                            := '0';
  
begin  -- architecture behav

  result_ref_s <= std_logic_vector(unsigned(opa) + unsigned(opb));
  -----------------------------------------------------------------------------
  -- purpose: Generate sys clk
  -- type   : 
  -- inputs : 
  -- outputs:
  -----------------------------------------------------------------------------  
  sys_clk_gen : process
  begin
    while (sim_end_s = '0') loop
      sys_clk <= not(sys_clk);
      wait for tclk_c/2;
    end loop;
    wait;
  end process sys_clk_gen;

  -----------------------------------------------------------------------------
  -- Checker
  -----------------------------------------------------------------------------
  checker : process
    variable check_acc_v : std_logic := '0';
    variable error_v     : std_logic := '0';
  begin
    wait until(rising_edge(feed_s));
    while(feed_s = '1') loop
      wait until(falling_edge(sys_clk));
      error_v := '0';
      if (result_ref_s /= result) then
        error_v := '1';
      end if;
      check_acc_v := check_acc or error_v;
      check_acc   <= check_acc_v;
      error_s     <= error_v;
    end loop;
  end process checker;
  -----------------------------------------------------------------------------
  -- purpose: Write interpolator output to file
  -- type   : 
  -- inputs : 
  -- outputs:
  -----------------------------------------------------------------------------
  write_pr : process(feed_s, sys_clk)
    variable line_o_v    : line;
    variable data_out_v  : integer;
    file result_f        : text open write_mode is "$OUTPATH/result.txt";
    variable outsmp_no_v : integer := 0;
  begin
    if (falling_edge(sys_clk)) and (feed_s = '1') then
      outsmp_no_v := outsmp_no_v + 1;
      hwrite(line_o_v, result);
      writeline(result_f, line_o_v);
    end if;
  end process write_pr;


  -----------------------------------------------------------------------------
  -- purpose: Control reset and enables. Read input samples from file
  -- type   : 
  -- inputs : 
  -- outputs:
  -----------------------------------------------------------------------------
  cntrl_pr : process
    file opb_f        : text is "$INPATH/opb.txt";
    file opa_f        : text is "$INPATH/opa.txt";
    file ref_file_f   : text is "$INPATH/result.txt";
    variable line1    : line;
    variable line2    : line;
    variable line3    : line;
    variable opb_v    : std_logic_vector(width_c-1 downto 0);
    variable opa_v    : std_logic_vector(width_c-1 downto 0);
    variable smpl_no  : integer := 0;
    variable result_v : std_logic_vector(width_c-1 downto 0);
  begin
    wait for 5*tclk_c;
    wait until(falling_edge(sys_clk));
    rst_n  <= '1';
    wait for 5*tclk_c;
    wait until(rising_edge(sys_clk));
    feed_s <= '1';
    while(not endfile(opb_f)) loop
      readline(opa_f, line1);
      read(line1, opa_v);
      readline(opb_f, line2);
      read(line2, opb_v);
      readline(ref_file_f, line3);
      read(line3, result_v);
      opa          <= opa_v;
      opb          <= opb_v;
      --result_ref_s <= result_v;
      wait until(rising_edge(sys_clk));
    end loop;
    feed_s    <= '0';
    wait until(rising_edge(sys_clk));
    rst_n     <= '0';
    sim_end_s <= '1';
    wait;
  end process cntrl_pr;


  -----------------------------------------------------------------------------
  -- Instantiate DUT
  -----------------------------------------------------------------------------
  cpa_1 : cpa
    generic map (
      width => width_c)                 -- [integer]
    port map (
      opa    => opa,      -- [in  std_logic_vector(width_c-1 downto 0)]
      opb    => opb,      -- [in  std_logic_vector(width_c-1 downto 0)]
      result => result);  -- [out std_logic_vector(width_c-1 downto 0)]

end architecture behav;


