----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Joao Leonardo Fragoso
-- 
-- Create Date:    19:04:44 06/26/2012 
-- Design Name:    K and S Modeling
-- Module Name:    data_path - rtl 
-- Description:    RTL Code for the K and S datapath
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
--          0.02 - Moving Vivado 2017.3
-- Additional Comments: 
--
----------------------------------------------------------------------------------
-- Pedro DAvila Silva Medeiros
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all; -- 
use ieee.NUMERIC_STD.all;
library work;
use work.k_and_s_pkg.all;

entity data_path is
  port (
    rst_n               : in  std_logic;
    clk                 : in  std_logic;
    branch              : in  std_logic;
    pc_enable           : in  std_logic;
    ir_enable           : in  std_logic;
    addr_sel            : in  std_logic;
    c_sel               : in  std_logic;
    operation           : in  std_logic_vector ( 1 downto 0);
    write_reg_enable    : in  std_logic;
    flags_reg_enable    : in  std_logic;
    decoded_instruction : out decoded_instruction_type;
    zero_op             : out std_logic;
    neg_op              : out std_logic;
    unsigned_overflow   : out std_logic;
    signed_overflow     : out std_logic;
    ram_addr            : out std_logic_vector ( 4 downto 0);
    data_out            : out std_logic_vector (15 downto 0);
    data_in             : in  std_logic_vector (15 downto 0)
  );
end data_path;

architecture rtl of data_path is
signal mem_addr: std_logic_vector (4 downto 0);
signal instruction : std_logic_vector (15 downto 0);
signal a_addr : std_logic_vector (1 downto 0);
signal b_addr : std_logic_vector (1 downto 0);
signal c_addr : std_logic_vector (1 downto 0);
signal bus_a : std_logic_vector (15 downto 0);
signal bus_b : std_logic_vector (15 downto 0);
signal bus_c : std_logic_vector (15 downto 0);
signal R0 : std_logic_vector (15 downto 0);
signal R1 : std_logic_vector (15 downto 0);
signal R2 : std_logic_vector (15 downto 0);
signal R3 : std_logic_vector (15 downto 0);

signal zero_r, zero_rr : std_logic;
signal neg_r,neg_rr : std_logic;
signal unsig_r,unsig_rr : std_logic;
signal sig_r, sig_rr : std_logic;

signal Z_ULA : std_logic_vector (15 downto 0);
signal program_counter : std_logic_vector (4 downto 0);
signal b_program_counter : std_logic_vector (4 downto 0);


