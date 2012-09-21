# encoding: utf-8
# Template for AdeverintaPredarePrimire.pdf
require 'prawn/measurement_extensions'

def firm
  Wstm::PartnerFirm.find_by(:firm => true)
end
def address
  firm.addresses.first
end
def freight_name(name)
  ary = name.split(" ")
  case ary.length
  when 1
    ary[0].titleize
  when 2
    [ary[0][0..2],'.',ary[1]].join[0..7]
  else
    "Error"
  end
end
def table_freight_data
  data = []
  data[0] = %w{Nr Material UM PU Cant. Val 3% 16% Rest}
  @object.freights.each_with_index do |f,i|
    val = (f.pu * f.qu).round(2)
    p03 = f.freight.p03 ? (val *  3 / 100).round(2) : 0.0
    p16 = (val * 16 / 100).round(2)
    out = val - (p03 + p16)
    data[i + 1] = [i +1 , freight_name(f.freight.name), f.um, "%.2f" % f.pu, "%.2f" % f.qu, "%.2f" % val, "%.2f" % p03, "%.2f" % p16, "%.2f" % out]
  end
  for i in data.length..5 do
    data[i] = [i, "","","","","","","",""]
  end
  data[6] = ["","TOTAL","","","", "%.2f" % @object.sum_100, "%.2f" % @object.sum_003, "%.2f" % @object.sum_016, "%.2f" % @object.sum_out]
  data
end
def table_recap_data
  data = [
    ["Din valoarea totala de","%.2f" % @object.sum_100, "RON s-au reţinut:"],
    ["Taxă mediu (3%) în valoare de","%.2f" % @object.sum_003,"RON"],
    ["Impozit  (16%) în valoare de","%.2f" % @object.sum_016,"RON"],
    [Prawn::Text::NBSP,Prawn::Text::NBSP,Prawn::Text::NBSP],
    ["S-a achitat suma de","%.2f" % @object.sum_out, "RON"]
  ]
end
def table_sign_data
  data = [
    ["Gestionar","Primitor"],
    [@object.signed_by.name,@object.client.name],
    ["_"*25,"_"*25]
  ]
end
def box_content(pdf)
  pdf.font_size 8 do
    pdf.text "#{firm.name[2]}"
    pdf.move_up 9
    pdf.text "Punct de lucru: #{@object.unit.name[1]}", :align => :right
    pdf.text "Nr.înreg.R.C. : #{firm.identities['chambcom']}"
    pdf.move_up 9
    pdf.text "Gestionar: #{@object.signed_by.name}", :align => :right
    pdf.text "Cod fiscal (C.U.I) : #{firm.identities['fiscal']}"
    pdf.text "Str.#{address.street} nr.#{address.nr},bl.#{address.bl},sc.#{address.sc},ap.#{address.ap},"
    pdf.text 'Cluj-Napoca, judeţul Cluj'
  end
  pdf.move_down 5.mm
  pdf.text 'ADEVERINŢĂ DE PRIMIRE ŞI PLATĂ',
    :align => :center, :size => 12, :style => :bold
  pdf.move_down 5.mm
  pdf.text "Nr. #{@object.name} din #{@object.id_date.strftime('%Y-%m-%d')}",
    :align => :center, :size => 10, :style => :bold
  pdf.move_down 5.mm
  pdf.font_size 9 do
    pdf.text I18n.t('wstm.intro.pdf.desk_expenditure.text_01', @object.client.i18n_hash),:leading => 2, :inline_format => true
    pdf.move_down 10.mm
    pdf.table(table_freight_data) do
      style(row(0..7), :padding => [1,3])
      style(row(0), :background_color => 'dddddd', :align => :center)
      style(row(1..5).column(0), :align => :center)
      style(row(1..5).column(2), :align => :center)
      style(row(1..5).column(3..8), :align => :right)
      column(0).style(:width => 6.mm)
      column(1).style(:width => 18.mm)
      column(2).style(:width => 8.mm)
      column(3).style(:width => 13.mm)
      column(4).style(:width => 15.mm)
      column(5).style(:width => 18.mm)
      column(6).style(:width => 12.mm)
      column(7).style(:width => 15.mm)
      column(8).style(:width => 18.mm)
      row(6).column(0).borders = [:left,:top,:bottom]
      row(6).column(1..4).borders = [:top,:bottom]
      style(row(6), :background_color => 'dddddd', :align => :center)
    end
    pdf.move_down 10.mm
    pdf.text I18n.t('wstm.intro.pdf.desk_expenditure.text_02', @object.client.i18n_hash).gsub('#',"#{Prawn::Text::NBSP}"),:leading => 2, :inline_format => true
    pdf.draw_text('Semnătura (amprenta) ________________', :at  => [50.mm,pdf.y - 25])
    pdf.move_down 5.mm
    pdf.table(table_recap_data) do
      cells.style(:borders => [], :padding => [1,3])
      column(1).style(:align => :right, :font_style => :bold, :width => 25.mm)
    end
    pdf.move_down 10.mm
    pdf.table(table_sign_data) do
      cells.style(:borders => [], :padding => [1,3], :align => :center)
      column(0..1).style(:width => 60.mm)
    end
  end
end


pdf = Prawn::Document.new(
  :page_size => 'A4',
  :page_layout => :landscape,
  :margin => [0.mm],
  :info => {
    :Title => "Adeverinţă_Primire_Plata",
    :Author => "kfl62",
    :Subject => "Formular \"Adeverinţă de Primire şi Plată\"",
    :Keywords => "#{firm.name[1].titleize} Adeverinţă Primire Plată",
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
pdf.bounding_box([15.mm,200.mm],:width  => 123.mm, :height => 190.mm) do
  box_content(pdf)
end
pdf.bounding_box([163.mm,200.mm],:width  => 123.mm, :height => 190.mm) do
  box_content(pdf)
end
pdf.stroke_line(148.mm,5.mm,148.mm,10.mm)
pdf.stroke_line(148.mm,200.mm,148.mm,205.mm)
pdf.render()
