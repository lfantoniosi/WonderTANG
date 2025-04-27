library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
--    use work.vdp_package.all;

entity ese_mixer is
    port(
        -- Clock, Reset ports
        clk21m          : in    std_logic;                                      -- VDP Clock ... 21.48MHz
        reset           : in    std_logic;
        clkena          : in    std_logic;
        PsgAmp          : in    std_logic_vector(  7 downto 0 );
        KeyClick        : in    std_logic;
        Scc1AmpL        : in    std_logic_vector( 14 downto 0 );
        OpllAmp         : in    std_logic_vector(  9 downto 0 );
        DACout          : out   std_logic;
        audio_sample    : out   std_logic_vector( 15 downto 0)
    );
end ese_mixer;

architecture RTL of ese_mixer is

    component scc_mix_mul
        port(
            a           : in    std_logic_vector( 15 downto 0 );        -- 16bits signed
            b           : in    std_logic_vector(  2 downto 0 );        --  3bits unsigned
            c           : out   std_logic_vector( 18 downto 0 )         -- 19bits signed
        );
    end component;


    --  low pass filter 1
    component lpf1
        generic(
            msbi    : integer
        );
        port(
            clk21m  : in    std_logic;
            reset   : in    std_logic;
            clkena  : in    std_logic;
            idata   : in    std_logic_vector( msbi downto 0 );
            odata   : out   std_logic_vector( msbi downto 0 )
        );
    end component;

    --  low pass filter 2
    component lpf2
        generic(
            msbi    : integer
        );
        port(
            clk21m  : in    std_logic;
            reset   : in    std_logic;
            clkena  : in    std_logic;
            idata   : in    std_logic_vector( msbi downto 0 );
            odata   : out   std_logic_vector( msbi downto 0 )
        );
    end component;

    --  sound interpolation
    component interpo
        generic(
            msbi    : integer
        );
        port(
            clk21m  : in    std_logic;
            reset   : in    std_logic;
            clkena  : in    std_logic;
            idata   : in    std_logic_vector( msbi downto 0 );
            odata   : out   std_logic_vector( msbi downto 0 )
        );
    end component;

    component esepwm
        generic(
            msbi    : integer
        );
        port(
            clk     : in    std_logic;
            reset   : in    std_logic;
            DACin   : in    std_logic_vector( msbi downto 0 );
            DACout  : out   std_logic
        );
    end component;

    -- Sound signals
    constant DAC_msbi       : integer := 13;
    signal  DACin           : std_logic_vector(DAC_msbi downto 0);

    signal  OpllVol         : std_logic_vector(  2 downto 0 ) := "010";
    signal  SccVol          : std_logic_vector(  2 downto 0 ) := "010";
    signal  PsgVol          : std_logic_vector(  2 downto 0 ) := "010";
    signal  MstrVol         : std_logic_vector(  2 downto 0 ) := "000";

    signal  pSltSndL        : std_logic_vector(  5 downto 0 );
    signal  pSltSndR        : std_logic_vector(  5 downto 0 );
    signal  pSltSound       : std_logic_vector(  5 downto 0 );


    -- Mixer
    signal  ff_prepsg       : std_logic_vector(  8 downto 0 );
    signal  ff_prescc       : std_logic_vector( 15 downto 0 );
    signal  ff_psg          : std_logic_vector( DACin'high + 2 downto DACin'low );
    signal  ff_scc          : std_logic_vector( DACin'high + 2 downto DACin'low );
    signal  w_scc           : std_logic_vector( 18 downto 0 );
    signal  m_SccVol        : std_logic_vector(  2 downto 0 );
    signal  ff_opll         : std_logic_vector( DACin'high + 2 downto DACin'low );
    signal  ff_psg_offset   : std_logic_vector( DACin'high + 2 downto DACin'low );
    signal  ff_scc_offset   : std_logic_vector( DACin'high + 2 downto DACin'low );
    signal  ff_pre_dacin    : std_logic_vector( DACin'high + 2 downto DACin'low );
    constant c_opll_offset  : std_logic_vector( DACin'high + 2 downto DACin'low ) := ( ff_pre_dacin'high => '1', others => '0' );
    constant c_opll_zero    : std_logic_vector( OpllAmp'range ) := ( OpllAmp'high => '1', others => '0' );

    -- Sound output filter
    signal  lpf1_wave       : std_logic_vector( DACin'high downto 0 );
    signal  lpf5_wave       : std_logic_vector( DACin'high downto 0 );
--  signal  ff_lpf_div      : std_logic_vector( 3 downto 0 );                       -- sccic
--  signal  w_lpf2ena       : std_logic;                                            -- sccic

begin

    -- mixer (pipe lined)
    u_mul: scc_mix_mul
    port map(
        a   => ff_prescc    ,               -- 16bits signed
        b   => m_SccVol     ,               --  3bits unsigned
        c   => w_scc                        -- 19bits signed
    );

    process( clk21m )
        constant h_ramp     : integer := -1;                        -- h_ramp selector -4 to 0 <= lv1-3, lv2-4, lv3-5, lv4-6 (in use), lv5-7
        constant m_ramp     : integer :=  2;                        -- m_ramp selector -1 to 3 <= lv1-3, lv2-4, lv3-5, lv4-6 (in use), lv5-7
        constant l_ramp     : integer :=  6;                        -- l_ramp <= level 1-7 (steps 3, 4, 5, 6, 7, 8, 9)
        constant h_thrd     : integer := 12;                        -- h_ramp threshold (steps 13, 14, 15)
        constant m_thrd     : integer :=  9;                        -- m_ramp threshold (steps 10, 11, 12)
        constant x_thrd     : integer :=  1;                        -- extra threshold (PsgVol goes up one level when x_thrd = 1)
        variable c_Psg      : std_logic_vector(  3 downto  0 );     -- combine PsgVol and MstrVol
        variable c_Scc      : std_logic_vector(  3 downto  0 );     -- combine SccVol and MstrVol
        variable c_Opll     : std_logic_vector(  3 downto  0 );     -- combine OpllVol and MstrVol
        variable chPsg      : std_logic_vector( ff_prepsg'range );
        variable chOpll     : std_logic_vector( ff_pre_dacin'range );
        variable tr_pcm_vol : std_logic_vector(  2 downto  0 );
    begin
        if( clk21m'event and clk21m = '1' )then

            -- amplitude ramp of the PSG (full range)
            ff_prepsg   <= ("0" & PsgAmp) + (KeyClick & "00000");
            c_Psg       := ("1" & PsgVol) - ("0" & MstrVol);
            if( PsgVol = "000" or MstrVol = "111" )then
                ff_psg      <= (others => '0');
            elsif( c_Psg > h_thrd )then
                chPsg       := ff_prepsg;
                ff_psg      <= "0" & ("0" & (chPsg * (PsgVol - MstrVol + h_ramp + x_thrd)) + chPsg( chPsg'high - 4 downto  0 )) & "00";
            elsif( c_Psg > (m_thrd - x_thrd) )then
                chPsg       := "0" & ff_prepsg( ff_prepsg'high downto 1 );
                ff_psg      <= "0" & ("0" & (chPsg * (PsgVol - MstrVol + m_ramp + x_thrd)) + chPsg( chPsg'high - 4 downto  0 )) & "00";
            else
                chPsg       := "00" & ff_prepsg( ff_prepsg'high downto 2 );
                ff_psg      <= "0" & ("0" & (chPsg * (PsgVol - MstrVol + l_ramp + x_thrd)) + chPsg( chPsg'high - 4 downto  0 )) & "00";
            end if;

            -- amplitude ramp of the SCC-I (full range)
            ff_prescc   <= (Scc1AmpL(14) & Scc1AmpL);
            c_Scc       := ("1" & SccVol) - ("0" & MstrVol);
            if( SccVol = "000" or MstrVol = "111" )then
                m_SccVol    <= "000";
                ff_scc      <= (others => w_scc(18));
            elsif( c_Scc > h_thrd )then
                m_SccVol    <= SccVol - MstrVol + h_ramp;
                ff_scc      <= w_scc(18) & w_scc( 18 downto  4 );
            elsif( c_Scc > m_thrd )then
                m_SccVol    <= SccVol - MstrVol + m_ramp;
                ff_scc      <= w_scc(18) & w_scc(18) & w_scc( 18 downto  5 );
            else
                m_SccVol    <= SccVol - MstrVol + l_ramp;
                ff_scc      <= w_scc(18) & w_scc(18) & w_scc(18) & w_scc( 18 downto  6 );
            end if;

            -- amplitude ramp of the OPLL (full range)
            c_Opll      := ("1" & OpllVol) - ("0" & MstrVol);
            if( OpllVol = "000" or MstrVol = "111" )then
                ff_opll <= c_opll_offset;
            elsif( OpllAmp < c_opll_zero )then
                if( c_Opll > h_thrd )then
                    chOpll   := ((c_opll_zero - OpllAmp) * (OpllVol - MstrVol + h_ramp)) & "000";
                elsif( c_Opll > m_thrd )then
                    chOpll   := "0" & ((c_opll_zero - OpllAmp) * (OpllVol - MstrVol + m_ramp)) & "00";
                else
                    chOpll   := "00" & ((c_opll_zero - OpllAmp) * (OpllVol - MstrVol + l_ramp)) & "0";
                end if;
                ff_opll <= c_opll_offset - (chOpll - chOpll( chOpll'high downto  3 ));
            else
                if( c_Opll > h_thrd )then
                    chOpll   := ((OpllAmp - c_opll_zero) * (OpllVol - MstrVol + h_ramp)) & "000";
                elsif( c_Opll > m_thrd )then
                    chOpll   := "0" & ((OpllAmp - c_opll_zero) * (OpllVol - MstrVol + m_ramp)) & "00";
                else
                    chOpll   := "00" & ((OpllAmp - c_opll_zero) * (OpllVol - MstrVol + l_ramp)) & "0";
                end if;
                ff_opll <= c_opll_offset + (chOpll - chOpll( chOpll'high downto  3 ));
            end if;

        end if;
    end process;

    process( clk21m )
    begin
        if( clk21m'event and clk21m = '1' )then

            -- ff_pre_dacin assignment
            ff_pre_dacin <= (not ff_psg) + ff_scc + ff_opll;

            -- amplitude limiter
            case ff_pre_dacin( ff_pre_dacin'high downto ff_pre_dacin'high - 2 ) is
                when "100" => DACin <= ff_pre_dacin( ff_pre_dacin'high ) & ff_pre_dacin( ff_pre_dacin'high - 3 downto 0 );
                when "011" => DACin <= ff_pre_dacin( ff_pre_dacin'high ) & ff_pre_dacin( ff_pre_dacin'high - 3 downto 0 );
                when others => DACin <= (others => ff_pre_dacin( ff_pre_dacin'high ));
            end case;

        end if;
    end process;

    --  sound output lowpass filter (sccic)
--  process( reset, clk21m )
--  begin
--      if( reset = '1' )then
--          ff_lpf_div <= (others => '0');
--      elsif( clk21m'event and clk21m = '1' )then
--          if( clkena = '1' )then
--              ff_lpf_div <= ff_lpf_div + 1;
--          end if;
--      end if;
--  end process;

    u_interpo : interpo
        generic map(
            msbi    => DACin'high
        )
        port map(
            clk21m  => clk21m       ,
            reset   => reset        ,
            clkena  => clkena       ,
            idata   => DACin        ,
            odata   => lpf1_wave
        );

    audio_sample <= "00" & lpf5_wave(lpf5_wave'high downto 0) ;

    --  low pass filter
--  w_lpf2ena <= '1' when( ff_lpf_div(         0) = '1'    and clkena = '1' ) else '0';     -- sccic

    u_lpf2 : lpf2
        generic map(
            msbi    => DACin'high
        )
        port map(
            clk21m  => clk21m       ,
            reset   => reset        ,
--          clkena  => w_lpf2ena    ,   -- sccic
            clkena  => clkena       ,   -- no sccic
            idata   => lpf1_wave    ,
            odata   => lpf5_wave
        );

    U33 : esepwm
        generic map(DAC_msbi) port map(clk21m, reset, lpf5_wave, DACout);


end RTL;
