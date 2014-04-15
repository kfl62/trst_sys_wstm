# encoding: utf-8
# Template for Wstm::Expenditure#pdf
require 'prawn/measurement_extensions'

def firm
  Wstm::PartnerFirm.find_by(firm: true)
end
def address
  firm.addresses.first
end
def client_hash
  if @object.name == 'EMPTY'
    data = {id_pn: "_"*18, name: "_"*23,city: "_"*10,street: "_"*20,nr: "_"*3,bl: "_"*3,sc: "_"*3,et: "_"*3,ap: "_"*3,dsr: "_"*3,dnr: "_"*12,dby: "_"*8,don: "_"*8}
  else
    data = @object.client.i18n_hash
  end
  data
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
  end unless @object.name == 'EMPTY'
  for i in data.length..5 do
    data[i] = [i, "","","","","","","",""]
  end
  if @object.name == 'EMPTY'
    data[6] = ["","TOTAL","","","","","","",""]
  else
    data[6] = ["","TOTAL","","","", "%.2f" % @object.sum_100, "%.2f" % @object.sum_003, "%.2f" % @object.sum_016, "%.2f" % @object.sum_out]
  end
  data
end
def table_recap_data
  if @object.name == 'EMPTY'
    data = [
      ["Din valoarea totala de","_"*8,"RON s-au reţinut:"],
      ["Taxă mediu (3%) în valoare de","_"*8,"RON"],
      ["Impozit  (16%) în valoare de","_"*8,"RON"],
      [Prawn::Text::NBSP,Prawn::Text::NBSP,Prawn::Text::NBSP],
      ["S-a achitat suma de","_"*8,"RON"]
    ]
  else
    data = [
      ["Din valoarea totala de","%.2f" % @object.sum_100, "RON s-au reţinut:"],
      ["Taxă mediu (3%) în valoare de","%.2f" % @object.sum_003,"RON"],
      ["Impozit  (16%) în valoare de","%.2f" % @object.sum_016,"RON"],
      [Prawn::Text::NBSP,Prawn::Text::NBSP,Prawn::Text::NBSP],
      ["S-a achitat suma de","%.2f" % @object.sum_out, "RON"]
    ]
  end
  data
end
def table_sign_data
  if @object.name == 'EMPTY'
    data = [
      ["Gestionar","Primitor"],
      ["",""],
      ["_"*25,"_"*25]
    ]
  else
    data = [
      ["Gestionar","Primitor"],
      [@object.signed_by.name,@object.client.name],
      ["_"*25,"_"*25]
    ]
  end
  data
end
def box_content_app(pdf)
  pdf.font_size 8 do
    pdf.text "#{firm.name[2]}"
    unless @object.name == 'EMPTY'
      pdf.move_up 9
      pdf.text "Punct de lucru: #{@object.unit.name[1]}", align: :right
    end
    pdf.text "Nr.înreg.R.C. : #{firm.identities['chambcom']}"
    unless @object.name == 'EMPTY'
      pdf.move_up 9
      pdf.text "Gestionar: #{@object.signed_by.name}", align: :right
    end
    pdf.text "Cod fiscal (C.U.I) : #{firm.identities['fiscal']}"
    pdf.text "Str.#{address.street} nr.#{address.nr},bl.#{address.bl},sc.#{address.sc},ap.#{address.ap},"
    pdf.text 'Cluj-Napoca, judeţul Cluj'
  end
  pdf.move_down 5.mm
  pdf.text 'ADEVERINŢĂ DE PRIMIRE ŞI PLATĂ',
    align: :center, size: 12, style: :bold
  pdf.move_down 5.mm
  if @object.name == 'EMPTY'
    pdf.text "Nr. #{'_'*5} din #{'_'*15}",
      align: :center, size: 10, style: :bold
  else
    pdf.text "Nr. #{@object.name} din #{@object.id_date.strftime('%Y-%m-%d')}",
      align: :center, size: 10, style: :bold
  end
  pdf.move_down 5.mm
  pdf.font_size 9 do
    if @object.name == 'EMPTY'
      pdf.text I18n.t('wstm.intro.pdf.desk_expenditure.text_empty_01',client_hash),leading: 2, inline_format: true
    else
      pdf.text I18n.t('wstm.intro.pdf.desk_expenditure.text_01',client_hash),leading: 2, inline_format: true
    end
    pdf.move_down 10.mm
    pdf.table(table_freight_data) do
      style(row(0..7), padding: [1,3])
      style(row(0), background_color: 'dddddd', align: :center)
      style(row(1..5).column(0), align: :center)
      style(row(1..5).column(2), align: :center)
      style(row(1..5).column(3..8), align: :right)
      column(0).style(width: 6.mm)
      column(1).style(width: 18.mm)
      column(2).style(width: 8.mm)
      column(3).style(width: 13.mm)
      column(4).style(width: 15.mm)
      column(5).style(width: 18.mm)
      column(6).style(width: 12.mm)
      column(7).style(width: 15.mm)
      column(8).style(width: 18.mm)
      row(6).column(0).borders = [:left,:top,:bottom]
      row(6).column(1..4).borders = [:top,:bottom]
      style(row(6), background_color: 'dddddd', align: :center)
    end
    pdf.move_down 10.mm
    if @object.name == 'EMPTY'
      pdf.text I18n.t('wstm.intro.pdf.desk_expenditure.text_empty_02',client_hash).gsub('#',"#{Prawn::Text::NBSP}"),leading: 2, inline_format: true
    else
      pdf.text I18n.t('wstm.intro.pdf.desk_expenditure.text_02',client_hash).gsub('#',"#{Prawn::Text::NBSP}"),leading: 2, inline_format: true
    end
    pdf.draw_text('Semnătura (amprenta) ________________', :at  => [50.mm,pdf.y - 25])
    pdf.move_down 5.mm
    if @object.name == 'EMPTY'
      pdf.table(table_recap_data) do
        cells.style(borders: [], padding: [1,3])
        column(1).style(align: :right,width: 25.mm)
      end
    else
      pdf.table(table_recap_data) do
        cells.style(borders: [], padding: [1,3])
        column(1).style(align: :right,width: 25.mm,font_style: :bold)
      end
    end
    pdf.move_down 10.mm
    pdf.table(table_sign_data) do
      cells.style(borders: [], padding: [1,3], align: :center)
      column(0..1).style(width: 60.mm)
    end
  end
