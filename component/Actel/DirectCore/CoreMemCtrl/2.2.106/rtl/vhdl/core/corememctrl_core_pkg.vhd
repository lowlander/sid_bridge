library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

package corememctrl_core_pkg is
  function SYNC_MODE_SEL    ( FAMILY: INTEGER) return INTEGER;
  function DQ_SIZE_SEL      ( MEM_0_DQ_SIZE: INTEGER ; MEM_1_DQ_SIZE: INTEGER ; MEM_2_DQ_SIZE: INTEGER ; MEM_3_DQ_SIZE: INTEGER ; FLASH_DQ_SIZE: INTEGER ) return INTEGER ;
  function DQ_SIZE_SRAM_SEL ( MEM_0_DQ_SIZE: INTEGER ; MEM_1_DQ_SIZE: INTEGER ; MEM_2_DQ_SIZE: INTEGER ; MEM_3_DQ_SIZE: INTEGER ) return INTEGER ;
 
end corememctrl_core_pkg;

package body corememctrl_core_pkg is
 
   function SYNC_MODE_SEL ( FAMILY: INTEGER) return INTEGER IS
      VARIABLE return_val : INTEGER := 0;
      BEGIN
         IF (FAMILY = 25) THEN
            return_val := 1;
         ELSE
            return_val := 0;
         END IF;
         RETURN return_val;
      END SYNC_MODE_SEL;

   function DQ_SIZE_SEL ( MEM_0_DQ_SIZE: INTEGER ; MEM_1_DQ_SIZE: INTEGER ; MEM_2_DQ_SIZE: INTEGER ; MEM_3_DQ_SIZE: INTEGER ; FLASH_DQ_SIZE: INTEGER ) return INTEGER IS
      VARIABLE return_val1 : INTEGER := 8;
      BEGIN
         IF (MEM_0_DQ_SIZE = 32 or MEM_1_DQ_SIZE = 32 or MEM_2_DQ_SIZE = 32 or MEM_3_DQ_SIZE = 32 or FLASH_DQ_SIZE = 32) THEN
            return_val1 := 32;
         ELSIF (MEM_0_DQ_SIZE = 16 or MEM_1_DQ_SIZE = 16 or MEM_2_DQ_SIZE = 16 or MEM_3_DQ_SIZE = 16 or FLASH_DQ_SIZE = 16) THEN
            return_val1 := 16;
         ELSE
            return_val1 := 8;
         END IF;
         RETURN return_val1;
      END DQ_SIZE_SEL;

   function DQ_SIZE_SRAM_SEL ( MEM_0_DQ_SIZE: INTEGER ; MEM_1_DQ_SIZE: INTEGER ; MEM_2_DQ_SIZE: INTEGER ; MEM_3_DQ_SIZE: INTEGER ) return INTEGER IS
      VARIABLE return_val2 : INTEGER := 8;
      BEGIN
         IF (MEM_0_DQ_SIZE = 32 or MEM_1_DQ_SIZE = 32 or MEM_2_DQ_SIZE = 32 or MEM_3_DQ_SIZE = 32 ) THEN
            return_val2 := 32;
         ELSIF (MEM_0_DQ_SIZE = 16 or MEM_1_DQ_SIZE = 16 or MEM_2_DQ_SIZE = 16 or MEM_3_DQ_SIZE = 16 ) THEN
            return_val2 := 16;
         ELSE
            return_val2 := 8;
         END IF;
         RETURN return_val2;
      END DQ_SIZE_SRAM_SEL;

end corememctrl_core_pkg;
