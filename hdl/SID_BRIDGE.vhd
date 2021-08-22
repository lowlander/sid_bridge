
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library smartfusion2;
use smartfusion2.all;

entity SID_BRIDGE is
port (
        HCLK        : in  std_logic;
        HRESETN     : in  std_logic;

        HADDR       : in  std_logic_vector(31 downto 0);
        HBURST      : in  std_logic_vector(2 downto 0);
        HREADYIN    : in  std_logic;
        HSEL        : in  std_logic;
        HSIZE       : in  std_logic_vector(2 downto 0);
        HTRANS      : in  std_logic_vector(1 downto 0);
        HWDATA      : in  std_logic_vector(31 downto 0);
        HWRITE      : in  std_logic;
        HPROT       : in  std_logic_vector(3 downto 0);
        HMASTLOCK   : in  std_logic;
        
        HRDATA      : out std_logic_vector(31 downto 0);
        HREADYOUT   : out std_logic;
        HRESP       : out std_logic_vector(1 downto 0);

        sid_addr    : out STD_LOGIC_VECTOR (4 downto 0);
        sid_data    : inout STD_LOGIC_VECTOR (7 downto 0);
        sid_cs_n    : out STD_LOGIC;
        sid_rw      : out STD_LOGIC;
        sid_rst_n   : out STD_LOGIC;
        sid_clk     : out STD_LOGIC
);
end SID_BRIDGE;

architecture architecture_SID_BRIDGE of SID_BRIDGE is
    component BIBUF
        generic (
            IOSTD   : string := ""
        );
        port( 
            PAD : inout std_logic;
            D   : in    std_logic := 'U';
            E   : in    std_logic := 'U';
            Y   : out   std_logic
        );
    end component;

    constant zero           : std_logic_vector(31 downto 0) := (others => '0');
    
    type state_type is ( st_idle, st_error, 
                         st_read_sid_st1, st_read_sid_st2, st_read_sid_st3, st_read_sid_st4, st_read_sid_st5, st_read_sid_st6,
                         st_write_sid_st1, st_write_sid_st2, st_write_sid_st3, st_write_sid_st4, st_write_sid_st5, st_write_sid_st6,
                         st_read_reg, st_write_reg );
     
    type reg_type is record
        state           : state_type;
 
        REG_ADDR        : std_logic_vector(1 downto 0);
        sid_freq        : std_logic_vector(7 downto 0);
        sid_clk_cntr    : integer range 0 to 1000000;
                
        HRDATA          : std_logic_vector(31 downto 0);
        HREADYOUT       : std_logic;
        HRESP           : std_logic_vector(1 downto 0);

        sid_addr        : STD_LOGIC_VECTOR (4 downto 0);
        sid_data_o      : STD_LOGIC_VECTOR (7 downto 0);
        sid_data_oe     : std_logic;
        sid_cs_n        : STD_LOGIC;
        sid_rw          : STD_LOGIC;
        sid_rst_n       : STD_LOGIC;
        sid_clk         : STD_LOGIC;
    end record;

    constant reset_reg : reg_type := (
        state           => st_idle,

        REG_ADDR        => (others => '-'),
        sid_freq        => "00100011", --  36

        sid_clk_cntr    => 0,
        
        HRDATA          => (others => '0'),
        HREADYOUT       => '1',
        HRESP           => (others => '0'),
        
        sid_addr        => (others => '0'),
        sid_data_o      => (others => '0'),
        sid_data_oe     => '0',
        sid_cs_n        => '1',
        sid_rw          => '0',
        sid_rst_n       => '0',
        sid_clk         => '0'
    );

    signal reg          : reg_type;
    signal next_reg     : reg_type;

    signal sid_data_i   : std_logic_vector(7 downto 0);
