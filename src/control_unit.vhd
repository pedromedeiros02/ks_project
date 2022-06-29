----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Joao Leonardo Fragoso
-- 
-- Create Date:    19:08:01 06/26/2012 
-- Design Name:    K and S modeling
-- Module Name:    control_unit - rtl 
-- Description:    RTL Code for K and S control unit
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
--          0.02 - moving to Vivado 2017.3
-- Additional Comments: 
--
----------------------------------------------------------------------------------
--Pedro DAvila Silva Medeiros
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.k_and_s_pkg.all;

entity control_unit is
  port (
    rst_n               : in  std_logic;
    clk                 : in  std_logic;
    branch              : out std_logic;
    pc_enable           : out std_logic;
    ir_enable           : out std_logic;
    write_reg_enable    : out std_logic;
    addr_sel            : out std_logic;
    c_sel               : out std_logic;
    operation           : out std_logic_vector (1 downto 0);
    flags_reg_enable    : out std_logic;
    decoded_instruction : in  decoded_instruction_type;
    zero_op             : in  std_logic;
    neg_op              : in  std_logic;
    unsigned_overflow   : in  std_logic;
    signed_overflow     : in  std_logic;
    ram_write_enable    : out std_logic;
    halt                : out std_logic
    );
end control_unit;

architecture rtl of control_unit is

type STATE is (
GET_INST,
DECODE_INST,
NEXT_INST,
NOP_INST,
HALT_INST,
INST_LOAD,
INST_LOAD_RAM,
INST_STORE,
INST_MOVE,
INST_ARITH,
INST_BRANCH,
INST_BNEG,
INST_BNNEG,
INST_BZERO,
INST_BNZERO,
PC_INC,
PC_INC_R
);



signal current_state : STATE;
signal next_state : STATE;
-- signal added to test environment... remove this
--signal counter : std_logic_vector(7 downto 0);
begin

