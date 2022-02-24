create or replace trigger cs_gastos_biu 
    before insert or update  
    on cs_gastos 
    for each row 
begin 
    :new.obs := upper(:new.obs); 
end cs_gastos_biu; 

