create or replace trigger cs_pagos_biu 
    before insert or update  
    on cs_pagos 
    for each row 
begin 
    if inserting then 
        :new.created := sysdate; 
        :new.created_by := coalesce(sys_context('APEX$SESSION','APP_USER'),user); 
    end if; 
    :new.updated := sysdate; 
    :new.updated_by := coalesce(sys_context('APEX$SESSION','APP_USER'),user); 
    :new.concepto := upper(:new.concepto); 
end cs_pagos_biu; 

