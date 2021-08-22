----------------------------------------------------------------------
-- Created by SmartDesign Sat Aug 21 22:24:22 2021
-- Version: v2021.2 2021.2.0.11
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Libraries
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library smartfusion2;
use smartfusion2.all;
----------------------------------------------------------------------
-- SID_PLAYER entity declaration
----------------------------------------------------------------------
entity SID_PLAYER is
    -- Port list
    port(
        -- Inputs
        DEVRST_N     : in    std_logic;
        MMUART_0_RXD : in    std_logic;
        USER_BTN     : in    std_logic;
        -- Outputs
        BA           : out   std_logic_vector(1 downto 0);
        CAS_N        : out   std_logic;
        CKE          : out   std_logic;
        CS_N         : out   std_logic_vector(0 to 0);
        DQM          : out   std_logic_vector(1 downto 0);
        LED          : out   std_logic_vector(7 downto 0);
        MMUART_0_TXD : out   std_logic;
        RAS_N        : out   std_logic;
        SA           : out   std_logic_vector(13 downto 0);
        SDRCLK       : out   std_logic;
        USER_LED     : out   std_logic;
        WE_N         : out   std_logic;
        sid_addr     : out   std_logic_vector(4 downto 0);
        sid_clk      : out   std_logic;
        sid_cs_n     : out   std_logic;
        sid_rst_n    : out   std_logic;
        sid_rw       : out   std_logic;
        -- Inouts
        DQ           : inout std_logic_vector(15 downto 0);
        sid_data     : inout std_logic_vector(7 downto 0)
        );
end SID_PLAYER;
----------------------------------------------------------------------
-- SID_PLAYER architecture body
----------------------------------------------------------------------
architecture RTL of SID_PLAYER is
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
-- AND2
component AND2
    -- Port list
    port(
        -- Inputs
        A : in  std_logic;
        B : in  std_logic;
        -- Outputs
        Y : out std_logic
        );
end component;
-- CORESDR_AHB_C1
component CORESDR_AHB_C1
    -- Port list
    port(
        -- Inputs
        HADDR         : in    std_logic_vector(31 downto 0);
        HBURST        : in    std_logic_vector(2 downto 0);
        HCLK          : in    std_logic;
        HREADYIN      : in    std_logic;
        HRESETN       : in    std_logic;
        HSEL          : in    std_logic;
        HSIZE         : in    std_logic_vector(2 downto 0);
        HTRANS        : in    std_logic_vector(1 downto 0);
        HWDATA        : in    std_logic_vector(31 downto 0);
        HWRITE        : in    std_logic;
        SDRCLK_IN     : in    std_logic;
        SDRCLK_RESETN : in    std_logic;
        -- Outputs
        BA            : out   std_logic_vector(1 downto 0);
        CAS_N         : out   std_logic;
        CKE           : out   std_logic;
        CS_N          : out   std_logic_vector(0 to 0);
        DQM           : out   std_logic_vector(1 downto 0);
        HRDATA        : out   std_logic_vector(31 downto 0);
        HREADY        : out   std_logic;
        HRESP         : out   std_logic_vector(1 downto 0);
        OE            : out   std_logic;
        RAS_N         : out   std_logic;
        SA            : out   std_logic_vector(13 downto 0);
        SDRCLK_OUT    : out   std_logic;
        WE_N          : out   std_logic;
        -- Inouts
        DQ            : inout std_logic_vector(15 downto 0)
        );
end component;
-- INV
component INV
    -- Port list
    port(
        -- Inputs
        A : in  std_logic;
        -- Outputs
        Y : out std_logic
        );
