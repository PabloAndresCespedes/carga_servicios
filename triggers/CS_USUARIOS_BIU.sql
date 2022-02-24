create or replace trigger cs_usuarios_biu 
    before insert or update  
    on cs_usuarios 
    for each row 
begin 
    if inserting then
        :new.creado := current_date; 
        :new.creado_por := coalesce(sys_context('APEX$SESSION','APP_USER'),user); 
    end if;

    :new.estado_id := nvl(:new.estado_id, paq_estados.co_activo);
    :new.actualizado := current_date; 
    :new.actualizado_por := coalesce(sys_context('APEX$SESSION','APP_USER'),user);

    -- @PabloACespedes 05/02/22 19:37
    -- encripta la contrasenha en caso de ser una nueva insersión o si es una actualizacion pero con nueva contrasenha
    -- en el caso que solo actualice otros datos la contrasenha antigua permanece para la nueva
    if inserting or (updating and :new.pass is not null and cs_if_update(:new.pass, :old.pass)) then
       :new.pass := cs_hash_password(upper(:new.nick), :new.pass);
    else
       :new.pass := :old.pass;
    end if;
end cs_usuarios_biu; 

