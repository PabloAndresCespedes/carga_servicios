create or replace trigger "CS_DET_SRV_AI"
AFTER
insert or delete or update on "CS_DET_SERVICIOS_CLIENTES"
for each row
begin
    if inserting then
        update CS_SERVICIOS_CLIENTES s
        set    s.MONTO_TOTAL = nvl(s.MONTO_TOTAL, 0) + :new.MONTO_TOTAL,
               s.MONTO_EXENTO = nvl(s.MONTO_EXENTO, 0) + :new.MONTO_EXENTO,
               s.MONTO_IVA_CINCO = nvl(s.MONTO_IVA_CINCO, 0) + :new.MONTO_IVA_CINCO,
               s.MONTO_IVA_DIEZ = nvl(s.MONTO_IVA_DIEZ, 0) + :new.MONTO_IVA_DIEZ,
               s.MONTO_DESCUENTO = nvl(s.MONTO_DESCUENTO, 0) + :new.MONTO_DESCUENTO
        where  s.id = :new.servicio_cab_id;
    elsif updating then
        update CS_SERVICIOS_CLIENTES s
        set    s.MONTO_TOTAL = nvl(s.MONTO_TOTAL, 0) + (:new.MONTO_TOTAL - :old.MONTO_TOTAL),
               s.MONTO_EXENTO = nvl(s.MONTO_EXENTO, 0) + (:new.MONTO_EXENTO - :old.MONTO_EXENTO),
               s.MONTO_IVA_CINCO = nvl(s.MONTO_IVA_CINCO, 0) + (:new.MONTO_IVA_CINCO - :old.MONTO_IVA_CINCO),
               s.MONTO_IVA_DIEZ = nvl(s.MONTO_IVA_DIEZ, 0) + (:new.MONTO_IVA_DIEZ - :old.MONTO_IVA_DIEZ),
               s.MONTO_DESCUENTO = nvl(s.MONTO_DESCUENTO, 0) + (:new.MONTO_DESCUENTO - :old.MONTO_DESCUENTO)
        where  s.id = :new.servicio_cab_id;
    else
        update CS_SERVICIOS_CLIENTES s
        set    s.MONTO_TOTAL = nvl(s.MONTO_TOTAL, 0) - :old.MONTO_TOTAL,
               s.MONTO_EXENTO = nvl(s.MONTO_EXENTO, 0) - :old.MONTO_EXENTO,
               s.MONTO_IVA_CINCO = nvl(s.MONTO_IVA_CINCO, 0) - :old.MONTO_IVA_CINCO,
               s.MONTO_IVA_DIEZ = nvl(s.MONTO_IVA_DIEZ, 0) - :old.MONTO_IVA_DIEZ,
               s.MONTO_DESCUENTO = nvl(s.MONTO_DESCUENTO, 0) - :old.MONTO_DESCUENTO
        where  s.id = :old.servicio_cab_id;
    end if;
end;