end component;
-- SID_BRIDGE
-- using entity instantiation for component SID_BRIDGE
-- SID_PLAYER_sb
component SID_PLAYER_sb
    -- Port list
    port(
        -- Inputs
        AMBA_SDRAM_HRDATA_S0         : in  std_logic_vector(31 downto 0);
        AMBA_SDRAM_HREADYOUT_S0      : in  std_logic;
        AMBA_SDRAM_HRESP_S0          : in  std_logic_vector(1 downto 0);
        AMBA_SID_BRIDGE_HRDATA_S1    : in  std_logic_vector(31 downto 0);
        AMBA_SID_BRIDGE_HREADYOUT_S1 : in  std_logic;
        AMBA_SID_BRIDGE_HRESP_S1     : in  std_logic_vector(1 downto 0);
        DEVRST_N                     : in  std_logic;
        FAB_RESET_N                  : in  std_logic;
        GPIO_8_F2M                   : in  std_logic;
        MMUART_0_RXD                 : in  std_logic;
        -- Outputs
        AMBA_SDRAM_HADDR_S0          : out std_logic_vector(31 downto 0);
        AMBA_SDRAM_HBURST_S0         : out std_logic_vector(2 downto 0);
        AMBA_SDRAM_HMASTLOCK_S0      : out std_logic;
        AMBA_SDRAM_HPROT_S0          : out std_logic_vector(3 downto 0);
        AMBA_SDRAM_HREADY_S0         : out std_logic;
        AMBA_SDRAM_HSEL_S0           : out std_logic;
        AMBA_SDRAM_HSIZE_S0          : out std_logic_vector(2 downto 0);
        AMBA_SDRAM_HTRANS_S0         : out std_logic_vector(1 downto 0);
        AMBA_SDRAM_HWDATA_S0         : out std_logic_vector(31 downto 0);
        AMBA_SDRAM_HWRITE_S0         : out std_logic;
        AMBA_SID_BRIDGE_HADDR_S1     : out std_logic_vector(31 downto 0);
        AMBA_SID_BRIDGE_HBURST_S1    : out std_logic_vector(2 downto 0);
        AMBA_SID_BRIDGE_HMASTLOCK_S1 : out std_logic;
        AMBA_SID_BRIDGE_HPROT_S1     : out std_logic_vector(3 downto 0);
        AMBA_SID_BRIDGE_HREADY_S1    : out std_logic;
        AMBA_SID_BRIDGE_HSEL_S1      : out std_logic;
        AMBA_SID_BRIDGE_HSIZE_S1     : out std_logic_vector(2 downto 0);
        AMBA_SID_BRIDGE_HTRANS_S1    : out std_logic_vector(1 downto 0);
        AMBA_SID_BRIDGE_HWDATA_S1    : out std_logic_vector(31 downto 0);
        AMBA_SID_BRIDGE_HWRITE_S1    : out std_logic;
        FIC_0_CLK                    : out std_logic;
        FIC_0_LOCK                   : out std_logic;
        GPIO_0_M2F                   : out std_logic;
        GPIO_1_M2F                   : out std_logic;
        GPIO_2_M2F                   : out std_logic;
        GPIO_3_M2F                   : out std_logic;
        GPIO_4_M2F                   : out std_logic;
        GPIO_5_M2F                   : out std_logic;
        GPIO_6_M2F                   : out std_logic;
        GPIO_7_M2F                   : out std_logic;
        GPIO_9_M2F                   : out std_logic;
        INIT_DONE                    : out std_logic;
        MMUART_0_TXD                 : out std_logic;
        MSS_READY                    : out std_logic;
        POWER_ON_RESET_N             : out std_logic
        );
