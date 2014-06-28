-------------------------------------------------------------------------------
-- Title      : partial product reduction tree
-- Project    : 
-------------------------------------------------------------------------------
-- File       : pp_rdcn.vhd
-- Author     : amr  <amr@amr-laptop>
-- Company    : 
-- Created    : 2014-06-20
-- Last update: 2014-06-28
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

  type   pp_all_t is array (0 to 16) of std_logic_vector(63 downto 0);
  signal pp_all_s                 : pp_all_t;  -- := (others => (others => '0'));
  signal pp_all_init              : pp_all_t;
  type   stage1_out_t is array (0 to 4) of std_logic_vector(64 downto 0);
  signal stage1_sum, stage1_carry : stage1_out_t;
  type   stage1_fix_t is array (0 to 11) of std_logic_vector(63 downto 0);
  signal stage1_fix               : stage1_fix_t;
  type   stage2_out_t is array (0 to 3) of std_logic_vector(64 downto 0);
  signal stage2_sum, stage2_carry : stage2_out_t;
  type   stage2_fix_t is array (0 to 7) of std_logic_vector(63 downto 0);
  signal stage2_fix               : stage2_fix_t;
  type   stage3_out_t is array (0 to 1) of std_logic_vector(64 downto 0);
  signal stage3_sum, stage3_carry : stage3_out_t;
  type   stage3_fix_t is array (0 to 5) of std_logic_vector(63 downto 0);
  signal stage3_fix               : stage3_fix_t;
  type   stage4_out_t is array (0 to 1) of std_logic_vector(64 downto 0);
  signal stage4_sum, stage4_carry : stage4_out_t;
  type   stage4_fix_t is array (0 to 3) of std_logic_vector(63 downto 0);
  signal stage4_fix               : stage4_fix_t;
  signal stage5_sum, stage5_carry : std_logic_vector(64 downto 0);
  type   stage5_fix_t is array (0 to 2) of std_logic_vector(63 downto 0);
  signal stage5_fix               : stage5_fix_t;
  signal stage6_sum, stage6_carry : std_logic_vector(64 downto 0);
  type   stage6_fix_t is array (0 to 1) of std_logic_vector(63 downto 0);
  signal stage6_fix               : stage6_fix_t;

  signal result_test : std_logic_vector(63 downto 0);
  -----------------------------------------------------------------------------
  component three2two
    port (
      a    : in  std_logic;
      b    : in  std_logic;
      cin  : in  std_logic;
      sum  : out std_logic;
      cout : out std_logic);
  end component;
  -----------------------------------------------------------------------------  
  
