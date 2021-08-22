-- ***********************************************************************/
-- Microsemi Corporation Proprietary and Confidential
-- Copyright 2013 Microsemi Corporation.  All rights reserved.
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
-- IN ADVANCE IN WRITING.
--
-- Description:	CoreConfigP
--				Soft IP core for facilitating configuration of peripheral
--              blocks (MDDR, FDDR, SERDESIF) in a SmartFusion2 or IGLOO2
--              device.
--
-- SVN Revision Information:
-- SVN $Revision: 22264 $
-- SVN $Date: 2014-04-02 15:55:11 +0100 (Wed, 02 Apr 2014) $
--
-- Notes:
--
-- ***********************************************************************/

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CoreConfigP is
    generic(
    FAMILY                  : integer := 19;
    -- Use the following parameters to indicate whether or not a particular
    -- peripheral block is being used (and connected to this core).
    MDDR_IN_USE             : integer := 1;
    FDDR_IN_USE             : integer := 1;
    SDIF0_IN_USE            : integer := 1;
    SDIF1_IN_USE            : integer := 1;
    SDIF2_IN_USE            : integer := 1;
    SDIF3_IN_USE            : integer := 1;
    -- Following are used to indicate if a particular SDIF block is used
    -- for PCIe.
    SDIF0_PCIE              : integer := 0;
    SDIF1_PCIE              : integer := 0;
    SDIF2_PCIE              : integer := 0;
    SDIF3_PCIE              : integer := 0;
    -- Set the following parameter to 1 to include the SOFT_RESET control
    -- register. This is used to control SOFT_* outputs.
    -- These outputs can be used in CoreResetP to directly control its
    -- various reset outputs.
    ENABLE_SOFT_RESETS      : integer := 0;
    -- Set the DEVICE_090 parameter to 1 when an 090/7500 device is being
    -- targeted, otherwise set to 0.
    -- When DEVICE_090 = 1, the address space normally allocated to
    -- SERDESIF_0 and SERDESIF_1 is allocated to SERDESIF_0 only. This is
    -- to support the SERDES interface used in the 090/7500 device which
    -- contains two PCIe controllers. The extra address space allows the
    -- two PCIe controllers to be accessed.
    -- (An extra configuration address bit is taken into the SERDES
    --  interface on an 090/7500 device. The SERDES block used in this
    --  device gets address bits [14:2] whereas the SERDES blocks in other
    --  devices receive address bits [13:2].)
    DEVICE_090              : integer := 0
    );
    port(
    -- APB_2 interface
    FIC_2_APB_M_PRESET_N    : in  std_logic;
    FIC_2_APB_M_PCLK        : in  std_logic;
    FIC_2_APB_M_PSEL        : in  std_logic;
    FIC_2_APB_M_PENABLE     : in  std_logic;
    FIC_2_APB_M_PWRITE      : in  std_logic;
    FIC_2_APB_M_PADDR       : in  std_logic_vector(16 downto 2);
    FIC_2_APB_M_PWDATA      : in  std_logic_vector(31 downto 0);
    FIC_2_APB_M_PRDATA      : out std_logic_vector(31 downto 0);
    FIC_2_APB_M_PREADY      : out std_logic;
    FIC_2_APB_M_PSLVERR     : out std_logic;
    -- Clock and reset to slaves
    APB_S_PCLK              : out std_logic;
    APB_S_PRESET_N          : out std_logic;
    -- MDDR
    MDDR_PSEL               : out std_logic;
    MDDR_PENABLE            : out std_logic;
    MDDR_PWRITE             : out std_logic;
    MDDR_PADDR              : out std_logic_vector(15 downto 2);
    MDDR_PWDATA             : out std_logic_vector(31 downto 0);
    MDDR_PRDATA             : in  std_logic_vector(31 downto 0);
    MDDR_PREADY             : in  std_logic;
    MDDR_PSLVERR            : in  std_logic;
    -- FDDR
    FDDR_PSEL               : out std_logic;
    FDDR_PENABLE            : out std_logic;
    FDDR_PWRITE             : out std_logic;
    FDDR_PADDR              : out std_logic_vector(15 downto 2);
    FDDR_PWDATA             : out std_logic_vector(31 downto 0);
    FDDR_PRDATA             : in  std_logic_vector(31 downto 0);
    FDDR_PREADY             : in  std_logic;
    FDDR_PSLVERR            : in  std_logic;
    -- SERDESIF_0
    SDIF0_PSEL              : out std_logic;
    SDIF0_PENABLE           : out std_logic;
    SDIF0_PWRITE            : out std_logic;
    SDIF0_PADDR             : out std_logic_vector(15 downto 2);
    SDIF0_PWDATA            : out std_logic_vector(31 downto 0);
    SDIF0_PRDATA            : in  std_logic_vector(31 downto 0);
    SDIF0_PREADY            : in  std_logic;
    SDIF0_PSLVERR           : in  std_logic;
    -- SERDESIF_1
    SDIF1_PSEL              : out std_logic;
    SDIF1_PENABLE           : out std_logic;
    SDIF1_PWRITE            : out std_logic;
    SDIF1_PADDR             : out std_logic_vector(15 downto 2);
    SDIF1_PWDATA            : out std_logic_vector(31 downto 0);
    SDIF1_PRDATA            : in  std_logic_vector(31 downto 0);
    SDIF1_PREADY            : in  std_logic;
    SDIF1_PSLVERR           : in  std_logic;
    -- SERDESIF_2
    SDIF2_PSEL              : out std_logic;
    SDIF2_PENABLE           : out std_logic;
    SDIF2_PWRITE            : out std_logic;
    SDIF2_PADDR             : out std_logic_vector(15 downto 2);
    SDIF2_PWDATA            : out std_logic_vector(31 downto 0);
    SDIF2_PRDATA            : in  std_logic_vector(31 downto 0);
    SDIF2_PREADY            : in  std_logic;
    SDIF2_PSLVERR           : in  std_logic;
    -- SERDESIF_3
    SDIF3_PSEL              : out std_logic;
    SDIF3_PENABLE           : out std_logic;
    SDIF3_PWRITE            : out std_logic;
    SDIF3_PADDR             : out std_logic_vector(15 downto 2);
    SDIF3_PWDATA            : out std_logic_vector(31 downto 0);
    SDIF3_PRDATA            : in  std_logic_vector(31 downto 0);
    SDIF3_PREADY            : in  std_logic;
    SDIF3_PSLVERR           : in  std_logic;
    -- Some SDIF APB port signals are replicated for connection to
    -- CoreResetP. The PRDATA buses from the SDIF blocks carry status
    -- information when a read is not in progress, and this status info
    -- is used within CoreResetP.
    R_SDIF0_PSEL            : out std_logic;
    R_SDIF0_PWRITE          : out std_logic;
    R_SDIF0_PRDATA          : out std_logic_vector(31 downto 0);
    R_SDIF1_PSEL            : out std_logic;
    R_SDIF1_PWRITE          : out std_logic;
    R_SDIF1_PRDATA          : out std_logic_vector(31 downto 0);
    R_SDIF2_PSEL            : out std_logic;
    R_SDIF2_PWRITE          : out std_logic;
    R_SDIF2_PRDATA          : out std_logic_vector(31 downto 0);
    R_SDIF3_PSEL            : out std_logic;
    R_SDIF3_PWRITE          : out std_logic;
    R_SDIF3_PRDATA          : out std_logic_vector(31 downto 0);

    CONFIG1_DONE            : out std_logic;
    SDIF_RELEASED           : in  std_logic;
    CONFIG2_DONE            : out std_logic;
    INIT_DONE               : in  std_logic;

    SOFT_EXT_RESET_OUT              : out std_logic;
    SOFT_RESET_F2M                  : out std_logic;
    SOFT_M3_RESET                   : out std_logic;
    SOFT_MDDR_DDR_AXI_S_CORE_RESET  : out std_logic;
    SOFT_FDDR_CORE_RESET            : out std_logic;
    SOFT_SDIF0_PHY_RESET            : out std_logic;
    SOFT_SDIF0_CORE_RESET           : out std_logic;
    SOFT_SDIF1_PHY_RESET            : out std_logic;
    SOFT_SDIF1_CORE_RESET           : out std_logic;
    SOFT_SDIF2_PHY_RESET            : out std_logic;
    SOFT_SDIF2_CORE_RESET           : out std_logic;
    SOFT_SDIF3_PHY_RESET            : out std_logic;
    SOFT_SDIF3_CORE_RESET           : out std_logic;
    -- The following two signals are used when targeting an 090/7500 device
    -- which has two PCIe controllers within a single SERDES interface
    -- block.
    SOFT_SDIF0_0_CORE_RESET         : out std_logic;
    SOFT_SDIF0_1_CORE_RESET         : out std_logic
    );
