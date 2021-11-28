--
--K and S Package File 
--
--Purpose: This package defines supplemental types, subtypes, 
-- constants, and functions 

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package k_and_s_pkg is

  type decoded_instruction_type is (I_LOAD,
                                    I_STORE,
                                    I_MOVE,
                                    I_ADD,
                                    I_SUB,
                                    I_AND,
                                    I_OR,
                                    I_BRANCH,
                                    I_BZERO,
                                    I_BNEG,
                                    I_BNZERO,
                                    I_BNNEG,
                                    I_NOP,
                                    I_HALT);  -- Decoded instruction in decode
  component data_path
  port (
    rst_n               : in  std_logic;
    clk                 : in  std_logic;
    branch              : in  std_logic;
    pc_enable           : in  std_logic;
    ir_enable           : in  std_logic;
    addr_sel            : in  std_logic;
    c_sel               : in  std_logic;
    operation           : in  std_logic_vector (1 downto 0);
    write_reg_enable    : in  std_logic;
    flags_reg_enable    : in  std_logic;
    decoded_instruction : out decoded_instruction_type;
    zero_op             : out std_logic;
    neg_op              : out std_logic;
    unsigned_overflow   : out std_logic;
    signed_overflow     : out std_logic;
    ram_addr            : out std_logic_vector (4 downto 0);
    data_out            : out std_logic_vector (15 downto 0);
    data_in             : in  std_logic_vector (15 downto 0)
  );
  end component;

  component control_unit
  port (
    rst_n               : in  std_logic;
    clk                 : in  std_logic;
    branch              : out std_logic;
    pc_enable           : out std_logic;
    ir_enable           : out std_logic;
    addr_sel            : out std_logic;
    c_sel               : out std_logic;
    operation           : out std_logic_vector (1 downto 0);
    write_reg_enable    : out std_logic;
    flags_reg_enable    : out  std_logic;
    decoded_instruction : in  decoded_instruction_type;
    zero_op             : in  std_logic;
    neg_op              : in  std_logic;
    unsigned_overflow   : in  std_logic;
    signed_overflow     : in  std_logic;
    ram_write_enable    : out std_logic;
    halt                : out std_logic
    );
  end component;

  component k_and_s
  port (
    rst_n        : in  std_logic;
    clk          : in  std_logic;
    halt         : out std_logic;
    addr         : out std_logic_vector (4 downto 0);
    data_in      : in  std_logic_vector (15 downto 0);
    data_out     : out std_logic_vector (15 downto 0);
    write_enable : out std_logic
    );
  end component;

end k_and_s_pkg;

package body k_and_s_pkg is
end k_and_s_pkg;