signal operation_result : std_logic_vector (15 downto 0);
begin
    --ram_addr <= (others => '0'); -- just to avoid messaging from test... remove this line
    IR : process(data_in, ir_enable, clk)
        begin
        if (rst_n = '1') then
            if (ir_enable = '1') then
            instruction <= data_in;
            end if;
        
        end if;
    end process;
    
    DECODE : process(instruction)
        begin
        case instruction(15 downto 7) is
        when "100000010" =>
            decoded_instruction <= I_LOAD;
            c_addr <= instruction(6 downto 5);
            mem_addr <= instruction(4 downto 0);  
        when "100000100" =>
            decoded_instruction <= I_STORE;
            a_addr <= instruction(6 downto 5);
            mem_addr <= instruction(4 downto 0);  
        when "100100010" =>
            decoded_instruction <= I_MOVE;
            c_addr <= instruction(1 downto 0);
            b_addr <= instruction(3 downto 2);
            a_addr <= instruction(1 downto 0);
        when "101000010" =>
            decoded_instruction <= I_ADD;
            c_addr <= instruction(5 downto 4);
            b_addr <= instruction(1 downto 0);
            a_addr <= instruction(3 downto 2);
        when "101000100" =>
            decoded_instruction <= I_SUB;
            c_addr <= instruction(5 downto 4);
            b_addr <= instruction(1 downto 0);
            a_addr <= instruction(3 downto 2);
        when "101000110" =>
            decoded_instruction <= I_AND;
            c_addr <= instruction(5 downto 4);
            b_addr <= instruction(3 downto 2);
            a_addr <= instruction(1 downto 0);
        when "101001000" =>
            decoded_instruction <= I_OR;  
            c_addr <= instruction(5 downto 4);
            b_addr <= instruction(3 downto 2);
            a_addr <= instruction(1 downto 0);
                         
        when "000000010" =>
            decoded_instruction <= I_BRANCH; 
            mem_addr <= instruction(4 downto 0); 
        when "000000100" =>
            decoded_instruction <= I_BZERO;
            mem_addr <= instruction(4 downto 0); 
        when "000000110" =>
            decoded_instruction <= I_BNEG;
            mem_addr <= instruction(4 downto 0); 
        when "000010100" =>
            decoded_instruction <= I_BNNEG;
            mem_addr <= instruction(4 downto 0); 
        when "000010110" =>
            decoded_instruction <= I_BNZERO;
            mem_addr <= instruction(4 downto 0); 
        
        when others =>
            if (instruction = "1111111111111111") then
            decoded_instruction <= I_HALT;
            else
            decoded_instruction <= I_NOP;
            mem_addr <= instruction(4 downto 0); --ram
            end if;
        end case;        
    end process;
    
    Register_Bank : process(a_addr,b_addr,c_addr,write_reg_enable,bus_c,R0,R1,R2,R3,bus_a, clk)
    begin
    
        if (write_reg_enable = '1') then
            case c_addr is
            when "00" =>
                R0 <= bus_c;
            when "01" =>
                R1 <= bus_c;
            when "10" =>
                R2 <= bus_c;
            when "11" =>
                R3 <= bus_c;
            when others =>
                null;
            end case;
        end if; 
        
        case a_addr is
        when "00" =>
            bus_a <= R0;
        when "01" =>
            bus_a <= R1;
        when "10" =>
            bus_a <= R2;
        when "11" =>
            bus_a <= R3;
        when others =>
            bus_a <= R0;
        end case;
        
        case b_addr is
        when "00" =>
            bus_b <= R0;
        when "01" =>
            bus_b <= R1;
        when "10" =>
            bus_b <= R2;
        when "11" =>
            bus_b <= R3;
        when others =>
            bus_b <= R3;
        end case;
        
        data_out <= bus_a;
   
    end process;
    
    ULA_OP : process (clk,bus_a,bus_b)  
    begin
    if (clk'event and clk = '1') then
        if (operation = "00") then
            operation_result <= bus_a + bus_b;
        else
            operation_result <= bus_a - bus_b;
        end if;
    end if;
    end process;
    
    ULA : process (bus_a, bus_b,bus_c,operation,operation_result)
    begin
    case operation is
    when "00" =>            
        Z_ULA <= operation_result;        
        if (bus_a(15) = '0') then
            if (bus_b(15) = '0') then
                if (bus_c(15) = '0') then
                    unsig_r <= '0';
                    sig_r <= '0';
                else
                    unsig_r <= '0';
                    sig_r <= '1';    
                end if;
            else
                if (bus_c(15) = '0') then
                    unsig_r <= '1';
                    sig_r <= '0';
                else
                    unsig_r <= '0';
                    sig_r <= '0';
                end if;    
            end if;
        else
            if (bus_b(15) = '0') then
                if (bus_c(15) = '0') then
                    unsig_r <= '1';
                    sig_r <= '0';
                else
                    unsig_r <= '0';
                    sig_r <= '0';    
                end if;
            else
                if (bus_c(15) = '0') then
                    unsig_r <= '1';
                    sig_r <= '1';
                else
                    unsig_r <= '1';
                    sig_r <= '0';
                end if;    
            end if;
        end if;
        
    when "01" =>
        Z_ULA <= operation_result;
        if (bus_a(15) = '0') then
            if (bus_b(15) = '0') then
                if (bus_c(15) = '0') then
                    unsig_r <= '0';
                    sig_r <= '0';
                else
                    unsig_r <= '1';
                    sig_r <= '0';    
                end if;
            else
                if (bus_c(15) = '0') then
                    unsig_r <= '1';
                    sig_r <= '0';
                else
                    unsig_r <= '1';
                    sig_r <= '1';
                end if;    
            end if;
        else
            if (bus_b(15) = '0') then
                if (bus_c(15) = '0') then
                    unsig_r <= '0';
                    sig_r <= '1';
                else
                    unsig_r <= '0';
                    sig_r <= '0';    
                end if;
            else
                if (bus_c(15) = '0') then
                    unsig_r <= '0';
                    sig_r <= '0';
                else
                    unsig_r <= '1';
                    sig_r <= '0';
                end if;    
            end if;
       end if;
        
    when "10" =>
        Z_ULA <= bus_a AND bus_b;
    when "11" =>
        Z_ULA <= bus_a OR bus_b;
    when others =>
        Z_ULA <= bus_a OR bus_b;
    end case;
    
    if (bus_c = x"0000") then
        zero_r <= '1';
    else
        zero_r <= '0';
    end if;
    neg_r <= bus_c(15);
    
    
    end process;
    
    flag_register: process (clk, zero_r, neg_r, unsig_r, sig_r, flags_reg_enable)
    begin
    if (clk'event and clk = '1' and flags_reg_enable = '1') then
        zero_op <= zero_r;
        neg_op <= neg_r;
        unsigned_overflow <= unsig_r;
        signed_overflow <= sig_r;
    end if;
    end process;
    
    
    select_c: process(Z_ULA, data_in, c_sel)
    begin
    if (c_sel = '1') then
        bus_c <= data_in;
    else
        bus_c <= Z_ULA;
    end if;
    end process;
    
    
    branch_sel : process(branch, mem_addr, program_counter)
    begin
    if (branch = '1') then
        b_program_counter <= mem_addr;
    else
        b_program_counter <= program_counter + "00001";
    end if;
    end process;
     
    pc : process(b_program_counter, pc_enable, clk, rst_n)
    begin
    if (clk'event and clk = '1') then
        if (pc_enable = '1') then
            program_counter <= b_program_counter;-- + "00001";
        elsif
        (rst_n = '0') then
            program_counter <= "00000";    
        end if;
        
    end if;
    end process;
         
        
    addr_selection : process(addr_sel, mem_addr, program_counter)
    begin
    if (addr_sel = '0') then
        ram_addr <= program_counter;
    else
        ram_addr <= mem_addr;     
    end if;
    end process;
    
end rtl;

