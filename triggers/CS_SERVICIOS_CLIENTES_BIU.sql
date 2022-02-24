create or replace trigger cs_servicios_clientes_biu 
    before insert or update  
    on cs_servicios_clientes 
    for each row 
begin 
    if inserting then 
        :new.created := current_date; 
        :new.created_by := coalesce(sys_context('APEX$SESSION','APP_USER'),user);
        :new.estado_id := paq_estados.co_carga;
        :new.fecha := current_date;
    end if; 
    :new.updated := current_date; 
    :new.updated_by := coalesce(sys_context('APEX$SESSION','APP_USER'),user); 
end cs_servicios_clientes_biu; 

