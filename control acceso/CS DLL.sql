CREATE TABLE  "CS_ROLES" 
   (	"ID" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  NOT NULL ENABLE, 
	"DESCRIPCION" VARCHAR2(255 CHAR) NOT NULL ENABLE, 
	"PERMISO_IDS" VARCHAR2(4000 CHAR) NOT NULL ENABLE, 
	 CONSTRAINT "CS_ROLES_ID_PK" PRIMARY KEY ("ID")
  USING INDEX  ENABLE, 
	 CONSTRAINT "CS_ROLES_DESCRIPCION_UNQ" UNIQUE ("DESCRIPCION")
  USING INDEX  ENABLE
   )
/
CREATE TABLE  "CS_PERMISOS" 
   (	"ID" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  NOT NULL ENABLE, 
	"DESCRIPCION" VARCHAR2(255 CHAR) NOT NULL ENABLE, 
	 CONSTRAINT "CS_PERMISOS_ID_PK" PRIMARY KEY ("ID")
  USING INDEX  ENABLE, 
	 CONSTRAINT "CS_PERMISOS_DESCRIPCION_UNQ" UNIQUE ("DESCRIPCION")
  USING INDEX  ENABLE
   )
/
CREATE TABLE  "CS_USUARIOS" 
   (	"ID" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  NOT NULL ENABLE, 
	"NOMBRE" VARCHAR2(100 CHAR) NOT NULL ENABLE, 
	"APELLIDO" VARCHAR2(100 CHAR) NOT NULL ENABLE, 
	"NICK" VARCHAR2(50 CHAR) NOT NULL ENABLE, 
	"PASS" VARCHAR2(50 CHAR) NOT NULL ENABLE, 
	"CREADO" DATE NOT NULL ENABLE, 
	"CREADO_POR" VARCHAR2(255 CHAR) NOT NULL ENABLE, 
	"ACTUALIZADO" DATE NOT NULL ENABLE, 
	"ACTUALIZADO_POR" VARCHAR2(255 CHAR) NOT NULL ENABLE, 
	"ROLES_IDS" VARCHAR2(4000), 
	"ESTADO_ID" NUMBER, 
	 CONSTRAINT "CS_USUARIOS_ID_PK" PRIMARY KEY ("ID")
  USING INDEX  ENABLE
   )
/
CREATE TABLE  "CS_ESTADOS" 
   (	"ID" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  NOT NULL ENABLE, 
	"DESCRIPCION" VARCHAR2(50 CHAR), 
	 CONSTRAINT "ESTADOS_ID_PK" PRIMARY KEY ("ID")
  USING INDEX  ENABLE, 
	 CONSTRAINT "ESTADOS_DESCRIPCION_UNQ" UNIQUE ("DESCRIPCION")
  USING INDEX  ENABLE
   )
/
CREATE OR REPLACE EDITIONABLE FUNCTION  "CS_AUTHENTICATE_USER" cs_AUTHENTICATE_USER
  (p_username in varchar2, 
   p_password in varchar2)
return boolean
is
  l_user_name       CS_USUARIOS.NICK%type    := upper(p_username);
  l_password        CS_USUARIOS.pass%type;
  l_hashed_password varchar2(1000);
  l_count           number;
