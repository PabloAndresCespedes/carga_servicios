create or replace trigger "CS_PAGOS_AID"
AFTER
delete or insert on "CS_PAGOS"
for each row
begin
   if inserting then
     update CS_SERVICIOS_CLIENTES c
     set    c.saldo = (c.saldo - :new.monto)
     where  c.id = :new.SERVICIO_CAB_ID;
   else -- deleting
     update CS_SERVICIOS_CLIENTES c
     set    c.saldo = (c.saldo + :old.monto)
     where  c.id = :old.SERVICIO_CAB_ID;
   end if;
end;

