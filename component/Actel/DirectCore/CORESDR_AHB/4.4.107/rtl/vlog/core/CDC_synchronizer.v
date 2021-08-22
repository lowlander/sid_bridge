module cdc_synchroniser  
# (	
   
                              
  parameter SYNC_CLOCK = 0    
  
)
(
  input toggle,
  input clk,
  input reset,
  output syn_pulse
);


generate 
  if (SYNC_CLOCK == 1 )  
begin
      reg toggle_f1;



always @ (posedge clk or negedge reset)
begin
  if (!reset)
    begin
      toggle_f1 <= 0;
   
	end
  else 
    begin 
      toggle_f1 <= toggle;
   
    end  
end

assign syn_pulse = toggle_f1 ^ toggle;

end 
endgenerate


generate 
if (SYNC_CLOCK == 0 )  

begin
  reg toggle_f1;
  reg toggle_f2;
  reg toggle_f3;


always @ (posedge clk or negedge reset)
begin
  if (!reset)
    begin
      toggle_f1 <= 0;
      toggle_f2 <= 0;
      toggle_f3 <= 0;
	end
  else 
    begin 
      toggle_f1 <= toggle;
      toggle_f2 <= toggle_f1;
      toggle_f3 <= toggle_f2;
    end  
end

assign syn_pulse = toggle_f3 ^ toggle_f2;

end 
endgenerate


endmodule