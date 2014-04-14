# encoding: utf-8
# Template for Document cumulativ APP.pdf
require 'prawn/measurement_extensions'
require 'prawn/layout'

period     = params[:period].to_i
unit_ids   = params[:unit_ids].split(',').map{|id| Moped::BSON::ObjectId(id)}

def firm
  Wstm::PartnerFirm.find_by(:firm => true)
end
def address
  firm.addresses.first
end
def superscript(id_stats)
  case id_stats
  when /1101|1102|2101|2102|2201/
    "<sup>(1)</sup>"
  when /3011/
    "<sup>(2,3)</sup>"
  when /3101|3201|3202|3301|3401|3501|3601|3602|4001/
    "<sup>(3)</sup>"
  else
    ""
  end
end
pdf = Prawn::Document.new(
  :page_size => 'A4',
  :page_layout => :portrait,
  :skip_page_creation => true,
  :margin => [10.mm],
  :info => {
    :Title => "Document Cumulativ",
    :Author => "kfl62",
    :Subject => "Formular \"Listă preț\"",
    :Keywords => "#{firm.name[1]} Listă Preț",
    :Creator => "http://#{firm.name[0].downcase}.trst.ro (using Sinatra, Prawn)",
    :CreationDate => Time.now
})

pdf.font_families.update(
  'Verdana' => {:bold => 'public/stylesheets/fonts/verdanab.ttf',
                :italic => 'public/stylesheets/fonts/verdanai.ttf',
                :bold_italic => 'public/stylesheets/fonts/verdanaz.ttf',
                :normal => 'public/stylesheets/fonts/verdana.ttf'}
)
unit_ids.each_with_index do |unit_id,next_unit|
  unit = Wstm::PartnerFirm.unit_by_unit_id(unit_id)
  data = unit.freights.asc(:id_stats).each_with_object([['Deșeu','Preț']]){|f,a| a << ["#{f.name}#{superscript(f.id_stats)}", "%0.2f" % f.pu] }
  fs = data.length > 15 ? 18 : 24
  # @todo
  pdf.start_new_page
  pdf.font 'Verdana'
  pdf.font_size 9 do
    pdf.text "#{firm.name[2]}"
    pdf.move_up 9
    pdf.text "Punct de lucru: #{unit.name[1]}", :align => :right
    pdf.text "Nr.înreg.R.C. : #{firm.identities['chambcom']}"
    pdf.move_up 9
    pdf.text "Gestionar: #{unit.chief}", :align => :right
    pdf.text "Cod fiscal (C.U.I) : #{firm.identities['fiscal']}"
    pdf.text "Str.#{address.street} nr.#{address.nr},bl.#{address.bl},sc.#{address.sc},ap.#{address.ap},"
    pdf.text 'Cluj-Napoca, judeţul Cluj'
  end
  tbl = pdf.make_table(data,cell_style: {border_width: 0.1, inline_format: true}) do
    pdf.font_size fs
    row(0).style(:background_color => "f9f9f9",:padding => [2,5,2,5], align: :center)
    column(0).style(width: 120.mm)
    column(1).rows(1..100).style(align: :right)
  end
  pdf.bounding_box([0,pdf.bounds.top - 65], width: pdf.bounds.width) do
    pdf.text 'Listă prețuri',
      align: :center,size: 24,style: :bold
  end
  _x = (pdf.bounds.width - tbl.width)/2
  _y = (pdf.bounds.top - 100)
  pdf.bounding_box([_x,_y], :width => tbl.width) do
    pdf.text "[lei/kg]", align: :right, size: 9
    tbl.draw
  end
  _y -= (tbl.height + 27)
  pdf.bounding_box([_x,_y], width: tbl.width) do
    pdf.font_size 9 do
      pdf.text "<b><sup>(1)</sup></b> La aceste tipuri de deșeuri prețul poate varia în funcție de culoare, calitate, tip etc.",inline_format: true
      pdf.text "<b><sup>(2)</sup></b> La deșeurile de fier prețul poate varia în funcție de sortiment (tablă, fier brut etc.).",inline_format: true
      pdf.text "Pentru detalii întrebați gestionarul!"
    end
  end
  pdf.bounding_box([0,60], width: pdf.bounds.width) do
    pdf.font_size 10 do
      pdf.text "<b>Important:</b>",inline_format: true
      pdf.text "La primirea banilor solicitați gestionarului <b>Adeverința de Primire/Plată</b>!", inline_format: true
      pdf.text "Conform HG 150/2011.03.01 din valoare totală se reține <b>16%</b> \"Impozit venit\".", inline_format: true
      pdf.text "Conform Legea nr.105/2006 la deșeurile marcate <b><sup>(3)</sup></b> se reține <b>3%</b> \"Taxă mediu\"", inline_format: true
    end
  end
end
pdf.render()