end component;
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal AND2_0_Y_1                               : std_logic;
signal BA_net_0                                 : std_logic_vector(1 downto 0);
signal CAS_N_net_0                              : std_logic;
signal CKE_net_0                                : std_logic;
signal CS_N_net_0                               : std_logic_vector(0 to 0);
signal DQM_net_0                                : std_logic_vector(1 downto 0);
signal LED_0                                    : std_logic;
signal LED_1                                    : std_logic;
signal LED_2                                    : std_logic;
signal LED_3                                    : std_logic;
signal LED_4                                    : std_logic;
signal LED_5                                    : std_logic;
signal LED_6                                    : std_logic;
signal LED_7                                    : std_logic;
signal MMUART_0_TXD_net_0                       : std_logic;
signal RAS_N_net_0                              : std_logic;
signal SA_net_0                                 : std_logic_vector(13 downto 0);
signal SDRCLK_net_0                             : std_logic;
signal sid_addr_net_0                           : std_logic_vector(4 downto 0);
signal sid_clk_net_0                            : std_logic;
signal sid_cs_n_net_0                           : std_logic;
signal sid_rst_n_net_0                          : std_logic;
signal sid_rw_net_0                             : std_logic;
signal SID_SABER_sb_0_AMBA_SDRAM_HADDR          : std_logic_vector(31 downto 0);
signal SID_SABER_sb_0_AMBA_SDRAM_HBURST         : std_logic_vector(2 downto 0);
signal SID_SABER_sb_0_AMBA_SDRAM_HMASTLOCK      : std_logic;
signal SID_SABER_sb_0_AMBA_SDRAM_HPROT          : std_logic_vector(3 downto 0);
signal SID_SABER_sb_0_AMBA_SDRAM_HRDATA         : std_logic_vector(31 downto 0);
signal SID_SABER_sb_0_AMBA_SDRAM_HREADY         : std_logic;
signal SID_SABER_sb_0_AMBA_SDRAM_HREADYOUT      : std_logic;
signal SID_SABER_sb_0_AMBA_SDRAM_HRESP          : std_logic_vector(1 downto 0);
signal SID_SABER_sb_0_AMBA_SDRAM_HSELx          : std_logic;
signal SID_SABER_sb_0_AMBA_SDRAM_HSIZE          : std_logic_vector(2 downto 0);
signal SID_SABER_sb_0_AMBA_SDRAM_HTRANS         : std_logic_vector(1 downto 0);
signal SID_SABER_sb_0_AMBA_SDRAM_HWDATA         : std_logic_vector(31 downto 0);
signal SID_SABER_sb_0_AMBA_SDRAM_HWRITE         : std_logic;
signal SID_SABER_sb_0_AMBA_SID_BRIDGE_HADDR     : std_logic_vector(31 downto 0);
signal SID_SABER_sb_0_AMBA_SID_BRIDGE_HBURST    : std_logic_vector(2 downto 0);
signal SID_SABER_sb_0_AMBA_SID_BRIDGE_HMASTLOCK : std_logic;
signal SID_SABER_sb_0_AMBA_SID_BRIDGE_HPROT     : std_logic_vector(3 downto 0);
signal SID_SABER_sb_0_AMBA_SID_BRIDGE_HRDATA    : std_logic_vector(31 downto 0);
signal SID_SABER_sb_0_AMBA_SID_BRIDGE_HREADY    : std_logic;
signal SID_SABER_sb_0_AMBA_SID_BRIDGE_HREADYOUT : std_logic;
signal SID_SABER_sb_0_AMBA_SID_BRIDGE_HRESP     : std_logic_vector(1 downto 0);
signal SID_SABER_sb_0_AMBA_SID_BRIDGE_HSELx     : std_logic;
signal SID_SABER_sb_0_AMBA_SID_BRIDGE_HSIZE     : std_logic_vector(2 downto 0);
signal SID_SABER_sb_0_AMBA_SID_BRIDGE_HTRANS    : std_logic_vector(1 downto 0);
signal SID_SABER_sb_0_AMBA_SID_BRIDGE_HWDATA    : std_logic_vector(31 downto 0);
signal SID_SABER_sb_0_AMBA_SID_BRIDGE_HWRITE    : std_logic;
signal SID_SABER_sb_0_FIC_0_CLK_1               : std_logic;
signal SID_SABER_sb_0_FIC_0_LOCK                : std_logic;
signal SID_SABER_sb_0_POWER_ON_RESET_N          : std_logic;
signal USER_LED_net_0                           : std_logic;
signal USER_LED_0                               : std_logic;
signal WE_N_net_0                               : std_logic;
signal MMUART_0_TXD_net_1                       : std_logic;
signal USER_LED_0_net_0                         : std_logic;
signal sid_cs_n_net_1                           : std_logic;
signal sid_rw_net_1                             : std_logic;
signal sid_rst_n_net_1                          : std_logic;
signal sid_clk_net_1                            : std_logic;
signal RAS_N_net_1                              : std_logic;
signal CAS_N_net_1                              : std_logic;
signal WE_N_net_1                               : std_logic;
signal CKE_net_1                                : std_logic;
signal SDRCLK_net_1                             : std_logic;
signal sid_addr_net_1                           : std_logic_vector(4 downto 0);
signal LED_1_net_0                              : std_logic_vector(0 to 0);
signal LED_0_net_0                              : std_logic_vector(1 to 1);
signal LED_2_net_0                              : std_logic_vector(2 to 2);
signal LED_3_net_0                              : std_logic_vector(3 to 3);
signal LED_4_net_0                              : std_logic_vector(4 to 4);
signal LED_5_net_0                              : std_logic_vector(5 to 5);
signal LED_6_net_0                              : std_logic_vector(6 to 6);
signal LED_7_net_0                              : std_logic_vector(7 to 7);
signal SA_net_1                                 : std_logic_vector(13 downto 0);
signal BA_net_1                                 : std_logic_vector(1 downto 0);
signal CS_N_net_1                               : std_logic_vector(0 to 0);
signal DQM_net_1                                : std_logic_vector(1 downto 0);
----------------------------------------------------------------------
-- TiedOff Signals
----------------------------------------------------------------------
signal VCC_net                                  : std_logic;

