require "rubygems"
require "highline/import"
require "mechanize"

require "uv"

class UvChecker
  attr_reader :last_check, :last_check_noerror, :uvs
  def initialize(login, passwd)
    @a = Mechanize.new
    @login = login
    @passwd = passwd
    @uvs = Hash.new
    @a.get('https://extranet.utbm.fr/Application/PageUtilisateur/Generique/PageGarde.aspx') do |page|
        @current_page = page
    end
  end
  def log_in
    # Filling login form
    @current_page.form_with(:action =>'Authentification.aspx') do |f|
      f.Identifiant = @login
      f.MotPasse = @passwd
    end.click_button # Sending form
  end
  def logged_in?
    @current_page.form_with(:action => 'Authentification.aspx') == nil
  end
  def check
    begin
      if not logged_in?
        @current_page = log_in
      end
      @a.get('https://extranet.utbm.fr/Application/PageUtilisateur/PvSuiviEtude/VisualisationResultatEtudiant.aspx') do |results_page|
        @current_page = results_page
        # Finding courses table
        results_page.search("//table[@id='ctl00_ContentPlaceHolder1_ResultatUv']").each do |table|
          # For each row (= course)
          table.search("./tr[contains(@class, 'TableauListingLigne')]").each do |tr|
            content = tr.search("./td")
            u = Uv.new
            u.name = content[1].content
            u.grade = content[3].content
            if @uvs[u.name] == nil || @uvs[u.name].grade != u.grade
              u.new = true
              @uvs[u.name] = u
            end
          end
        end
      end
      @last_check_noerror = Time.new
      @last_check = @last_check_noerror
    rescue => e
      @last_check = Time.new
    end
  end
end
