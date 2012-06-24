require "rubygems"
require "highline/import"
require "mechanize"

login = (ask "Login UTBM : ").downcase
passwd = ask("Mot de passe : ") { |c| c.echo = "*" }

a = Mechanize.new
a.get('https://extranet.utbm.fr/Application/PageUtilisateur/Generique/Authentification.aspx') do |login_page|
  menu_page = login_page.form_with(:action =>'Authentification.aspx') do |f|
    f.Identifiant = login
    f.MotPasse = passwd
  end.click_button
  while(true) do
    results_page = a.click(menu_page.link_with(:text => 'Résultats semestriels'))
    system("clear")
    results_page.search("//table[@id='ctl00_ContentPlaceHolder1_ResultatUv']").each do |table|
      table.search("./tr[contains(@class, 'TableauListingLigne')]").each do |tr|
        content = tr.search("./td")
        puts content[1].content + " - " + content[3].content
      end
    end
    sleep 30
  end
end