begin
----------------------------------------------------------------------
-- Constant assignments
----------------------------------------------------------------------
 VCC_net <= '1';
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 MMUART_0_TXD_net_1   <= MMUART_0_TXD_net_0;
 MMUART_0_TXD         <= MMUART_0_TXD_net_1;
 USER_LED_0_net_0     <= USER_LED_0;
 USER_LED             <= USER_LED_0_net_0;
 sid_cs_n_net_1       <= sid_cs_n_net_0;
 sid_cs_n             <= sid_cs_n_net_1;
 sid_rw_net_1         <= sid_rw_net_0;
 sid_rw               <= sid_rw_net_1;
 sid_rst_n_net_1      <= sid_rst_n_net_0;
 sid_rst_n            <= sid_rst_n_net_1;
 sid_clk_net_1        <= sid_clk_net_0;
 sid_clk              <= sid_clk_net_1;
 RAS_N_net_1          <= RAS_N_net_0;
 RAS_N                <= RAS_N_net_1;
 CAS_N_net_1          <= CAS_N_net_0;
 CAS_N                <= CAS_N_net_1;
 WE_N_net_1           <= WE_N_net_0;
 WE_N                 <= WE_N_net_1;
 CKE_net_1            <= CKE_net_0;
 CKE                  <= CKE_net_1;
 SDRCLK_net_1         <= SDRCLK_net_0;
 SDRCLK               <= SDRCLK_net_1;
 sid_addr_net_1       <= sid_addr_net_0;
 sid_addr(4 downto 0) <= sid_addr_net_1;
 LED_1_net_0(0)       <= LED_1;
 LED(0)               <= LED_1_net_0(0);
 LED_0_net_0(1)       <= LED_0;
 LED(1)               <= LED_0_net_0(1);
 LED_2_net_0(2)       <= LED_2;
 LED(2)               <= LED_2_net_0(2);
 LED_3_net_0(3)       <= LED_3;
 LED(3)               <= LED_3_net_0(3);
 LED_4_net_0(4)       <= LED_4;
 LED(4)               <= LED_4_net_0(4);
 LED_5_net_0(5)       <= LED_5;
 LED(5)               <= LED_5_net_0(5);
 LED_6_net_0(6)       <= LED_6;
 LED(6)               <= LED_6_net_0(6);
 LED_7_net_0(7)       <= LED_7;
 LED(7)               <= LED_7_net_0(7);
 SA_net_1             <= SA_net_0;
 SA(13 downto 0)      <= SA_net_1;
 BA_net_1             <= BA_net_0;
 BA(1 downto 0)       <= BA_net_1;
 CS_N_net_1(0)        <= CS_N_net_0(0);
 CS_N(0)              <= CS_N_net_1(0);
 DQM_net_1            <= DQM_net_0;
 DQM(1 downto 0)      <= DQM_net_1;
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- AND2_0
AND2_0 : AND2
    port map( 
        -- Inputs
        A => SID_SABER_sb_0_POWER_ON_RESET_N,
        B => SID_SABER_sb_0_FIC_0_LOCK,
        -- Outputs
        Y => AND2_0_Y_1 
        );