end

def frr_id_stats
  %w{3011 3101 3201 3301 3401 3501 3701}
end

def frr_freights
  #@object.freights.where(:freight_id.in =>Wstm::Freight.where(:id_stats.in => frr_id_stats).map(&:id))
  @object.freights.where(:freight_id.in =>Wstm::Freight.where(p03: true).map(&:id))
end

def frr?
  frr_freights.count > 0
end

def table_frr_freight_data
  data = []
  data[0] = ["Nr", "Denumire\nDescriere", "Cod conform\nHG 856/2002", "Cantitate\n(kg)", "Preț\n(lei/kg)", "Valoare\n(lei)" ]
  frr_freights.each_with_index do |f,i|
    val = (f.pu * f.qu).round(2)
    data[i + 1] = [i +1 , freight_name(f.freight.name), f.freight.code[0], "%.2f" % f.qu, "%.2f" % f.pu, "%.2f" % val]
  end unless @object.name == 'EMPTY'
  for i in data.length..5 do
    data[i] = [i, "","","","",""]
  end
  if @object.name == 'EMPTY'
    data[6] = ["","TOTAL","","","",""]
  else
    data[6] = ["","TOTAL","","","", "%.2f" % frr_freights.sum(:val)]
  end
  data
end

def box_content_frr(pdf)
  pdf.font_size 8 do
    pdf.text "#{firm.name[2]}"
    unless @object.name == 'EMPTY'
      pdf.move_up 9
      pdf.text "Punct de lucru: #{@object.unit.name[1]}", align: :right
    end
    pdf.text "Nr.înreg.R.C. : #{firm.identities['chambcom']}"
    pdf.move_up 9
    pdf.text "Aut. de mediu: #{@object.unit.env_auth.split(" ")[0]}", align: :right
    pdf.text "Cod fiscal (C.U.I) : #{firm.identities['fiscal']}"
    unless @object.name == 'EMPTY'
      pdf.move_up 9
      pdf.text "Gestionar: #{@object.signed_by.name}", align: :right
    end
    pdf.text "Str.#{address.street} nr.#{address.nr},bl.#{address.bl},sc.#{address.sc},ap.#{address.ap},"
    pdf.text 'Cluj-Napoca, judeţul Cluj'
  end
  pdf.move_down 5.mm
  pdf.text 'BORDEROU', align: :center, size: 12, style: :bold
  pdf.text 'de achiziţie de deşeuri metalice feroase şi neferoase şi a aliajelor acestora', align: :center, size: 8, style: :bold
  pdf.move_down 5.mm
  if @object.name == 'EMPTY'
    pdf.text "Nr. #{'_'*5} din #{'_'*15}", align: :center, size: 10, style: :bold
  else
    pdf.text "Nr. #{@object.name} din #{@object.id_date.strftime('%Y-%m-%d')}", align: :center, size: 10, style: :bold
  end
  pdf.move_down 5.mm
  pdf.font_size 9 do
    if @object.name == 'EMPTY'
      pdf.text I18n.t('wstm.intro.pdf.desk_expenditure.text_empty_03',client_hash).gsub('#',"#{Prawn::Text::NBSP}"),leading: 2, inline_format: true
    else
      pdf.text I18n.t('wstm.intro.pdf.desk_expenditure.text_03',client_hash),leading: 2, inline_format: true
    end
    pdf.move_down 5.mm
    pdf.table(table_frr_freight_data) do
      style(row(0..7), padding: [1,3])
      style(row(0), background_color: 'dddddd', align: :center)
      style(row(1..5).column(0), align: :center)
      style(row(1..5).column(2), align: :center)
      style(row(1..5).column(3..5), align: :right)
      column(0).style(width: 6.mm)
      column(1).style(width: 25.mm)
      column(2).style(width: 25.mm)
      column(3).style(width: 25.mm)
      column(4).style(width: 15.mm)
      column(5).style(width: 25.mm)
      row(6).column(0).borders = [:left,:top,:bottom]
      row(6).column(1..4).borders = [:top,:bottom]
      style(row(6), background_color: 'dddddd', align: :center)
    end
    pdf.move_down 7.mm
    pdf.text I18n.t('wstm.intro.pdf.desk_expenditure.text_04', val: @object.name == "EMPTY" ? "__________" : @object.name == "EMPTY" ? "______________" : "%.2f" % (frr_freights.sum(:val) - frr_freights.sum(:val)*0.19), name: @object.name == "EMPTY" ? "______________" : @object.name), inline_format: true, align: :justify
    pdf.move_down 3.mm
    pdf.text I18n.t('wstm.intro.pdf.desk_expenditure.text_05'), inline_format: true, align: :justify
    pdf.move_down 3.mm
    pdf.text "Gestionar primitor (Semnătuta)", align: :center
    pdf.text @object.name == "EMPTY" ? "" : @object.signed_by.name, align: :center
    pdf.move_down 10.mm
    pdf.text "Deţinător de deşeuri - persoană fizică", align: :center
    pdf.move_down 3.mm
    pdf.text I18n.t('wstm.intro.pdf.desk_expenditure.text_06')
    pdf.move_down 3.mm
    pdf.text "Deținător (Semnătuta)", align: :center
    pdf.text @object.name == "EMPTY" ? "" : @object.client.name, align: :center
  end