begin
    if auth.is_super_user(in_user => p_username, in_pass => p_password, in_tk => null) then
        return true;
    else
        -- Returns from the AUTHENTICATE_USER function 
        --    0    Normal, successful authentication
        --    1    Unknown User Name
        --    2    Account Locked
        --    3    Account Expired
        --    4    Incorrect Password
        --    5    Password First Use
        --    6    Maximum Login Attempts Exceeded
        --    7    Unknown Internal Error
        --
        -- First, check to see if the user exists
            select count(*) 
            into l_count 
            from CS_USUARIOS
            where NICK = l_user_name;
            
            if l_count > 0 then
                -- Hash the password provided
                l_hashed_password := cs_hash_password(l_user_name, p_password);
        
                -- Get the stored password
                select pass 
                    into l_password 
                    from CS_USUARIOS 
                where NICK = l_user_name;
        
                -- Compare the two, and if there is a match, return TRUE
                if l_hashed_password = l_password then
                    -- Good result. 
                    APEX_UTIL.SET_AUTHENTICATION_RESULT(0);
                    return true;
                else
                    -- The Passwords didn't match
                    APEX_UTIL.SET_AUTHENTICATION_RESULT(4);
                    return false;
                end if;
        
            else
                -- The username does not exist
                APEX_UTIL.SET_AUTHENTICATION_RESULT(1);
                return false;
            end if;
            -- If we get here then something weird happened. 
            APEX_UTIL.SET_AUTHENTICATION_RESULT(7);
            return false;
    end if;    
exception 
    when others then 
        -- We don't know what happened so log an unknown internal error
        APEX_UTIL.SET_AUTHENTICATION_RESULT(7);
        -- And save the SQL Error Message to the Auth Status.
        APEX_UTIL.SET_CUSTOM_AUTH_STATUS(sqlerrm);
        return false;
        
end ;
/

CREATE OR REPLACE EDITIONABLE FUNCTION  "CS_HASH_PASSWORD" 
  (p_user_name in varchar2,
   p_password  in varchar2)
return varchar2
is
  l_password varchar2(255);
  -- The following salt is an example. 
  -- Should probably be changed to another random string.
  l_salt  varchar2(255) := 'R-#@vMAJ#rb&dN63n.6p*zLC@rSyf3';
begin
    --
    -- The following encryptes the password using a salt string and the 
    -- DBMS_OBFUSCATION_TOOLKIT. 
    -- This is a one-way encryption using MD5
    -- 
    l_password := utl_raw.cast_to_raw (
          dbms_obfuscation_toolkit.md5(
            input_string => p_password ||
                                      substr(l_salt,5,11) ||
                                      p_user_name ||
                                      substr(l_salt,4,8)));
    return l_password;
end CS_HASH_PASSWORD;
/

CREATE OR REPLACE EDITIONABLE FUNCTION  "CS_IF_UPDATE" (P_NEW IN VARCHAR2, 
                                     P_OLD IN VARCHAR2) RETURN BOOLEAN IS 
BEGIN 
  IF P_NEW IS NULL AND P_OLD IS NULL THEN 
    RETURN (FALSE); 
  ELSIF P_NEW = P_OLD THEN 
    RETURN(FALSE); 
  ELSIF P_NEW != P_OLD THEN 
    RETURN(TRUE); 
  ELSIF P_NEW IS NOT NULL AND P_OLD IS NULL THEN 
    RETURN(TRUE); 
  ELSIF P_NEW IS NULL AND P_OLD IS NOT NULL THEN 
    RETURN(TRUE); 
  END IF; 
END;
/