begin  -- behav


  -----------------------------------------------------------------------------
  -- Begin Partial Product reduction
  -- First we need to initialize all empty places in the PP array with zeros
  -- Then the array will be introduced to compression modules.
  -- The places initialized to zeros will be automatically optimized by tool
  -- Each three rows of the array will be introduced to compression modules
  -- resulting into a sum vector and a carry vector
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Assign input PP's to the array
  -----------------------------------------------------------------------------
  wallace_tree : process(pp1, pp10, pp11, pp12, pp13, pp14, pp15, pp16, pp17,
                         pp2, pp3, pp4, pp5, pp6, pp7, pp8, pp9)
    variable pp_all_v : pp_all_t;
  begin
    pp_all_v                 := (others => (others => '0'));
    pp_all_v(0)(63 downto 0) := pp16(63) & pp15(62 downto 61) & pp14(60 downto 59) & pp13(58 downto 57) &
                                pp12(56 downto 55) & pp11(54 downto 53) & pp10(52 downto 51) & pp9(50 downto 49) &
                                pp8(48 downto 47) & pp7(46 downto 45) & pp6(44 downto 43) & pp5(42 downto 41) &
                                pp4(40 downto 39) & pp3(38 downto 37) & pp2(36) & pp1(35 downto 2) & '0' & pp1(0);
    
    pp_all_v(1)(63 downto 0) := pp17(63) & pp16(62 downto 61) & pp15(60 downto 59) & pp14(58 downto 57) & pp13(56 downto 55) &
                                pp12(54 downto 53) & pp11(52 downto 51) & pp10(50 downto 49) & pp9(48 downto 47) &
                                pp8(46 downto 45) & pp7(44 downto 43) & pp6(42 downto 41) & pp5(40 downto 39) & pp4(38 downto 37) &
                                pp3(36) & pp2(35 downto 2) & '0' & pp2(0);
    
    pp_all_v(2)(62 downto 2) := pp17(62 downto 61) & pp16(60 downto 59) & pp15(58 downto 57) & pp14(56 downto 55) &
                                pp13(54 downto 53) & pp12(52 downto 51) & pp11(50 downto 49) & pp10(48 downto 47) &
                                pp9(46 downto 45) & pp8(44 downto 43) & pp7(42 downto 41) & pp6(40 downto 39) &
                                pp5(38 downto 37) & pp4(36) & pp3(35 downto 4) & '0' & pp3(2);
    
    pp_all_v(3)(60 downto 4) := pp17(60 downto 59) & pp16(58 downto 57) & pp15(56 downto 55) & pp14(54 downto 53) &
                                pp13(52 downto 51) & pp12(50 downto 49) & pp11(48 downto 47) & pp10(46 downto 45) &
                                pp9(44 downto 43) & pp8(42 downto 41) & pp7(40 downto 39) & pp6(38 downto 37) & pp5(36) &
                                pp4(35 downto 6) & '0' & pp4(4);
    
    pp_all_v(4)(58 downto 6) := pp17(58 downto 57) & pp16(56 downto 55) & pp15(54 downto 53) & pp14(52 downto 51) &
                                pp13(50 downto 49) & pp12(48 downto 47) & pp11(46 downto 45) & pp10(44 downto 43) &
                                pp9(42 downto 41) & pp8(40 downto 39) & pp7(38 downto 37) & pp6(36) & pp5(35 downto 8) & '0' & pp5(6);
    
    pp_all_v(5)(56 downto 8) := pp17(56 downto 55) & pp16(54 downto 53) & pp15(52 downto 51) & pp14(50 downto 49) &
                                pp13(48 downto 47) & pp12(46 downto 45) & pp11(44 downto 43) & pp10(42 downto 41) &
                                pp9(40 downto 39) & pp8(38 downto 37) & pp7(36) & pp6(35 downto 10) & '0' & pp6(8);
    
    pp_all_v(6)(54 downto 10) := pp17(54 downto 53) & pp16(52 downto 51) & pp15(50 downto 49) & pp14(48 downto 47) &
                                 pp13(46 downto 45) & pp12(44 downto 43) & pp11(42 downto 41) & pp10(40 downto 39) &
                                 pp9(38 downto 37) & pp8(36) & pp7(35 downto 12) & '0' & pp7(10);
    
    pp_all_v(7)(52 downto 12) := pp17(52 downto 51) & pp16(50 downto 49) & pp15(48 downto 47) & pp14(46 downto 45) &
                                 pp13(44 downto 43) & pp12(42 downto 41) & pp11(40 downto 39) & pp10(38 downto 37) &
                                 pp9(36) & pp8(35 downto 14) & '0' & pp8(12);
    
    pp_all_v(8)(50 downto 14) := pp17(50 downto 49) & pp16(48 downto 47) & pp15(46 downto 45) & pp14(44 downto 43) &
                                 pp13(42 downto 41) & pp12(40 downto 39) & pp11(38 downto 37) & pp10(36) & pp9(35 downto 16) & '0' & pp9(14);
    
    pp_all_v(9)(48 downto 16) := pp17(48 downto 47) & pp16(46 downto 45) & pp15(44 downto 43) & pp14(42 downto 41) &
                                 pp13(40 downto 39) & pp12(38 downto 37) & pp11(36) & pp10(35 downto 18) & '0' & pp10(16);
    
    pp_all_v(10)(46 downto 18) := pp17(46 downto 45) & pp16(44 downto 43) & pp15(42 downto 41) & pp14(40 downto 39) &
                                  pp13(38 downto 37) & pp12(36) & pp11(35 downto 20) & '0' & pp11(18);
    
    pp_all_v(11)(44 downto 20) := pp17(44 downto 43) & pp16(42 downto 41) & pp15(40 downto 39) & pp14(38 downto 37) &
                                  pp13(36) & pp12(35 downto 22) & '0' & pp12(20);
    
    pp_all_v(12)(42 downto 22) := pp17(42 downto 41) & pp16(40 downto 39) & pp15(38 downto 37) & pp14(36) &
                                  pp13(35 downto 24) & '0' & pp13(22);
    pp_all_v(13)(40 downto 24) := pp17(40 downto 39) & pp16(38 downto 37) & pp15(36) &
                                  pp14(35 downto 26) & '0' & pp14(24);
    
    pp_all_v(14)(38 downto 26) := pp17(38 downto 37) & pp16(36) & pp15(35 downto 28) & '0' & pp15(26);

    pp_all_v(15)(36 downto 28) := pp17(36) & pp16(35 downto 30) & '0' & pp16(28);

    pp_all_v(16)(35 downto 30) := pp17(35 downto 32) & '0' & pp17(30);

    pp_all_s <= pp_all_v;
  end process wallace_tree;

  -----------------------------------------------------------------------------
  -- Intialize all array by zero then assign occupied values to overwrite zeros
  -----------------------------------------------------------------------------
  --zero_init : process(pp_all_s)
  --  variable pp_all_v : pp_all_t;
  --begin
  --  pp_all_v := (others => (others => '0'));
  --  for i in 1 to 14 loop
  --    pp_all_v(i)(2*i+34 downto 2*i) := pp_all_s(i)(2*i+34 downto 2*i);
  --    pp_all_v(i)(2*i-2)             := pp_all_s(i)(2*i-2);
  --  end loop;  -- i
  --  pp_all_v(0)(35 downto 0)   := pp_all_s(0)(35 downto 0);
  --  -----------------------------------
  --  pp_all_v(15)(28)           := pp_all_s(15)(28);
  --  pp_all_v(15)(63 downto 30) := pp_all_s(15)(63 downto 30);
  --  -----------------------------------
  --  pp_all_v(16)(30)           := pp_all_s(16)(30);
  --  pp_all_v(16)(63 downto 32) := pp_all_s(16)(63 downto 32);
  --  -----------------------------------
  --  pp_all_init                <= pp_all_v;
  --end process zero_init;
  pp_all_init <= pp_all_s;
  -----------------------------------------------------------------------------
  -- Instantiate compressors - First Stage Compression
  -----------------------------------------------------------------------------
  -- PP's 1, 15, 16
  stg1_o : for k in 0 to 4 generate
    stg1_i : for i in 0 to 63 generate
      three2two_1 : three2two
        port map (
          a    => pp_all_init(3*k)(i),
          b    => pp_all_init(3*k+1)(i),
          cin  => pp_all_init(3*k+2)(i),
          sum  => stage1_sum(k)(i),
          cout => stage1_carry(k)(i+1));
    end generate stg1_i;
    stage1_fix(2*k)   <= stage1_sum(k)(63 downto 0);
    stage1_fix(2*k+1) <= stage1_carry(k)(63 downto 1) & '0';
  end generate stg1_o;
  stage1_fix(10) <= pp_all_init(15);
  stage1_fix(11) <= pp_all_init(16);


  -----------------------------------------------------------------------------
  -- Instantiate compressors - Second Stage Compression
  -----------------------------------------------------------------------------
  stg2_o : for k in 0 to 3 generate
    stg2_i : for i in 0 to 63 generate
      three2two_1 : three2two
        port map (
          a    => stage1_fix(3*k)(i),
          b    => stage1_fix(3*k+1)(i),
          cin  => stage1_fix(3*k+2)(i),
          sum  => stage2_sum(k)(i),
          cout => stage2_carry(k)(i+1));
    end generate stg2_i;
    stage2_fix(2*k)   <= stage2_sum(k)(63 downto 0);
    stage2_fix(2*k+1) <= stage2_carry(k)(63 downto 1) & '0';
  end generate stg2_o;

  -----------------------------------------------------------------------------
  -- Instantiate compressors - Second Stage Compression
  -----------------------------------------------------------------------------
  stg3_o : for k in 0 to 1 generate
    stg3_i : for i in 0 to 63 generate
      three2two_1 : three2two
        port map (
          a    => stage2_fix(3*k)(i),
          b    => stage2_fix(3*k+1)(i),
          cin  => stage2_fix(3*k+2)(i),
          sum  => stage3_sum(k)(i),
          cout => stage3_carry(k)(i+1));
    end generate stg3_i;
    stage3_fix(2*k)   <= stage3_sum(k)(63 downto 0);
    stage3_fix(2*k+1) <= stage3_carry(k)(63 downto 1) & '0';
  end generate stg3_o;
  stage3_fix(4) <= stage2_fix(6);
  stage3_fix(5) <= stage2_fix(7);

  -----------------------------------------------------------------------------
  -- Instantiate compressors - Second Stage Compression
  -----------------------------------------------------------------------------
  stg4_o : for k in 0 to 1 generate
    stg4_i : for i in 0 to 63 generate
      three2two_1 : three2two
        port map (
          a    => stage3_fix(3*k)(i),
          b    => stage3_fix(3*k+1)(i),
          cin  => stage3_fix(3*k+2)(i),
          sum  => stage4_sum(k)(i),
          cout => stage4_carry(k)(i+1));
    end generate stg4_i;
    stage4_fix(2*k)   <= stage4_sum(k)(63 downto 0);
    stage4_fix(2*k+1) <= stage4_carry(k)(63 downto 1) & '0';
  end generate stg4_o;

  -----------------------------------------------------------------------------
  -- Instantiate compressors - Fifth Stage Compression
  -----------------------------------------------------------------------------
  stg5_i : for i in 0 to 63 generate
    three2two_1 : three2two
      port map (
        a    => stage4_fix(0)(i),
        b    => stage4_fix(1)(i),
        cin  => stage4_fix(2)(i),
        sum  => stage5_sum(i),
        cout => stage5_carry(i+1));
  end generate stg5_i;
  stage5_fix(0) <= stage5_sum(63 downto 0);
  stage5_fix(1) <= stage5_carry(63 downto 1) & '0';
  stage5_fix(2) <= stage4_fix(3);

  -----------------------------------------------------------------------------
  -- Instantiate compressors - Fifth Stage Compression
  -----------------------------------------------------------------------------
  stg6_i : for i in 0 to 63 generate
    three2two_1 : three2two
      port map (
        a    => stage5_fix(0)(i),
        b    => stage5_fix(1)(i),
        cin  => stage5_fix(2)(i),
        sum  => stage6_sum(i),
        cout => stage6_carry(i+1));
  end generate stg6_i;
  stage6_fix(0) <= stage6_sum(63 downto 0);
  stage6_fix(1) <= stage6_carry(63 downto 1) & '0';

  addin_1 <= stage6_fix(0);
  addin_2 <= stage6_fix(1);

  --pp1_s <= pp16(63) & pp15(62 downto 61) & pp14(60 downto 59) & pp13(58 downto 57) & pp12(56 downto 55) &
  --         pp11(54 downto 53) & pp10(52 downto 51) & pp9(50 downto 49) & pp8(48 downto 47) & pp7(46 downto 45) &
  --         pp6(44 downto 43) & pp5(42 downto 41) & pp4(40 downto 39) & pp3(38 downto 37) & pp2(36) & pp1(35 downto 0);

  -- pp2 0-35
  -- pp3 2-36
  -- pp4 4-38
  -- pp5 6-40
  -- pp6 8-42
  -- pp7 10-44
  -- pp8 12-46
  -- pp9 14-48
  -- pp10 16-50
  -- pp11 18-52
  -- pp12 20-54
  -- pp13 22-56
  -- pp14 24-58
  -- pp15 26-60
  -- pp16 28-63

  --pp2_s(35 downto 0) <= pp_all_s(1)(35 downto 0);
  --pp2_msbs : for i in 0 to 15 generate
  --  pp2_s(2*i+37 downto 2*i+36) <= pp_all_s(i)(2*i+37 downto 2*i+36);
  --end generate pp2_msbs;


-- pragma synthesis_off
  testres : process(pp_all_init)
    variable result_v : unsigned(63 downto 0) := (others => '0');
  begin
    result_v := (others => '0');
    for i in 0 to 16 loop
      result_v := unsigned(pp_all_init(i)) + result_v;
    end loop;  -- i
    result_test <= std_logic_vector(result_v);
  end process testres;
-- pragma synthesis_on
  
end behav;
