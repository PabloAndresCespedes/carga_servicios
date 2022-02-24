create or replace package body auth is
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