end CoreConfigP;

architecture rtl of CoreConfigP is

    -- Parameters for state machine states
    constant S0 : std_logic_vector(1 downto 0) := "00";
    constant S1 : std_logic_vector(1 downto 0) := "01";
    constant S2 : std_logic_vector(1 downto 0) := "10";

    -- A read only version register is used to inform software of the
    -- capabilities of this core. For example, versions prior to 7.0
    -- did not have an SDIF_RELEASED status bit, so any software that polls
    -- this bit would hang if used with an earlier version of the core.
    constant VERSION_MAJOR : integer := 7;
    constant VERSION_MINOR : integer := 0;

    signal VERSION_MAJOR_VECTOR     : std_logic_vector(15 downto 0);
    signal VERSION_MINOR_VECTOR     : std_logic_vector(15 downto 0);

    signal state                    : std_logic_vector(1 downto 0);
    signal next_state               : std_logic_vector(1 downto 0);
    signal next_FIC_2_APB_M_PREADY  : std_logic;
    signal psel                     : std_logic;
    signal d_psel                   : std_logic;
    signal d_penable                : std_logic;
    signal pready                   : std_logic;
    signal pslverr                  : std_logic;
    signal prdata                   : std_logic_vector(31 downto 0);
    signal int_prdata               : std_logic_vector(31 downto 0);
    signal int_psel                 : std_logic;
    signal control_reg_1            : std_logic_vector(1 downto 0);
    signal soft_reset_reg           : std_logic_vector(16 downto 0);
    signal paddr                    : std_logic_vector(16 downto 2);
    signal pwdata                   : std_logic_vector(31 downto 0);
    signal pwrite                   : std_logic;
    signal mddr_sel                 : std_logic;
    signal fddr_sel                 : std_logic;
    signal sdif0_sel                : std_logic;
    signal sdif1_sel                : std_logic;
    signal sdif2_sel                : std_logic;
    signal sdif3_sel                : std_logic;
    signal int_sel                  : std_logic;
    signal INIT_DONE_q1             : std_logic;
    signal INIT_DONE_q2             : std_logic;
    signal SDIF_RELEASED_q1         : std_logic;
    signal SDIF_RELEASED_q2         : std_logic;

    signal FIC_2_APB_M_PRDATA_0     : std_logic_vector(31 downto 0);
    signal FIC_2_APB_M_PREADY_0     : std_logic;
    signal FIC_2_APB_M_PSLVERR_0    : std_logic;
    signal APB_S_PCLK_0             : std_logic;
    signal APB_S_PRESET_N_0         : std_logic;
    signal MDDR_PSEL_0              : std_logic;
    signal MDDR_PENABLE_0           : std_logic;
    signal MDDR_PWRITE_0            : std_logic;
    signal MDDR_PADDR_0             : std_logic_vector(15 downto 2);
    signal MDDR_PWDATA_0            : std_logic_vector(31 downto 0);
    signal FDDR_PSEL_0              : std_logic;
    signal FDDR_PENABLE_0           : std_logic;
    signal FDDR_PWRITE_0            : std_logic;
    signal FDDR_PADDR_0             : std_logic_vector(15 downto 2);
    signal FDDR_PWDATA_0            : std_logic_vector(31 downto 0);
    signal SDIF0_PSEL_0             : std_logic;
    signal SDIF0_PENABLE_0          : std_logic;
    signal SDIF0_PWRITE_0           : std_logic;
    signal SDIF0_PADDR_0            : std_logic_vector(15 downto 2);
    signal SDIF0_PWDATA_0           : std_logic_vector(31 downto 0);
    signal SDIF1_PSEL_0             : std_logic;
    signal SDIF1_PENABLE_0          : std_logic;
    signal SDIF1_PWRITE_0           : std_logic;
    signal SDIF1_PADDR_0            : std_logic_vector(15 downto 2);
    signal SDIF1_PWDATA_0           : std_logic_vector(31 downto 0);
    signal SDIF2_PSEL_0             : std_logic;
    signal SDIF2_PENABLE_0          : std_logic;
    signal SDIF2_PWRITE_0           : std_logic;
    signal SDIF2_PADDR_0            : std_logic_vector(15 downto 2);
    signal SDIF2_PWDATA_0           : std_logic_vector(31 downto 0);
    signal SDIF3_PSEL_0             : std_logic;
    signal SDIF3_PENABLE_0          : std_logic;
    signal SDIF3_PWRITE_0           : std_logic;
    signal SDIF3_PADDR_0            : std_logic_vector(15 downto 2);
    signal SDIF3_PWDATA_0           : std_logic_vector(31 downto 0);

    signal CONFIG1_DONE_0           : std_logic;
    signal CONFIG2_DONE_0           : std_logic;

