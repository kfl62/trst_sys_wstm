# encoding: utf-8
# Template for Wstm::Invoice#pdf
require 'prawn/measurement_extensions'

def firm
  Wstm::PartnerFirm.find_by(:firm => true)
end

pdf = Prawn::Document.new(
  :page_size => 'A4',
  :page_layout => :portrait,
  :margin => [10.mm],
  :info => {
    :Title => "Facturare",
    :Author => "kfl62",
    :Subject => "Formular \"Facturare\"",
    :Keywords => "#{firm.name[1].titleize} Facturare",
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
