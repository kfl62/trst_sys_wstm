# encoding: utf-8
# Template for Wstm::Cassation#pdf
require 'prawn/measurement_extensions'

def firm
  Wstm::PartnerFirm.find_by(:firm => true)
end

pdf = Prawn::Document.new(
  :page_size => 'A4',
  :page_layout => :landscape,
  :margin => [10.mm],
  :info => {
    :Title => "PV_Casare_Degradare",
    :Author => "kfl62",
    :Subject => "Formular \"PV de Casare/Degradare\"",
    :Keywords => "#{firm.name[1].titleize} Proces Verbal Casare Degradare",
    :Creator => "http://#{firm.name[0].downcase}.trst.ro (using Sinatra, Prawn)",
    :CreationDate => Time.now
  }
)
pdf.font_families.update(
  'Verdana' => {:bold => 'public/stylesheets/fonts/verdanab.ttf',
                :italic => 'public/stylesheets/fonts/verdanai.ttf',
                :bold_italic => 'public/stylesheets/fonts/verdanaz.ttf',
                :normal => 'public/stylesheets/fonts/verdana.ttf'})
pdf.font 'Verdana'
pdf.text 'Încă nu este gata..., Anexaţi formularul completat manual!'
pdf.render()