-- CORESDR_AHB_C1_0
CORESDR_AHB_C1_0 : CORESDR_AHB_C1
    port map( 
        -- Inputs
        HCLK          => SID_SABER_sb_0_FIC_0_CLK_1,
        HRESETN       => AND2_0_Y_1,
        SDRCLK_IN     => SID_SABER_sb_0_FIC_0_CLK_1,
        SDRCLK_RESETN => AND2_0_Y_1,
        HWRITE        => SID_SABER_sb_0_AMBA_SDRAM_HWRITE,
        HSEL          => SID_SABER_sb_0_AMBA_SDRAM_HSELx,
        HREADYIN      => SID_SABER_sb_0_AMBA_SDRAM_HREADY,
        HADDR         => SID_SABER_sb_0_AMBA_SDRAM_HADDR,
        HTRANS        => SID_SABER_sb_0_AMBA_SDRAM_HTRANS,
        HBURST        => SID_SABER_sb_0_AMBA_SDRAM_HBURST,
        HSIZE         => SID_SABER_sb_0_AMBA_SDRAM_HSIZE,
        HWDATA        => SID_SABER_sb_0_AMBA_SDRAM_HWDATA,
        -- Outputs
        OE            => OPEN,
        RAS_N         => RAS_N_net_0,
        CAS_N         => CAS_N_net_0,
        WE_N          => WE_N_net_0,
        CKE           => CKE_net_0,
        SDRCLK_OUT    => SDRCLK_net_0,
        HREADY        => SID_SABER_sb_0_AMBA_SDRAM_HREADYOUT,
        SA            => SA_net_0,
        BA            => BA_net_0,
        CS_N          => CS_N_net_0,
        DQM           => DQM_net_0,
        HRDATA        => SID_SABER_sb_0_AMBA_SDRAM_HRDATA,
        HRESP         => SID_SABER_sb_0_AMBA_SDRAM_HRESP,
        -- Inouts
        DQ            => DQ 
        );
-- INV_0
INV_0 : INV
    port map( 
        -- Inputs
        A => USER_LED_net_0,
        -- Outputs
        Y => USER_LED_0 
        );
-- SID_BRIDGE_0
SID_BRIDGE_0 : entity work.SID_BRIDGE
    port map( 
        -- Inputs
        HCLK      => SID_SABER_sb_0_FIC_0_CLK_1,
        HRESETN   => AND2_0_Y_1,
        HREADYIN  => SID_SABER_sb_0_AMBA_SID_BRIDGE_HREADY,
        HSEL      => SID_SABER_sb_0_AMBA_SID_BRIDGE_HSELx,
        HWRITE    => SID_SABER_sb_0_AMBA_SID_BRIDGE_HWRITE,
        HMASTLOCK => SID_SABER_sb_0_AMBA_SID_BRIDGE_HMASTLOCK,
        HADDR     => SID_SABER_sb_0_AMBA_SID_BRIDGE_HADDR,
        HBURST    => SID_SABER_sb_0_AMBA_SID_BRIDGE_HBURST,
        HSIZE     => SID_SABER_sb_0_AMBA_SID_BRIDGE_HSIZE,
        HTRANS    => SID_SABER_sb_0_AMBA_SID_BRIDGE_HTRANS,
        HWDATA    => SID_SABER_sb_0_AMBA_SID_BRIDGE_HWDATA,
        HPROT     => SID_SABER_sb_0_AMBA_SID_BRIDGE_HPROT,
        -- Outputs
        HREADYOUT => SID_SABER_sb_0_AMBA_SID_BRIDGE_HREADYOUT,
        sid_cs_n  => sid_cs_n_net_0,
        sid_rw    => sid_rw_net_0,
        sid_rst_n => sid_rst_n_net_0,
        sid_clk   => sid_clk_net_0,
        HRDATA    => SID_SABER_sb_0_AMBA_SID_BRIDGE_HRDATA,
        HRESP     => SID_SABER_sb_0_AMBA_SID_BRIDGE_HRESP,
        sid_addr  => sid_addr_net_0,
        -- Inouts
        sid_data  => sid_data 
        );
