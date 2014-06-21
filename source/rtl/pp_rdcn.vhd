-------------------------------------------------------------------------------
-- Title      : partial product reduction tree
-- Project    : 
-------------------------------------------------------------------------------
-- File       : pp_rdcn.vhd
-- Author     : amr  <amr@amr-laptop>
-- Company    : 
-- Created    : 2014-06-20
-- Last update: 2014-06-20
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: partial production reduction using carry save adder tree
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


entity pp_rdcn is
  
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
    addin_2 : out std_logic_vector(63 downto 0)
    );

end pp_rdcn;


architecture behav of pp_rdcn is

begin  -- behav



end behav;