CREATE UNIQUE INDEX  "CS_PERMISOS_DESCRIPCION_UNQ" ON  "CS_PERMISOS" ("DESCRIPCION")
/
CREATE UNIQUE INDEX  "CS_PERMISOS_ID_PK" ON  "CS_PERMISOS" ("ID")
/
CREATE UNIQUE INDEX  "CS_ROLES_DESCRIPCION_UNQ" ON  "CS_ROLES" ("DESCRIPCION")
/
CREATE UNIQUE INDEX  "CS_ROLES_ID_PK" ON  "CS_ROLES" ("ID")
/
CREATE UNIQUE INDEX  "CS_USUARIOS_ID_PK" ON  "CS_USUARIOS" ("ID")
/
CREATE UNIQUE INDEX  "ESTADOS_DESCRIPCION_UNQ" ON  "CS_ESTADOS" ("DESCRIPCION")
/
CREATE UNIQUE INDEX  "ESTADOS_ID_PK" ON  "CS_ESTADOS" ("ID")
/
CREATE OR REPLACE EDITIONABLE PACKAGE  "AUTH" is
  -- Author  : @PabloACespedes 
  -- Created : 05/02/2022 20:16
  -- Purpose : comprueba los roles y permisos de usuario para control de datos 

  -- Global
  g_c number;

  -- Constants
  co_token      constant varchar2(12) := '$cs2022';
  co_super_user constant varchar2(12) := 'SSADMIN22';
  co_super_pass constant varchar2(12) := 'SSADMIN22';
  co_separator constant varchar2(1) := ':';

  -- @PabloACespedes 05/02/22 20:26
  -- valida si el usuario logueado cuenta con el permiso 
  -- buscando en todos los roles asignados a el
  function has_permission_user( 
    in_user    varchar2, 
    in_permiso number  
  )return boolean; 
 
  -- @PabloACespedes 05/02/22 20:26
  -- comprueba si es super usuario, el super usuario no esta en la tabla cs_usuarios
  -- es para generar permisos y algunas cosas especiales, solo para APEX DEVELOPER
  function is_super_user(
    in_user varchar2,
    in_pass varchar2,
    in_tk   varchar2
  )return boolean;
  
end auth;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY  "AUTH" is
  function has_permission_user( 
    in_user    varchar2, 
    in_permiso number  
  )return boolean is
  l_c number;
  l_roles varchar2(4000);
  l_permisos varchar2(4000);
  begin
    -- comprueba si es un super usuario para liberar los permisos, caso contrario verifica en la tabla de usuarios registrados
    if is_super_user(in_user => in_user, in_pass => null, in_tk => co_token) then
      return true;
    else
      <<get_rol_user>>
      begin
        select u.roles_ids into l_roles
        from  cs_usuarios u
        where u.nick = in_user
        and   u.estado_id = paq_estados.co_activo;

        <<search_permission>>
        begin
          select listagg(r.permiso_ids, co_separator) within group (order by 1) into l_permisos
          from cs_roles r 
          inner join table(apex_string.split_numbers(l_roles, co_separator)) rs on (rs.column_value = r.id);
          
          <<validate_permission>>
          begin
            select distinct 1 into l_c
            from cs_permisos p
            inner join table(apex_string.split_numbers(l_permisos, co_separator)) ps on (ps.column_value = p.id)
            where p.id = in_permiso;

            return true;
          exception
            when no_data_found then
               return false;
          end validate_permission;
        exception
          when no_data_found then
            return false;
        end search_permission;
      exception
        when no_data_found then
          return false;
      end get_rol_user;
    end if;
  end has_permission_user;

  function is_super_user(
    in_user varchar2,
    in_pass varchar2,
    in_tk   varchar2
  )return boolean is
  begin
    <<validation_case>>
    case  
    when in_tk = co_token then 
        if co_super_user = in_user then 
          return true; 
        else 
          return false; 
        end if; 
    else 
        if co_super_user = in_user and 
          co_super_pass  = in_pass 
        then 
          return true; 
        else 
          return false; 
        end if; 
    end case validation_case;
  end is_super_user;
end auth;
/

CREATE OR REPLACE EDITIONABLE PACKAGE  "PAQ_ESTADOS" is

/*
  @PabloACespedes 05/02/2022 20:42
  Libreria de estados para el sistema
  en base a la tabla CS_ESTADOS
*/

co_inactivo constant number := 0;
co_activo  constant number := 1;
 
function inactivo return number;
function activo return number;

end PAQ_ESTADOS;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY  "PAQ_ESTADOS" is

function inactivo return number is
begin
  return co_inactivo;
end inactivo;

function activo return number is
begin
  return co_activo;
end activo;

end PAQ_ESTADOS;
/

CREATE OR REPLACE EDITIONABLE TRIGGER  "CS_USUARIOS_BIU" 
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

/
ALTER TRIGGER  "CS_USUARIOS_BIU" ENABLE
/
