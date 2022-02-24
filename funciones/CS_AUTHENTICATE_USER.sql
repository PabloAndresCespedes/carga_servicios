create or replace FUNCTION cs_AUTHENTICATE_USER
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
        
end cs_AUTHENTICATE_USER;
