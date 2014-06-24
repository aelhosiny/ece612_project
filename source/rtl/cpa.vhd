-------------------------------------------------------------------------------
-- Title      : carry propagation adder
-- Project    : 
-------------------------------------------------------------------------------
-- File       : cpa.vhd
-- Author     : amr  <amr@amr-laptop>
-- Company    : 
-- Created    : 2014-06-24
-- Last update: 2014-06-24
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: post CSA tree carry propagation adder
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
use work.basic_functions.all;

entity cpa is
  
  generic (
    width : integer := 64);             -- adder precision

  port (
    opa    : in  std_logic_vector(width-1 downto 0);
    opb    : in  std_logic_vector(width-1 downto 0);
    result : out std_logic_vector(width-1 downto 0));

end cpa;


architecture behav of cpa is

  -----------------------------------------------------------------------------
  -- Signal Declaration
  -----------------------------------------------------------------------------
  signal p_vector_s       : std_logic_vector(width-1 downto 0);
  signal g_vector_s       : std_logic_vector(width-1 downto 0);
  type   pg_t is array (0 to log2(width)) of std_logic_vector(width-1 downto 0);
  signal p_a, g_a         : pg_t;
  signal c_vector_s       : std_logic_vector(width-1 downto 0);

  -----------------------------------------------------------------------------
  -- Component Declaration
  -----------------------------------------------------------------------------
  component dot_operator
    port (
      g0 : in  std_logic;
      g1 : in  std_logic;
      p0 : in  std_logic;
      p1 : in  std_logic;
      g2 : out std_logic;
      p2 : out std_logic);
  end component;


-------------------------------------------------------------------------------
-- Architecture body
-------------------------------------------------------------------------------  
begin  -- behav

  -----------------------------------------------------------------------------
  -- Generate initial PG pairs for each two bits from opa & opb
  -----------------------------------------------------------------------------
  genGP : for i in 0 to width-1 generate
    p_vector_s(i) <= opa(i) xor opb(i);
    g_vector_s(i) <= opa(i) and opb(i);
  end generate genGP;

  p_a(0) <= p_vector_s;
  g_a(0) <= g_vector_s;

  -----------------------------------------------------------------------------
  -- Tree Implementation
  -----------------------------------------------------------------------------
  tree_o : for i in 1 to log2(width) generate
    tree_i : for j in 2**(i-1) to width-1 generate
      dot_operator_1 : dot_operator
        port map (
          g0 => g_a(i-1)(j-(2**(i-1))),
          g1 => g_a(i-1)(j),
          p0 => p_a(i-1)(j-(2**(i-1))),
          p1 => p_a(i-1)(j),
          g2 => g_a(i)(j),
          p2 => p_a(i)(j));
    end generate tree_i;
    c_vector_s(2**i-1 downto 2**(i-1)) <= g_a(i)(2**i-1 downto 2**(i-1));
    g_a(i)((2**(i-1))-1 downto 0)      <= g_a(i-1)((2**(i-1))-1 downto 0);
    p_a(i)((2**(i-1))-1 downto 0)      <= p_a(i-1)((2**(i-1))-1 downto 0);
    last_stage : if i = log2(width) generate
      c_vector_s(width-1 downto 2**i) <= g_a(i)(width-1 downto 2**i);
    end generate last_stage;
  end generate tree_o;

  c_vector_s(0) <= g_a(0)(0);
  -----------------------------------------------------------------------------
  -- Result Selection
  -----------------------------------------------------------------------------
  get_sum : for i in 1 to width-1 generate
    result(i) <= p_vector_s(i) xor c_vector_s(i-1);
  end generate get_sum;
  result(0) <= p_vector_s(0);

  
end behav;