--process to test environment ... remove this
   -- main: process(clk, rst_n)
   -- begin
   --     if (rst_n = '0') then
   --         counter <= (others => '0');
    --    elsif (clk'event and clk='1') then
    --        counter <= counter + 1;
    --    end if;
   -- end process main;
  --  halt <= '1' when counter = x"5f" else '0';
-- remove until here....

state_change : process (clk)
    begin
    if (clk'event and clk = '1') then
        if (rst_n = '1') then 
            current_state <= next_state;
        else
            current_state <= GET_INST;
        end if;        
    end if;        
    end process;
    
instruction_case : process (current_state)
    begin
    case (current_state) is
        when GET_INST =>
            next_state <= DECODE_INST;
            ir_enable <= '1';
            addr_sel <= '0';
            c_sel <= '0';
            pc_enable <= '0';
            branch <= '0';
            ram_write_enable <= '0';
            flags_reg_enable <= '0';
            write_reg_enable <= '0';
            halt <= '0';
            
        when DECODE_INST =>
            ir_enable <= '0';
            addr_sel <= '0';
            c_sel <= '0';
            pc_enable <= '0';
            branch <= '0';
            ram_write_enable <= '0';
            flags_reg_enable <= '0';
            write_reg_enable <= '0';
            halt <= '0';
            case (decoded_instruction) is
            when I_NOP =>
                next_state <= NOP_INST;
            when I_HALT =>
                next_state <= HALT_INST;
            when I_LOAD =>
                next_state <= INST_LOAD;
            when I_STORE =>
                next_state <= INST_STORE;
                operation <= "00";
            when I_MOVE =>
                next_state <= INST_MOVE;
            when I_ADD =>
                next_state <= INST_ARITH;
                operation <= "00";
            when I_SUB =>
                next_state <= INST_ARITH;
                operation <= "01";
            when I_AND =>
                next_state <= INST_ARITH;
                operation <= "10";
            when I_OR =>
                next_state <= INST_ARITH;
                operation <= "11";
            when I_BRANCH =>
                next_state <= INST_BRANCH;
            when I_BNEG =>
                next_state <= INST_BNEG;
            when I_BNNEG =>
                next_state <= INST_BNNEG;
            when I_BZERO =>
                next_state <= INST_BZERO;
            when I_BNZERO =>
                next_state <= INST_BNZERO;
            when others =>
                next_state <= INST_BNZERO;
            end case;
        
        when NOP_INST =>
            next_state <= PC_INC;
            ir_enable <= '0';
            addr_sel <= '0';
            c_sel <= '0';
            pc_enable <= '0';
            branch <= '0';
            ram_write_enable <= '0';
            flags_reg_enable <= '0';
            write_reg_enable <= '0'; 
            halt <= '0';      
        when HALT_INST =>
            halt <= '1';
            next_state <= HALT_INST; 
        when INST_LOAD =>
            next_state <= INST_LOAD_RAM;
            ir_enable <= '0';
            addr_sel <= '1'; -- 1 = mem_addr
            c_sel <= '1';  -- 1 = data_in
            pc_enable <= '0';
            branch <= '0'; -- 0 = pc
            ram_write_enable <= '0';
            flags_reg_enable <= '0';
            write_reg_enable <= '0'; 
            halt <= '0';      
        when INST_LOAD_RAM =>
            next_state <= PC_INC;
            write_reg_enable <= '1'; 
        when INST_STORE =>
            next_state <= PC_INC;
            ir_enable <= '0';
            addr_sel <= '1';
            c_sel <= '0';
            pc_enable <= '0';
            branch <= '0';
            ram_write_enable <= '1';
            flags_reg_enable <= '0';
            write_reg_enable <= '0'; 
            halt <= '0';   
        when INST_MOVE =>
            next_state <= PC_INC;
            ir_enable <= '0';
            addr_sel <= '0';
            c_sel <= '0';
            pc_enable <= '0';
            branch <= '0';
            ram_write_enable <= '0';
            flags_reg_enable <= '0';
            write_reg_enable <= '1'; 
            halt <= '0';
            operation <= "00";   
        when INST_ARITH =>
            next_state <= PC_INC;
            ir_enable <= '0';
            addr_sel <= '0';
            c_sel <= '0';
            pc_enable <= '0';
            branch <= '0';
            ram_write_enable <= '0';
            flags_reg_enable <= '1';
            write_reg_enable <= '1'; 
            halt <= '0';   
        when INST_BRANCH =>
            next_state <= PC_INC_R;
            ir_enable <= '0';
            addr_sel <= '0';
            c_sel <= '0';
            pc_enable <= '1';--
            branch <= '1';
            ram_write_enable <= '0';
            flags_reg_enable <= '0';
            write_reg_enable <= '0'; 
            halt <= '0';       
        when INST_BNEG =>
            next_state <= PC_INC_R;
            ir_enable <= '0';
            addr_sel <= '0';
            c_sel <= '0';
            pc_enable <= '1';
            if (neg_op = '1') then
                branch <= '1';
            else
                branch <= '0';
            end if;
            ram_write_enable <= '0';
            flags_reg_enable <= '0';
            write_reg_enable <= '0'; 
            halt <= '0';   
        when INST_BNNEG =>
            next_state <= PC_INC_R;
            ir_enable <= '0';
            addr_sel <= '0';
            c_sel <= '0';
            pc_enable <= '1';
            if (neg_op = '1') then
                branch <= '0';
            else
                branch <= '1';
            end if;
            ram_write_enable <= '0';
            flags_reg_enable <= '0';
            write_reg_enable <= '0'; 
            halt <= '0';   
        when INST_BZERO =>
            next_state <= PC_INC_R;
            ir_enable <= '0';
            addr_sel <= '0';
            c_sel <= '0';
            pc_enable <= '1';
            if (zero_op = '1') then
                branch <= '1';
            else
                branch <= '0';
            end if;
            ram_write_enable <= '0';
            flags_reg_enable <= '0';
            write_reg_enable <= '0'; 
            halt <= '0';   
        when INST_BNZERO =>
            next_state <= PC_INC_R;
            ir_enable <= '0';
            addr_sel <= '0';
            c_sel <= '0';
            pc_enable <= '1';
            if (zero_op = '1') then
                branch <= '0';
            else
                branch <= '1';
            end if;
            ram_write_enable <= '0';
            flags_reg_enable <= '0';
            write_reg_enable <= '0'; 
            halt <= '0';  
        when PC_INC =>
            next_state <= PC_INC_R;
            ir_enable <= '0';
            addr_sel <= '0';
            c_sel <= '0';
            pc_enable <= '1';
            branch <= '0';
            ram_write_enable <= '0';
            flags_reg_enable <= '0';
            write_reg_enable <= '0';
            halt <= '0';       
        when others => --PC_INC_R
            next_state <= GET_INST;
            ir_enable <= '0';
            addr_sel <= '0';
            c_sel <= '0';
            pc_enable <= '0';
            branch <= '0';

            halt <= '0';    
        end case;     
    end process;
    
    
end rtl;

