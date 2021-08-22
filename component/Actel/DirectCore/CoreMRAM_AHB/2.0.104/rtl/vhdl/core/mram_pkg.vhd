package mram_pkg is
  function SYNC_MODE_SEL ( FAMILY: INTEGER) return INTEGER;
end mram_pkg;

package body mram_pkg is
  function SYNC_MODE_SEL ( FAMILY: INTEGER) return INTEGER IS
    VARIABLE return_val : INTEGER := 0;
    BEGIN
      IF (FAMILY = 25) THEN
        return_val := 1;
      ELSE
        return_val := 0;
      END IF;
    RETURN return_val;
  end SYNC_MODE_SEL;
end mram_pkg;
