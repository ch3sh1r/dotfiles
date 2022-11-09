function genpasswd --wraps='openssl rand -base64 12' --description 'alias genpasswd openssl rand -base64 12'
  openssl rand -base64 12 $argv; 
end
