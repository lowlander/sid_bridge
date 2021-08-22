library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Bin2Gray is
    generic (
        n_bits               : integer := 4
        );
    port (

        cntBinary            : in std_logic_vector (n_bits - 1 downto 0);                                  
        nextGray             : out std_logic_vector (n_bits - 1 downto 0)
	);
end Bin2Gray;


architecture rtl of Bin2Gray is

   begin
   GEN_GRAY: 
      for i in 0 to (n_bits-2) generate
      --for i in 0 to (n_bits-1) generate
         nextGray(i) <= cntBinary(i) xor cntBinary(i+1);
   end generate GEN_GRAY;

 
  nextGray(n_bits-1) <= cntBinary(n_bits-1);


end rtl;