-- SID_PLAYER_sb_0
SID_PLAYER_sb_0 : SID_PLAYER_sb
    port map( 
        -- Inputs
        MMUART_0_RXD                 => MMUART_0_RXD,
        FAB_RESET_N                  => VCC_net,
        AMBA_SDRAM_HREADYOUT_S0      => SID_SABER_sb_0_AMBA_SDRAM_HREADYOUT,
        AMBA_SID_BRIDGE_HREADYOUT_S1 => SID_SABER_sb_0_AMBA_SID_BRIDGE_HREADYOUT,
        DEVRST_N                     => DEVRST_N,
        GPIO_8_F2M                   => USER_BTN,
        AMBA_SDRAM_HRDATA_S0         => SID_SABER_sb_0_AMBA_SDRAM_HRDATA,
        AMBA_SDRAM_HRESP_S0          => SID_SABER_sb_0_AMBA_SDRAM_HRESP,
        AMBA_SID_BRIDGE_HRDATA_S1    => SID_SABER_sb_0_AMBA_SID_BRIDGE_HRDATA,
        AMBA_SID_BRIDGE_HRESP_S1     => SID_SABER_sb_0_AMBA_SID_BRIDGE_HRESP,
        -- Outputs
        MMUART_0_TXD                 => MMUART_0_TXD_net_0,
        POWER_ON_RESET_N             => SID_SABER_sb_0_POWER_ON_RESET_N,
        INIT_DONE                    => OPEN,
        AMBA_SDRAM_HWRITE_S0         => SID_SABER_sb_0_AMBA_SDRAM_HWRITE,
        AMBA_SDRAM_HSEL_S0           => SID_SABER_sb_0_AMBA_SDRAM_HSELx,
        AMBA_SDRAM_HREADY_S0         => SID_SABER_sb_0_AMBA_SDRAM_HREADY,
        AMBA_SDRAM_HMASTLOCK_S0      => SID_SABER_sb_0_AMBA_SDRAM_HMASTLOCK,
        AMBA_SID_BRIDGE_HWRITE_S1    => SID_SABER_sb_0_AMBA_SID_BRIDGE_HWRITE,
        AMBA_SID_BRIDGE_HSEL_S1      => SID_SABER_sb_0_AMBA_SID_BRIDGE_HSELx,
        AMBA_SID_BRIDGE_HREADY_S1    => SID_SABER_sb_0_AMBA_SID_BRIDGE_HREADY,
        AMBA_SID_BRIDGE_HMASTLOCK_S1 => SID_SABER_sb_0_AMBA_SID_BRIDGE_HMASTLOCK,
        FIC_0_CLK                    => SID_SABER_sb_0_FIC_0_CLK_1,
        FIC_0_LOCK                   => SID_SABER_sb_0_FIC_0_LOCK,
        MSS_READY                    => OPEN,
        GPIO_0_M2F                   => LED_1,
        GPIO_1_M2F                   => LED_0,
        GPIO_2_M2F                   => LED_2,
        GPIO_3_M2F                   => LED_3,
        GPIO_4_M2F                   => LED_4,
        GPIO_5_M2F                   => LED_5,
        GPIO_6_M2F                   => LED_6,
        GPIO_7_M2F                   => LED_7,
        GPIO_9_M2F                   => USER_LED_net_0,
        AMBA_SDRAM_HADDR_S0          => SID_SABER_sb_0_AMBA_SDRAM_HADDR,
        AMBA_SDRAM_HTRANS_S0         => SID_SABER_sb_0_AMBA_SDRAM_HTRANS,
        AMBA_SDRAM_HSIZE_S0          => SID_SABER_sb_0_AMBA_SDRAM_HSIZE,
        AMBA_SDRAM_HWDATA_S0         => SID_SABER_sb_0_AMBA_SDRAM_HWDATA,
        AMBA_SDRAM_HBURST_S0         => SID_SABER_sb_0_AMBA_SDRAM_HBURST,
        AMBA_SDRAM_HPROT_S0          => SID_SABER_sb_0_AMBA_SDRAM_HPROT,
        AMBA_SID_BRIDGE_HADDR_S1     => SID_SABER_sb_0_AMBA_SID_BRIDGE_HADDR,
        AMBA_SID_BRIDGE_HTRANS_S1    => SID_SABER_sb_0_AMBA_SID_BRIDGE_HTRANS,
        AMBA_SID_BRIDGE_HSIZE_S1     => SID_SABER_sb_0_AMBA_SID_BRIDGE_HSIZE,
        AMBA_SID_BRIDGE_HWDATA_S1    => SID_SABER_sb_0_AMBA_SID_BRIDGE_HWDATA,
        AMBA_SID_BRIDGE_HBURST_S1    => SID_SABER_sb_0_AMBA_SID_BRIDGE_HBURST,
        AMBA_SID_BRIDGE_HPROT_S1     => SID_SABER_sb_0_AMBA_SID_BRIDGE_HPROT 
        );

end RTL;
