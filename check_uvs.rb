require "rubygems"
require "highline/import"
require "mechanize"

# First ask for credentials...
login = (ask "Login UTBM : ").downcase
passwd = ask("Mot de passe : ") { |c| c.echo = "*" }

a = Mechanize.new
# Getting login page
a.get('https://extranet.utbm.fr/Application/PageUtilisateur/Generique/Authentification.aspx') do |login_page|
  # Filling login form
  menu_page = login_page.form_with(:action =>'Authentification.aspx') do |f|
    f.Identifiant = login
    f.MotPasse = passwd
  end.click_button # Sending form
  while(true) do
    # Clicking results link
    results_page = a.click(menu_page.link_with(:text => 'Résultats semestriels'))
    # Dirty-way clearing terminal
    system("clear")
    # Finding courses table
    results_page.search("//table[@id='ctl00_ContentPlaceHolder1_ResultatUv']").each do |table|
      # For each row (= course)
      table.search("./tr[contains(@class, 'TableauListingLigne')]").each do |tr|
        content = tr.search("./td")
        # Puts result
        puts content[1].content + " - " + content[3].content
      end
    end
    # Waiting a few sec (random :D)
    sleep 30 + rand(30)
  end
end