begin
    GEN_BIDUF : for I in 0 to 7 generate
        BIBUF_X : BIBUF port map (
            PAD => sid_data(I), 
            D   => reg.sid_data_o(I), 
            E   => reg.sid_data_oe, 
            Y   => sid_data_i(I)
        );
    end generate GEN_BIDUF;


    process(reg, HRESETN, HADDR, HBURST, HREADYIN, HSEL, HSIZE, HTRANS, HWDATA, HWRITE, HPROT, HMASTLOCK, sid_data_i)
        variable v : reg_type;
    begin
        v := reg;
        
        if (reg.sid_clk_cntr < unsigned(reg.sid_freq)) then
            v.sid_clk_cntr := reg.sid_clk_cntr + 1;            
        else
            v.sid_clk := not reg.sid_clk;
            v.sid_clk_cntr := 0;
        end if;

        --
        -- ABP Bus FSM
        --
        case reg.state is

            when st_idle =>
                v.sid_data_oe := '0';
                
                if (HSEL = '1') then
                    
                    v.HREADYOUT := '1';
                    
                    if (HADDR(14) = '0') then
                        v.REG_ADDR := HADDR(3 downto 2);
                        if (HWRITE = '1') then
                            v.state := st_write_reg;
                        else
                            v.HRDATA := (others => '0');
                            case v.REG_ADDR is
                                when "00" => v.HRDATA(0)            := reg.sid_rst_n;
                                when "01" => v.HRDATA(7 downto 0)   := reg.sid_freq;
                                when others => null;
                            end case;
                        end if;
                    else
                        v.HREADYOUT := '0';
                        v.sid_addr := HADDR(6 downto 2);
                        if (HWRITE = '1') then
                            v.state := st_write_sid_st1;
                        else
                            v.state := st_read_sid_st1;
                        end if;                    
                    end if;
                
                end if;
                            
            when st_write_reg =>
                case reg.REG_ADDR is
                    when "00" => v.sid_rst_n    := HWDATA(0);
                    when "01" => v.sid_freq     := HWDATA(7 downto 0);
                    when others => null;
                end case;                
                v.state := st_idle;
                
            when st_read_sid_st1 =>
                v.sid_data_oe := '0';
                if (reg.sid_clk = '0') then
                    v.sid_cs_n  := '0';
                    v.sid_rw    := '1';               
                    v.state := st_read_sid_st2;
                end if;

            when st_read_sid_st2 =>
                if (reg.sid_clk = '1') then
                    v.state := st_read_sid_st3;
                end if;
                
            when st_read_sid_st3 =>
                if (reg.sid_clk = '0') then
                    v.HRDATA                := (others => '0');
                    v.HRDATA(7 downto 0)    := sid_data_i;
                    v.state                 := st_read_sid_st4;
                end if;

            when st_read_sid_st4 =>
                v.state := st_read_sid_st5;

            when st_read_sid_st5 =>
                v.state := st_read_sid_st6;
                
            when st_read_sid_st6 =>
                v.HREADYOUT := '1';
                v.sid_cs_n  := '1';
                v.sid_rw    := '1';               
                v.state := st_idle;

            when st_write_sid_st1 =>
                v.sid_data_o := HWDATA(7 downto 0);
                v.sid_data_oe := '0';
                if (reg.sid_clk = '0') then
                    v.sid_cs_n  := '0';
                    v.sid_rw    := '0';
                    v.state := st_write_sid_st2;
                end if;

            when st_write_sid_st2 =>
                if (reg.sid_clk = '1') then
                    v.sid_data_oe := '1';
                    v.state := st_write_sid_st3;
                end if;
                
            when st_write_sid_st3 =>
                if (reg.sid_clk = '0') then
                    v.state := st_write_sid_st4;
                end if;

            when st_write_sid_st4 =>
                v.state := st_write_sid_st5;

            when st_write_sid_st5 =>
                v.state := st_write_sid_st6;
                
            when st_write_sid_st6 =>
                v.sid_data_oe := '0';
                v.HREADYOUT := '1';
                v.sid_cs_n  := '1';
                v.sid_rw    := '1';               
                v.state := st_idle;
                
            when st_error =>
                v.state := st_idle;
    
            when others =>
                v.state := st_idle;
        
        end case;
        
                
        --
        -- reset everything
        --
        if (HRESETN = '0') then
            v := reset_reg;
        end if;
        
        
        next_reg        <= v;
    
        --
        -- set outputs
        -- 
        
        HRDATA      <= reg.HRDATA;
        HREADYOUT   <= reg.HREADYOUT;
        HRESP       <= reg.HRESP;

        sid_addr    <= reg.sid_addr;
        sid_cs_n    <= reg.sid_cs_n;
        sid_rw      <= reg.sid_rw;
        sid_rst_n   <= reg.sid_rst_n;
        sid_clk     <= reg.sid_clk;

    end process;

    process(HCLK) 
    begin
        if (rising_edge(HCLK)) then
            reg <= next_reg;
        end if;
    end process;

end architecture_SID_BRIDGE;
