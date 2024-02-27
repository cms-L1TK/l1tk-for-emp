-- #########################################################################
-- #########################################################################
-- ###                                                                   ###
-- ###   Use of this code, whether in its current form or modified,      ###
-- ###   implies that you consent to the terms and conditions, namely:   ###
-- ###    - You acknowledge my contribution                              ###
-- ###    - This copyright notification remains intact                   ###
-- ###                                                                   ###
-- ###   Many thanks,                                                    ###
-- ###     Dr. Andrew W. Rose, Imperial College London, 2018             ###
-- ###                                                                   ###
-- #########################################################################
-- #########################################################################

-- .include ReuseableElements/PkgUtilities.vhd
-- .include ReuseableElements/DataRam.vhd in .

-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.kfout_config.ALL;

USE work.DataType.ALL;
USE work.ArrayTypes.ALL;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ENTITY kfout_router IS
  PORT(
    clk     : IN STD_LOGIC := '0'; -- The algorithm clock
    reset   : IN STD_LOGIC := '0';
    DataIn  : IN Vector;
    DataOut : OUT Vector
  );
END kfout_router;

-- -------------------------------------------------------------------------
-- Dummy Skinny Chain router, all tracks same eta sector no routing 
-- put all tracks on output stream delayed by full router latency to maintain latency in full algo

-- ARCHITECTURE rtl OF kfout_router IS
 
-- CONSTANT delay_tracks : INTEGER := 5;
 
-- SIGNAL Input          : Vector( 0 TO delay_tracks-1 ) := NullVector( delay_tracks );
 
-- BEGIN
 
-- PROCESS(clk)
-- BEGIN
--      IF( RISING_EDGE( clk ) ) THEN
--       Input <= DataIn( 0 ) & Input(0 TO delay_tracks - 2);
--       DataOut( 1 ) <= Input( delay_tracks - 1 );
--      END IF;
-- END PROCESS;
 
 
-- END rtl;

 -------------------------------------------------------------------------
 ARCHITECTURE rtl OF kfout_router IS

   SIGNAL Output         : Vector( 0 TO DataOut'LENGTH-1 )                         := NullVector( DataOut'LENGTH );

   SIGNAL reset_array : std_logic_vector(0 TO 7) := (OTHERS=>'0');

   SUBTYPE tAddress        IS INTEGER RANGE 0 TO PacketBufferLength - 1;
   TYPE tAddressArray      IS ARRAY( 0 TO DataIn'LENGTH-1 ) OF tAddress;
   
   TYPE tBooleanArray      IS ARRAY( 0 to DataIn'LENGTH-1 ) OF BOOLEAN;

   BEGIN
   g1 : FOR j IN 0 TO DataOut'LENGTH-1 GENERATE

     SIGNAL RamCells       : Vector( 0 TO DataIn'LENGTH-1 )                          := NullVector( DataIn'Length );

     SIGNAL Input          : Vector( 0 TO DataIn'LENGTH-1 )                          := NullVector( DataIn'LENGTH );
     SIGNAL WriteEnable    : tBooleanArray := (OTHERS => FALSE);

     SIGNAL Addresses_ram : INTEGER_VECTOR( 0 TO 107) := (OTHERS=>0);
     SIGNAL Addresses_ram_delay : INTEGER_VECTOR( 0 TO 107) := (OTHERS=>0);

     SIGNAL WriteAddr    : tAddressArray                       := ( OTHERS => 0 );
     SIGNAL ReadAddr     :tAddressArray := ( OTHERS => 0 );
     SIGNAL ReadAddr_delay     :tAddressArray := ( OTHERS => 0 );

     SIGNAL out_counter : INTEGER_VECTOR( 0 TO 2) := (OTHERS=>0);

   BEGIN

 -- -------------------------------------------------------------------------
 -- RAM for storing incoming trigger cells
 -- -------------------------------------------------------------------------
   RAMgen            : FOR i IN Input'RANGE GENERATE
     DataRamInstance : ENTITY work.DataRam
     GENERIC MAP(
         COUNT => PacketBufferLength
     )
     PORT MAP(
       clk         => clk ,
       WriteAddr   => WriteAddr( i ),
       DataIn      => Input( i ) ,
       WriteEnable => WriteEnable( i ) ,
       ReadAddr    => ReadAddr( i ) ,
       DataOut     => RamCells( i ) 
     );
   END GENERATE RAMgen;
 -- -------------------------------------------------------------------------

 -- -------------------------------------------------------------------------
   PROCESS( clk )
   VARIABLE buffer_counter : INTEGER := 0;
   BEGIN
     IF( RISING_EDGE( clk ) ) THEN

       reset_array <= reset & reset_array( 0 TO 6);
     
       IF reset = '1' THEN
         buffer_counter := 0;
         --Addresses_ram <= (OTHERS=>0);
         WriteAddr <= ( OTHERS => 0 );
       END IF;

       FOR ram IN Input'RANGE LOOP

         Input( ram )  <= DataIn( DataIn'LENGTH - 1 - ram );
         IF ( ( DataIn( DataIn'LENGTH - 1 - ram ).sortkey = j ) AND ( DataIn( DataIn'LENGTH - 1 - ram).DataValid ) ) THEN
           WriteEnable( ram ) <= TRUE;
           WriteAddr( ram ) <= ( WriteAddr( ram ) + 1 ) MOD PacketBufferLength;
          
           Addresses_ram( buffer_counter ) <= ram;
           buffer_counter := buffer_counter + 1;
         ELSE
           WriteEnable( ram ) <= FALSE;

         END IF;
       END LOOP;


       Addresses_ram_delay <= Addresses_ram;

     END IF;
   END PROCESS;



   PROCESS( clk )


  
   BEGIN
     IF( RISING_EDGE( clk ) ) THEN

       DataOut( j ) <= RamCells(Addresses_ram_delay( out_counter(2)));

       out_counter(1) <= out_counter(0);
       out_counter(2) <= out_counter(1);
  
       IF reset_array(2) = '1' THEN
         ReadAddr <= ( OTHERS => 0 );
         out_counter(0) <= 0;
       ELSE
         out_counter(0) <= (out_counter(0) + 1) MOD (PacketBufferLength + 1);
         ReadAddr( Addresses_ram_delay( out_counter(0)  ) ) <=   (ReadAddr( Addresses_ram_delay( out_counter(0)  ) ) + 1) MOD PacketBufferLength;

       END IF;

     END IF;
   END PROCESS;
 END GENERATE;
 
 END rtl;