begin

    VERSION_MAJOR_VECTOR <= std_logic_vector(to_unsigned(VERSION_MAJOR, 16));
    VERSION_MINOR_VECTOR <= std_logic_vector(to_unsigned(VERSION_MINOR, 16));

    FIC_2_APB_M_PRDATA  <= FIC_2_APB_M_PRDATA_0;
    FIC_2_APB_M_PREADY  <= FIC_2_APB_M_PREADY_0;
    FIC_2_APB_M_PSLVERR <= FIC_2_APB_M_PSLVERR_0;
    APB_S_PCLK          <= APB_S_PCLK_0;
    APB_S_PRESET_N      <= APB_S_PRESET_N_0;
    MDDR_PSEL           <= MDDR_PSEL_0;
    MDDR_PENABLE        <= MDDR_PENABLE_0;
    MDDR_PWRITE         <= MDDR_PWRITE_0;
    MDDR_PADDR          <= MDDR_PADDR_0;
    MDDR_PWDATA         <= MDDR_PWDATA_0;
    FDDR_PSEL           <= FDDR_PSEL_0;
    FDDR_PENABLE        <= FDDR_PENABLE_0;
    FDDR_PWRITE         <= FDDR_PWRITE_0;
    FDDR_PADDR          <= FDDR_PADDR_0;
    FDDR_PWDATA         <= FDDR_PWDATA_0;
    SDIF0_PSEL          <= SDIF0_PSEL_0;
    SDIF0_PENABLE       <= SDIF0_PENABLE_0;
    SDIF0_PWRITE        <= SDIF0_PWRITE_0;
    SDIF0_PADDR         <= SDIF0_PADDR_0;
    SDIF0_PWDATA        <= SDIF0_PWDATA_0;
    SDIF1_PSEL          <= SDIF1_PSEL_0;
    SDIF1_PENABLE       <= SDIF1_PENABLE_0;
    SDIF1_PWRITE        <= SDIF1_PWRITE_0;
    SDIF1_PADDR         <= SDIF1_PADDR_0;
    SDIF1_PWDATA        <= SDIF1_PWDATA_0;
    SDIF2_PSEL          <= SDIF2_PSEL_0;
    SDIF2_PENABLE       <= SDIF2_PENABLE_0;
    SDIF2_PWRITE        <= SDIF2_PWRITE_0;
    SDIF2_PADDR         <= SDIF2_PADDR_0;
    SDIF2_PWDATA        <= SDIF2_PWDATA_0;
    SDIF3_PSEL          <= SDIF3_PSEL_0;
    SDIF3_PENABLE       <= SDIF3_PENABLE_0;
    SDIF3_PWRITE        <= SDIF3_PWRITE_0;
    SDIF3_PADDR         <= SDIF3_PADDR_0;
    SDIF3_PWDATA        <= SDIF3_PWDATA_0;
    CONFIG1_DONE        <= CONFIG1_DONE_0;
    CONFIG2_DONE        <= CONFIG2_DONE_0;

    -----------------------------------------------------------------------
    -- SDIF related APB signals for connection to CoreResetP.
    -- The PRDATA buses from the SDIF blocks carry status information when
    -- a read is not in progress, and this status info is used within
    -- CoreResetP.
    -----------------------------------------------------------------------
    R_SDIF0_PSEL        <= SDIF0_PSEL_0;
    R_SDIF0_PWRITE      <= SDIF0_PWRITE_0;
    R_SDIF0_PRDATA      <= SDIF0_PRDATA;
    R_SDIF1_PSEL        <= SDIF1_PSEL_0;
    R_SDIF1_PWRITE      <= SDIF1_PWRITE_0;
    R_SDIF1_PRDATA      <= SDIF1_PRDATA;
    R_SDIF2_PSEL        <= SDIF2_PSEL_0;
    R_SDIF2_PWRITE      <= SDIF2_PWRITE_0;
    R_SDIF2_PRDATA      <= SDIF2_PRDATA;
    R_SDIF3_PSEL        <= SDIF3_PSEL_0;
    R_SDIF3_PWRITE      <= SDIF3_PWRITE_0;
    R_SDIF3_PRDATA      <= SDIF3_PRDATA;

    -----------------------------------------------------------------------
    -- Drive APB_S_PCLK signal to slaves.
    -----------------------------------------------------------------------
    process (FIC_2_APB_M_PCLK)
    begin
        APB_S_PCLK_0 <= FIC_2_APB_M_PCLK;
    end process;

    -----------------------------------------------------------------------
    -- Drive APB_S_PRESET_N signal to slaves.
    -----------------------------------------------------------------------
    process (FIC_2_APB_M_PRESET_N)
    begin
        APB_S_PRESET_N_0 <= FIC_2_APB_M_PRESET_N;
    end process;

    -----------------------------------------------------------------------
    -- PADDR, PWRITE and PWDATA from master registered before passing on to
    -- slaves.
    -----------------------------------------------------------------------
    process (FIC_2_APB_M_PCLK, FIC_2_APB_M_PRESET_N)
    begin
        if (FIC_2_APB_M_PRESET_N = '0') then
            paddr  <= "000000000000000";
            pwrite <= '0';
            pwdata <= "00000000000000000000000000000000";
        elsif (FIC_2_APB_M_PCLK'event and FIC_2_APB_M_PCLK = '1') then
            if (state = S0) then
                paddr  <= FIC_2_APB_M_PADDR;
                pwrite <= FIC_2_APB_M_PWRITE;
                pwdata <= FIC_2_APB_M_PWDATA;
            end if;
        end if;
    end process;

    process (paddr, pwrite, pwdata)
    begin
        MDDR_PADDR_0   <= paddr(15 downto 2);
        FDDR_PADDR_0   <= paddr(15 downto 2);
        SDIF0_PADDR_0  <= paddr(15 downto 2);
        SDIF1_PADDR_0  <= paddr(15 downto 2);
        SDIF2_PADDR_0  <= paddr(15 downto 2);
        SDIF3_PADDR_0  <= paddr(15 downto 2);
        MDDR_PWRITE_0  <= pwrite;
        FDDR_PWRITE_0  <= pwrite;
        SDIF0_PWRITE_0 <= pwrite;
        SDIF1_PWRITE_0 <= pwrite;
        SDIF2_PWRITE_0 <= pwrite;
        SDIF3_PWRITE_0 <= pwrite;
        MDDR_PWDATA_0  <= pwdata;
        FDDR_PWDATA_0  <= pwdata;
        SDIF0_PWDATA_0 <= pwdata;
        SDIF1_PWDATA_0 <= pwdata;
        SDIF2_PWDATA_0 <= pwdata;
        SDIF3_PWDATA_0 <= pwdata;
    end process;

    -----------------------------------------------------------------------
    -- Decode master address to produce slave selects
    -----------------------------------------------------------------------

    --                                                  111111     111111
    --                                                  54321098   54321098
    -- --------------------------------------------------------------------
    -- 090/7500 device
    -- ---------------
    -- MDDR         0x40020000 - 0x40020FFF             00000000 - 00001111
    -- FDDR         0x40021000 - 0x40021FFF             00010000 - 00011111
    -- Internal     0x40022000 - 0x40023FFF             00100000 - 00111111
    -- (Unused)     0x40024000 - 0x40027FFF             01000000 - 01111111
    -- SERDESIF_0   0x40028000 - 0x4002FFFF (32 KB)     10000000 - 11111111
    --
    -- Devices other than 090/7500 or 150/12000
    -- ----------------------------------------
    -- MDDR         0x40020000 - 0x40020FFF             00000000 - 00001111
    -- FDDR         0x40021000 - 0x40021FFF             00010000 - 00011111
    -- Internal     0x40022000 - 0x40023FFF             00100000 - 00111111
    -- (Unused)     0x40024000 - 0x40027FFF             01000000 - 01111111
    -- SERDESIF_0   0x40028000 - 0x4002BFFF (16 KB)     10000000 - 10111111
    -- SERDESIF_1   0x4002C000 - 0x4002FFFF (16 KB)     11000000 - 11111111
    --
    -- 150/12000 device
    -- ----------------
    -- MDDR         0x40020000 - 0x40020FFF             00000000 - 00001111
    -- FDDR         0x40021000 - 0x40021FFF             00010000 - 00011111
    -- Internal     0x40022000 - 0x40023FFF             00100000 - 00111111
    -- (Unused)     0x40024000 - 0x40027FFF             01000000 - 01111111
    -- SERDESIF_0   0x40028000 - 0x4002BFFF (16 KB)     10000000 - 10111111
    -- SERDESIF_1   0x4002C000 - 0x4002FFFF (16 KB)     11000000 - 11111111
    -- SERDESIF_2   0x40030000 - 0x40033FFF (16 KB)    100000000 -100111111
    -- SERDESIF_3   0x40034000 - 0x40037FFF (16 KB)    101000000 -101111111
    --
    --
    -- Note: System registers (not particular to this block) begin
    --       at address 0x40038000 in the system memory map.
    --
    -- Note: Aliases of MDDR, FDDR and internal registers will appear
    --       in the address space labelled Unused above.
    -- --------------------------------------------------------------------
    process (paddr)
    begin
        mddr_sel  <= '0';
        fddr_sel  <= '0';
        int_sel   <= '0';
        sdif0_sel <= '0';
        sdif1_sel <= '0';
        sdif2_sel <= '0';
        sdif3_sel <= '0';
        if (paddr(16 downto 15) = "10") then
            if (paddr(14) = '1') then
                sdif3_sel <= '1';
            else
                sdif2_sel <= '1';
            end if;
       else
            if (paddr(15) = '1') then
                if (DEVICE_090 = 1) then
                    sdif0_sel <= '1';
                else
                    if (paddr(14) = '1') then
                        sdif1_sel <= '1';
                    else
                        sdif0_sel <= '1';
                    end if;
                end if;
            else
                if (paddr(13) = '1') then
                    int_sel <= '1';
                else
                    if (paddr(12) = '1') then
                        fddr_sel <= '1';
                    else
                        mddr_sel <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;

    process (psel, mddr_sel, fddr_sel, sdif0_sel, sdif1_sel, sdif2_sel, sdif3_sel, int_sel)
    begin
        if (psel = '1') then
            MDDR_PSEL_0  <= mddr_sel;
            FDDR_PSEL_0  <= fddr_sel;
            SDIF0_PSEL_0 <= sdif0_sel;
            SDIF1_PSEL_0 <= sdif1_sel;
            SDIF2_PSEL_0 <= sdif2_sel;
            SDIF3_PSEL_0 <= sdif3_sel;
            int_psel     <= int_sel;
        else
            MDDR_PSEL_0  <= '0';
            FDDR_PSEL_0  <= '0';
            SDIF0_PSEL_0 <= '0';
            SDIF1_PSEL_0 <= '0';
            SDIF2_PSEL_0 <= '0';
            SDIF3_PSEL_0 <= '0';
            int_psel     <= '0';
        end if;
    end process;

    -----------------------------------------------------------------------
    -- State machine
    -----------------------------------------------------------------------
    process (
        state,
        FIC_2_APB_M_PREADY_0,
        FIC_2_APB_M_PSEL,
        FIC_2_APB_M_PENABLE,
        pready
    )
    begin
        next_state <= state;
        next_FIC_2_APB_M_PREADY <= FIC_2_APB_M_PREADY_0;
        d_psel <= '0';
        d_penable <= '0';
        case state is
            when S0 =>
                if (FIC_2_APB_M_PSEL = '1' and FIC_2_APB_M_PENABLE = '0') then
                    next_state <= S1;
                    next_FIC_2_APB_M_PREADY <= '0';
                end if;
            when S1 =>
                next_state <= S2;
                d_psel <= '1';
            when S2 =>
                d_psel <= '1';
                d_penable <= '1';
                if (pready = '1') then
                    next_FIC_2_APB_M_PREADY <= '1';
                    next_state <= S0;
                end if;
            when others =>
                next_state <= S0;
        end case;
    end process;

    process (FIC_2_APB_M_PCLK, FIC_2_APB_M_PRESET_N)
    begin
        if (FIC_2_APB_M_PRESET_N = '0') then
            state <= S0;
            FIC_2_APB_M_PREADY_0 <= '1';
        elsif (FIC_2_APB_M_PCLK'event and FIC_2_APB_M_PCLK = '1') then
            state <= next_state;
            FIC_2_APB_M_PREADY_0 <= next_FIC_2_APB_M_PREADY;
        end if;
    end process;

    process (FIC_2_APB_M_PCLK, FIC_2_APB_M_PRESET_N)
    begin
        if (FIC_2_APB_M_PRESET_N = '0') then
            psel <= '0';
            MDDR_PENABLE_0  <= '0';
            FDDR_PENABLE_0  <= '0';
            SDIF0_PENABLE_0 <= '0';
            SDIF1_PENABLE_0 <= '0';
            SDIF2_PENABLE_0 <= '0';
            SDIF3_PENABLE_0 <= '0';
        elsif (FIC_2_APB_M_PCLK'event and FIC_2_APB_M_PCLK = '0') then
            psel <= d_psel;
            MDDR_PENABLE_0  <= d_penable and mddr_sel;
            FDDR_PENABLE_0  <= d_penable and fddr_sel;
            SDIF0_PENABLE_0 <= d_penable and sdif0_sel;
            SDIF1_PENABLE_0 <= d_penable and sdif1_sel;
            SDIF2_PENABLE_0 <= d_penable and sdif2_sel;
            SDIF3_PENABLE_0 <= d_penable and sdif3_sel;
        end if;
    end process;
    -----------------------------------------------------------------------

    -----------------------------------------------------------------------
    -- Mux signals from slaves.
    -----------------------------------------------------------------------
    process (
        MDDR_PSEL_0,
        FDDR_PSEL_0,
        SDIF0_PSEL_0,
        SDIF1_PSEL_0,
        SDIF2_PSEL_0,
        SDIF3_PSEL_0,
        int_psel,
        MDDR_PRDATA,
        MDDR_PSLVERR,
        MDDR_PREADY,
        FDDR_PRDATA,
        FDDR_PSLVERR,
        FDDR_PREADY,
        SDIF0_PRDATA,
        SDIF0_PSLVERR,
        SDIF0_PREADY,
        SDIF1_PRDATA,
        SDIF1_PSLVERR,
        SDIF1_PREADY,
        SDIF2_PRDATA,
        SDIF2_PSLVERR,
        SDIF2_PREADY,
        SDIF3_PRDATA,
        SDIF3_PSLVERR,
        SDIF3_PREADY,
        int_prdata
    )
    variable temp_sel : std_logic_vector(6 downto 0);
    begin
        temp_sel := MDDR_PSEL_0 & FDDR_PSEL_0 & SDIF0_PSEL_0 & SDIF1_PSEL_0 & SDIF2_PSEL_0 & SDIF3_PSEL_0 & int_psel;
        if (std_match(temp_sel, "1------")) then
            prdata  <= MDDR_PRDATA;
            pslverr <= MDDR_PSLVERR;
            pready  <= MDDR_PREADY;
        elsif (std_match(temp_sel, "-1-----")) then
            prdata  <= FDDR_PRDATA;
            pslverr <= FDDR_PSLVERR;
            pready  <= FDDR_PREADY;
        elsif (std_match(temp_sel, "--1----")) then
            prdata  <= SDIF0_PRDATA;
            pslverr <= SDIF0_PSLVERR;
            pready  <= SDIF0_PREADY;
        elsif (std_match(temp_sel, "---1---")) then
            prdata  <= SDIF1_PRDATA;
            pslverr <= SDIF1_PSLVERR;
            pready  <= SDIF1_PREADY;
        elsif (std_match(temp_sel, "----1--")) then
            prdata  <= SDIF2_PRDATA;
            pslverr <= SDIF2_PSLVERR;
            pready  <= SDIF2_PREADY;
        elsif (std_match(temp_sel, "-----1-")) then
            prdata  <= SDIF3_PRDATA;
            pslverr <= SDIF3_PSLVERR;
            pready  <= SDIF3_PREADY;
        elsif (std_match(temp_sel, "------1")) then
            prdata  <= int_prdata;
            pslverr <= '0';
            pready  <= '1';
        else
            prdata  <= int_prdata;
            pslverr <= '0';
            pready  <= '1';
        end if;
    end process;

    -----------------------------------------------------------------------
    -- Register read data from slaves.
    -----------------------------------------------------------------------
    process (FIC_2_APB_M_PCLK, FIC_2_APB_M_PRESET_N)
    begin
        if (FIC_2_APB_M_PRESET_N = '0') then
            FIC_2_APB_M_PRDATA_0  <= "00000000000000000000000000000000";
            FIC_2_APB_M_PSLVERR_0 <= '0';
        elsif (FIC_2_APB_M_PCLK'event and FIC_2_APB_M_PCLK = '1') then
            if (state = S2) then
                FIC_2_APB_M_PRDATA_0  <= prdata;
                FIC_2_APB_M_PSLVERR_0 <= pslverr;
            end if;
        end if;
    end process;

    -----------------------------------------------------------------------
    -- Synchronize INIT_DONE input to FIC_2_APB_M_PCLK domain.
    -----------------------------------------------------------------------
    process (FIC_2_APB_M_PCLK, FIC_2_APB_M_PRESET_N)
    begin
        if (FIC_2_APB_M_PRESET_N = '0') then
            INIT_DONE_q1 <= '0';
            INIT_DONE_q2 <= '0';
        elsif (FIC_2_APB_M_PCLK'event and FIC_2_APB_M_PCLK = '1') then
            INIT_DONE_q1 <= INIT_DONE;
            INIT_DONE_q2 <= INIT_DONE_q1;
        end if;
    end process;

    -----------------------------------------------------------------------
    -- Synchronize INIT_DONE input to FIC_2_APB_M_PCLK domain.
    -----------------------------------------------------------------------
    process (FIC_2_APB_M_PCLK, FIC_2_APB_M_PRESET_N)
    begin
        if (FIC_2_APB_M_PRESET_N = '0') then
            SDIF_RELEASED_q1 <= '0';
            SDIF_RELEASED_q2 <= '0';
        elsif (FIC_2_APB_M_PCLK'event and FIC_2_APB_M_PCLK = '1') then
            SDIF_RELEASED_q1 <= SDIF_RELEASED;
            SDIF_RELEASED_q2 <= SDIF_RELEASED_q1;
        end if;
    end process;

    -----------------------------------------------------------------------
    -- Internal registers
    -----------------------------------------------------------------------
    -- Control register 1
    --    [0] = CONFIG1_DONE
    --    [1] = CONFIG2_DONE
    process (FIC_2_APB_M_PCLK, FIC_2_APB_M_PRESET_N)
    begin
        if (FIC_2_APB_M_PRESET_N = '0') then
            control_reg_1 <= "00";
        elsif (FIC_2_APB_M_PCLK'event and FIC_2_APB_M_PCLK = '1') then
            if (int_psel = '1' and FIC_2_APB_M_PENABLE = '1' and FIC_2_APB_M_PWRITE = '1'
                and FIC_2_APB_M_PADDR(4 downto 2) = "000"
            ) then
                control_reg_1 <= FIC_2_APB_M_PWDATA(1 downto 0);
            end if;
        end if;
    end process;
    process (control_reg_1)
    begin
        CONFIG1_DONE_0 <= control_reg_1(0);
        CONFIG2_DONE_0 <= control_reg_1(1);
    end process;

    -- Soft reset control register
    process (FIC_2_APB_M_PCLK, FIC_2_APB_M_PRESET_N)
    begin
        if (FIC_2_APB_M_PRESET_N = '0') then
            soft_reset_reg <= (others => '0');
        elsif (FIC_2_APB_M_PCLK'event and FIC_2_APB_M_PCLK = '1') then
            if (int_psel = '1' and FIC_2_APB_M_PENABLE = '1' and FIC_2_APB_M_PWRITE = '1'
                and FIC_2_APB_M_PADDR(4 downto 2) = "100"
            ) then
                soft_reset_reg <= FIC_2_APB_M_PWDATA(16 downto 0);
            end if;
        end if;
    end process;
    process (soft_reset_reg)
    begin
        SOFT_EXT_RESET_OUT             <= soft_reset_reg( 0);
        SOFT_RESET_F2M                 <= soft_reset_reg( 1);
        SOFT_M3_RESET                  <= soft_reset_reg( 2);
        SOFT_MDDR_DDR_AXI_S_CORE_RESET <= soft_reset_reg( 3);
        --SOFT_FAB_RESET                 <= soft_reset_reg( 4);
        --SOFT_USER_FAB_RESET            <= soft_reset_reg( 5);
        SOFT_FDDR_CORE_RESET           <= soft_reset_reg( 6);
        SOFT_SDIF0_PHY_RESET           <= soft_reset_reg( 7);
        SOFT_SDIF0_CORE_RESET          <= soft_reset_reg( 8);
        SOFT_SDIF1_PHY_RESET           <= soft_reset_reg( 9);
        SOFT_SDIF1_CORE_RESET          <= soft_reset_reg(10);
        SOFT_SDIF2_PHY_RESET           <= soft_reset_reg(11);
        SOFT_SDIF2_CORE_RESET          <= soft_reset_reg(12);
        SOFT_SDIF3_PHY_RESET           <= soft_reset_reg(13);
        SOFT_SDIF3_CORE_RESET          <= soft_reset_reg(14);
        -- The following two signals are used when targeting an 090/7500
        -- device which has two PCIe controllers within a single SERDES
        -- interface block.
        SOFT_SDIF0_0_CORE_RESET        <= soft_reset_reg(15);
        SOFT_SDIF0_1_CORE_RESET        <= soft_reset_reg(16);
    end process;

    -- Read data from internal registers
    process (FIC_2_APB_M_PADDR, control_reg_1, INIT_DONE_q2, SDIF_RELEASED_q2,
             soft_reset_reg, VERSION_MAJOR_VECTOR, VERSION_MINOR_VECTOR)
    begin
        case FIC_2_APB_M_PADDR(4 downto 2) is
            when "000" =>
                int_prdata <= "000000000000000000000000000000" & control_reg_1;
            when "001" =>
                int_prdata <= "000000000000000000000000000000" & SDIF_RELEASED_q2 & INIT_DONE_q2;
            when "010" =>
                int_prdata <= "00000000000000000000000000000000";
            when "011" =>
                int_prdata <= "00000000000000000000000000"
                               & std_logic_vector(to_unsigned(MDDR_IN_USE,  1))
                               & std_logic_vector(to_unsigned(FDDR_IN_USE,  1))
                               & std_logic_vector(to_unsigned(SDIF3_IN_USE, 1))
                               & std_logic_vector(to_unsigned(SDIF2_IN_USE, 1))
                               & std_logic_vector(to_unsigned(SDIF1_IN_USE, 1))
                               & std_logic_vector(to_unsigned(SDIF0_IN_USE, 1));
            when "100" =>
                int_prdata <= "000000000000000" & soft_reset_reg;
            when "101" =>
                int_prdata <=   VERSION_MAJOR_VECTOR    -- [31:16]
                              & VERSION_MINOR_VECTOR;   -- [15: 0]
            when others =>
                int_prdata <= "00000000000000000000000000000000";
        end case;
    end process;

end rtl;
