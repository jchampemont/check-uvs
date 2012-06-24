require "uv"
require "uv_checker"

# First ask for credentials...
login = (ask "Login UTBM : ").downcase
passwd = ask("Mot de passe : ") { |c| c.echo = "*" }
begin
  u = UvChecker.new(login, passwd)
  while true
    u.check
    system("clear")
    puts "Dernière vérification sans erreur : " + (u.last_check_noerror!=nil ? u.last_check_noerror.strftime("%H:%M:%S") : "Jamais")
    puts "Dernière vérification : " + u.last_check.strftime("%H:%M:%S")
    u.uvs.each_value do |uv|
      puts uv.name + " - " + uv.grade + ( uv.new ? (7.chr + " !!") : "" )
      uv.new = false
    end
    sleep 30 + rand(30)
  end
rescue => e
  puts e.backtrace
  puts "Problème de connexion. Vérifiez votre connexion internet/vos identifiants"
end