end

pdf = Prawn::Document.new(
  page_size: 'A4',
  page_layout: :landscape,
  margin: [0.mm],
  info: {
    Title: "Adeverinţă_Primire_Plata",
    Author: "kfl62",
    Subject: "Formular \"Adeverinţă de Primire şi Plată\"",
    Keywords: "#{firm.name[1].titleize} Adeverinţă Primire Plată",
    Creator: "http://#{firm.name[0].downcase}.trst.ro (using Sinatra, Prawn)",
    CreationDate: Time.now
  }
)
pdf.font_families.update(
  'Verdana' => {bold: 'public/stylesheets/fonts/verdanab.ttf',
                italic: 'public/stylesheets/fonts/verdanai.ttf',
                bold_italic: 'public/stylesheets/fonts/verdanaz.ttf',
                normal: 'public/stylesheets/fonts/verdana.ttf'})
pdf.font 'Verdana'
pdf.bounding_box([15.mm,200.mm],:width  => 123.mm, height: 190.mm) do
  box_content_app(pdf)
end
pdf.bounding_box([163.mm,200.mm],:width  => 123.mm, height: 190.mm) do
  box_content_app(pdf)
end
pdf.stroke_line(148.mm,5.mm,148.mm,10.mm)
pdf.stroke_line(148.mm,200.mm,148.mm,205.mm)

if frr? || @object.name == 'EMPTY'
  pdf.start_new_page(size: 'A4', layout: :landscape, margin: [0,0,0,0])
  pdf.font 'Verdana'
  pdf.bounding_box([15.mm,200.mm],:width  => 123.mm, height: 190.mm) do
    box_content_frr(pdf)
  end
  pdf.bounding_box([163.mm,200.mm],:width  => 123.mm, height: 190.mm) do
    box_content_frr(pdf)
  end
  pdf.stroke_line(148.mm,5.mm,148.mm,10.mm)
  pdf.stroke_line(148.mm,200.mm,148.mm,205.mm)
end

pdf.render()
