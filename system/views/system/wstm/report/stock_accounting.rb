# encoding: utf-8
# Template for Sitaţie lunară (Contabilă).pdf
require 'prawn/measurement_extensions'
require "prawn/templates"

def date_strt
  params[:date].split('-').map(&:to_i)
end
def date_next
  if Date.today.month == date_strt[1]
    [2000,1,31]
  else
    Date.new(*date_strt,1).next_month.to_s.split('-')[0..1].map(&:to_i)
  end
end
def mny
  Wstm::Cache.stats_all(*date_strt,{mny_all: true,exp_all:true}).each_with_object({}){|e,h| h[e[0]]=e[2..-1]}
end
def firm
  Wstm::PartnerFirm.find_by(firm: true)
end
def address
  firm.addresses.first
end
def main_data
  ins,outs,stks = Wstm::FreightIn,Wstm::FreightOut,Wstm::FreightStock
  keys = (ins.monthly(*date_strt).keys + outs.monthly(*date_strt).keys + stks.monthly(*date_strt).where(:qu.ne => 0.0).keys + stks.stock_now.where(:qu.ne => 0.0).keys).uniq.sort
  keys.each_with_object({}) do |k,h|
    id_stats, pu = k.split('_')
    name = "#{Wstm::Freight.find_by(id_stats: id_stats).name}_#{id_stats}"
    data = [
      pu.to_f,
      stks.by_key(k).sum_stks(*date_strt,{what: :qu}),
      stks.by_key(k).sum_stks(*date_strt,{what: :val}),
      ins.by_key(k).where(:doc_grn.ne => nil).nonin.sum_ins(*date_strt,{what: :qu}),
      ins.by_key(k).where(:doc_grn.ne => nil).nonin.sum_ins(*date_strt,{what: :val}),
      #ins.by_key(k).where(:doc_grn.ne => nil).nonin(false).sum_ins(*date_strt,{what: :qu}),
      #ins.by_key(k).where(:doc_grn.ne => nil).nonin(false).sum_ins(*date_strt,{what: :val}),
      ins.by_key(k).or({:doc_grn.ne => nil},{:doc_sor.ne => nil}).nonin(false).sum_ins(*date_strt,{what: :qu}),
      ins.by_key(k).or({:doc_grn.ne => nil},{:doc_sor.ne => nil}).nonin(false).sum_ins(*date_strt,{what: :val}),
      ins.by_key(k).where(:doc_exp.ne => nil).sum_ins(*date_strt,{what: :qu}),
      ins.by_key(k).where(:doc_exp.ne => nil).sum_ins(*date_strt,{what: :val}),
      #outs.by_key(k).where(:doc_dln.ne => nil).nonin(false).sum_outs(*date_strt,{what: :qu}),
      #outs.by_key(k).where(:doc_dln.ne => nil).nonin(false).sum_outs(*date_strt,{what: :val}),
      outs.by_key(k).or({:doc_dln.ne => nil},{:doc_sor.ne => nil}).nonin(false).sum_outs(*date_strt,{what: :qu}),
      outs.by_key(k).or({:doc_dln.ne => nil},{:doc_sor.ne => nil}).nonin(false).sum_outs(*date_strt,{what: :val}),
      outs.by_key(k).where(:doc_dln.ne => nil).nonin.sum_outs(*date_strt,{what: :qu}),
      outs.by_key(k).where(:doc_dln.ne => nil).nonin.sum_outs(*date_strt,{what: :val}),
      outs.by_key(k).where(:doc_dln.ne => nil).nonin.sum_outs(*date_strt,{what: :val_invoice}),
      outs.by_key(k).where(:doc_cas.ne => nil).sum_outs(*date_strt,{what: :qu}),
      outs.by_key(k).where(:doc_cas.ne => nil).sum_outs(*date_strt,{what: :val}),
      stks.by_key(k).sum_stks(*date_next,{what: :qu}),
      stks.by_key(k).sum_stks(*date_next,{what: :val})
    ]
    (h[name].nil? ? h[name] = [data] : h[name] << data) unless data.sum == k.split('_')[1].to_f
  end
end
pdf = Prawn::Document.new(
  page_size: 'A4',
  page_layout: :landscape,
  skip_page_creation: true,
  margin: [10.mm],
  info: {
    Title: "Sitaţie lunară (Contabilă)",
    Author: "kfl62",
    Subject: "Formular \"Sitaţie lunară (Contabilă)\"",
    Keywords: "#{firm.name[1]} Stoc Inventar Valoric Situaţie Lunară",
    Creator: "http://#{firm.name[0].downcase}.trst.ro (using Sinatra, Prawn)",
    CreationDate: Time.now
})
pdf.font_families.update(
  'Verdana' => {bold: 'public/stylesheets/fonts/verdanab.ttf',
                italic: 'public/stylesheets/fonts/verdanai.ttf',
                bold_italic: 'public/stylesheets/fonts/verdanaz.ttf',
                normal: 'public/stylesheets/fonts/verdana.ttf'}
)
rows,r_gt = main_data, {}
pdf.start_new_page(template: "public/images/wstm/pdf/stock_stats.pdf")
pdf.font 'Verdana'
pdf.font_size = 8
pdf.text firm.name[2]
pdf.text "Nr. înreg. R.C. : #{firm.identities['chambcom']}"
pdf.text "Cod Fiscal (C.U.I.) : #{firm.identities['fiscal']}"
pdf.text "Str. #{address.street},nr.#{address.nr rescue '-'},bl.#{address.bl rescue '-'},sc.#{address.sc rescue '-'},et.#{address.et rescue '-'},ap.#{address.ap rescue '-'}"
pdf.text "#{address.city rescue '-'}, județul #{address.state rescue '-'}"
pdf.move_up 30
pdf.text "Situaţie lunară: #{I18n.l(Date.new(*date_strt,1),format: '%B')} - #{firm.name[1]} -",
  align: :center, size: 12, style: :bold
pdf.bounding_box([pdf.bounds.left - 0.3, pdf.bounds.top - 80], width: pdf.bounds.width) do
  rows.each_pair do |k,v|
    r_gt[k.split('_')[1]] = v.transpose.map {|x| (x.reduce(:+)).round(2)}
    r_gt[k.split('_')[1]][0] = k.split('_')[1]
    n = v.clone
    n.push(n.transpose.map {|x| (x.reduce(:+)).round(2)})
    n.each{|a| a.map!{|e| "%.2f" % e}}
    n.last[0] = 'Total'
    d = pdf.make_table(n, cell_style: {padding: [2,3,2,0], align: :right, border_width: 0.1}, column_widths: [29,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm]) do
      row(row_length - 1).style(background_color: "e6e6e6")
    end
    if pdf.y - d.height < 20.mm
      pdf.start_new_page(template: "public/images/wstm/pdf/stock_stats.pdf", template_page: 2)
      pdf.move_up 21.5.mm
    end
    data =  [
              ["Sortiment: #{k.split('_')[0]}"],
              [d]
            ]
    pdf.table(data, cell_style: {border_width: 0.1}) do
      pdf.font_size 6
      row(0).style(background_color: "f9f9f9", padding: [2,5,2,5])
    end
  end
end
pdf.start_new_page(template: "public/images/wstm/pdf/stock_stats.pdf")
pdf.font_size = 8
pdf.text firm.name[2]
pdf.text "Nr. înreg. R.C. : #{firm.identities['chambcom']}"
pdf.text "Cod Fiscal (C.U.I.) : #{firm.identities['fiscal']}"
pdf.text "Str. #{address.street},nr.#{address.nr rescue '-'},bl.#{address.bl rescue '-'},sc.#{address.sc rescue '-'},et.#{address.et rescue '-'},ap.#{address.ap rescue '-'}"
pdf.text "#{address.city rescue '-'}, județul #{address.state rescue '-'}"
pdf.font_size = 6
pdf.bounding_box([pdf.bounds.left - 0.3, pdf.bounds.top - 81], width: pdf.bounds.width) do
  pdf.move_up 23.5.mm
  pdf.text "Centralizator: #{I18n.l(Date.new(*date_strt,1),format: '%B')} - #{firm.name[1]} -",
    align: :center, size: 12, style: :bold
  pdf.move_down 52.5
  v = r_gt.values_at('1101','1202','1201').compact
  unless v.empty?
    names = v.each_with_object([]){|a,n| n << a.shift}
    names.push('Total')
    v.push(v.transpose.map {|x| (x.reduce(:+)).round(2)})
    v.each{|a| a.map!{|e| "%.2f" % e}}
    names.each_with_index{|n,i| v[i].unshift(n)}
    d = pdf.make_table(v, cell_style: {padding: [2,3,2,0], align: :right, border_width: 0.1}, column_widths: [29,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm]) do
      row(row_length - 1).style(background_color: "e6e6e6")
    end
    data =  [
              ["Categoria: Hârtie şi Carton"],
              [d]
            ]
    pdf.table(data, cell_style: {border_width: 0.1}) do
      row(0).style(background_color: "f9f9f9", padding: [2,5,2,5])
    end
  end
  v = r_gt.values_at('2101','2102','2201').compact
  unless v.empty?
    names = v.each_with_object([]){|a,n| n << a.shift}
    names.push('Total')
    v.push(v.transpose.map {|x| (x.reduce(:+)).round(2)})
    v.each{|a| a.map!{|e| "%.2f" % e}}
    names.each_with_index{|n,i| v[i].unshift(n)}
    d = pdf.make_table(v, cell_style: {padding: [2,3,2,0], align: :right, border_width: 0.1}, column_widths: [29,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm]) do
      row(row_length - 1).style(background_color: "e6e6e6")
    end
    data =  [
              ["Categoria: Folie, PET şi PVC"],
              [d]
            ]
    pdf.table(data, cell_style: {border_width: 0.1}) do
      row(0).style(background_color: "f9f9f9", padding: [2,5,2,5])
    end
  end
  v = r_gt.values_at('3011').compact
  unless v.empty?
    names = v.each_with_object([]){|a,n| n << a.shift}
    names.push('Total')
    v.push(v.transpose.map {|x| (x.reduce(:+)).round(2)})
    v.each{|a| a.map!{|e| "%.2f" % e}}
    names.each_with_index{|n,i| v[i].unshift(n)}
    d = pdf.make_table(v, cell_style: {padding: [2,3,2,0], align: :right, border_width: 0.1}, column_widths: [29,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm]) do
      row(row_length - 1).style(background_color: "e6e6e6")
    end
    data =  [
              ["Categoria: Fier"],
              [d]
            ]
    pdf.table(data, cell_style: {border_width: 0.1}) do
      row(0).style(background_color: "f9f9f9", padding: [2,5,2,5])
    end
  end
  v = r_gt.values_at('3101','3201','3202','3301','3401','3501','3601','3602','3701').compact
  unless v.empty?
    names = v.each_with_object([]){|a,n| n << a.shift}
    names.push('Total')
    v.push(v.transpose.map {|x| (x.reduce(:+)).round(2)})
    v.each{|a| a.map!{|e| "%.2f" % e}}
    names.each_with_index{|n,i| v[i].unshift(n)}
    d = pdf.make_table(v, cell_style: {padding: [2,3,2,0], align: :right, border_width: 0.1}, column_widths: [29,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm]) do
      row(row_length - 1).style(background_color: "e6e6e6")
    end
    data =  [
              ["Categoria: Metale neferoase (Alamă, Aluminiu, Doze aluminiu, Cupru, Inox, Plumb, Radiatoare alamă, Radiatoare aluminiu și Zamac)"],
              [d]
            ]
    pdf.table(data, cell_style: {border_width: 0.1}) do
      row(0).style(background_color: "f9f9f9", padding: [2,5,2,5])
    end
  end
  v = r_gt.values_at('4001').compact
  unless v.empty?
    names = v.each_with_object([]){|a,n| n << a.shift}
    names.push('Total')
    v.push(v.transpose.map {|x| (x.reduce(:+)).round(2)})
    v.each{|a| a.map!{|e| "%.2f" % e}}
    names.each_with_index{|n,i| v[i].unshift(n)}
    d = pdf.make_table(v, cell_style: {padding: [2,3,2,0], align: :right, border_width: 0.1}, column_widths: [29,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm]) do
      row(row_length - 1).style(background_color: "e6e6e6")
    end
    data =  [
              ["Categoria: Baterii auto"],
              [d]
            ]
    pdf.table(data, cell_style: {border_width: 0.1}) do
      row(0).style(background_color: "f9f9f9", padding: [2,5,2,5])
    end
  end
  v = r_gt.values_at('5001').compact
  unless v.empty?
    names = v.each_with_object([]){|a,n| n << a.shift}
    names.push('Total')
    v.push(v.transpose.map {|x| (x.reduce(:+)).round(2)})
    v.each{|a| a.map!{|e| "%.2f" % e}}
    names.each_with_index{|n,i| v[i].unshift(n)}
    d = pdf.make_table(v, cell_style: {padding: [2,3,2,0], align: :right, border_width: 0.1}, column_widths: [29,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm]) do
      row(row_length - 1).style(background_color: "e6e6e6")
    end
    data =  [
              ["Categoria: DEEE"],
              [d]
            ]
    pdf.table(data, cell_style: {border_width: 0.1}) do
      row(0).style(background_color: "f9f9f9", padding: [2,5,2,5])
    end
  end
  v = r_gt.values_at('6001').compact
  unless v.empty?
    names = v.each_with_object([]){|a,n| n << a.shift}
    names.push('Total')
    v.push(v.transpose.map {|x| (x.reduce(:+)).round(2)})
    v.each{|a| a.map!{|e| "%.2f" % e}}
    names.each_with_index{|n,i| v[i].unshift(n)}
    d = pdf.make_table(v, cell_style: {padding: [2,3,2,0], align: :right, border_width: 0.1}, column_widths: [29,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm]) do
      row(row_length - 1).style(background_color: "e6e6e6")
    end
    data =  [
              ["Categoria: Motor electric"],
              [d]
            ]
    pdf.table(data, cell_style: {border_width: 0.1}) do
      row(0).style(background_color: "f9f9f9", padding: [2,5,2,5])
    end
  end
  v = r_gt.values_at('7001').compact
  unless v.empty?
    names = v.each_with_object([]){|a,n| n << a.shift}
    names.push('Total')
    v.push(v.transpose.map {|x| (x.reduce(:+)).round(2)})
    v.each{|a| a.map!{|e| "%.2f" % e}}
    names.each_with_index{|n,i| v[i].unshift(n)}
    d = pdf.make_table(v, cell_style: {padding: [2,3,2,0], align: :right, border_width: 0.1}, column_widths: [29,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm]) do
      row(row_length - 1).style(background_color: "e6e6e6")
    end
    data =  [
              ["Categoria: Deșeu lemn"],
              [d]
            ]
    pdf.table(data, cell_style: {border_width: 0.1}) do
      row(0).style(background_color: "f9f9f9", padding: [2,5,2,5])
    end
  end
  v = r_gt.values
  v.each{|a| a.shift}
  v.each{|a| a.map!{|e| e.to_f}}
  sum = v.transpose.map{|x| "%.2f" % (x.reduce(:+)).round(2)}
  d = pdf.make_table([sum.unshift(' ')], cell_style: {padding: [2,3,2,0], align: :right, border_width: 0.1}, column_widths: [29,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm,15.46.mm]) do
    row(row_length - 1).style(background_color: "e6e6e6")
  end
  data =  [
            ["Total general"],
            [d]
          ]
  pdf.table(data, cell_style: {border_width: 0.1}) do
    row(0).style(background_color: "f9f9f9", padding: [2,5,2,5])
  end
end
pdf.bounding_box([pdf.bounds.left, pdf.bounds.bottom + 8], width: pdf.bounds.width) do
  pdf.font_size 6 do
    pdf.text "Notă: În tabel coloana preţ conţine codurile interne a materialelor! Ele sunt în ordinea înşirată din capul de tabel."
  end
end
pdf.start_new_page(size: "A4", layout: :landscape, margins: [10.mm])
pdf.font_size = 8
pdf.text firm.name[2]
pdf.text "Nr. înreg. R.C. : #{firm.identities['chambcom']}"
pdf.text "Cod Fiscal (C.U.I.) : #{firm.identities['fiscal']}"
pdf.text "Str. #{address.street},nr.#{address.nr rescue '-'},bl.#{address.bl rescue '-'},sc.#{address.sc rescue '-'},et.#{address.et rescue '-'},ap.#{address.ap rescue '-'}"
pdf.text "#{address.city rescue '-'}, județul #{address.state rescue '-'}"
pdf.move_up 30
pdf.text "Centralizator: #{I18n.l(Date.new(*date_strt,1),format: '%B')} - #{firm.name[1]} - (recapitulare)",
  align: :center, size: 12, style: :bold
top = pdf.bounds.top - 25.mm
pdf.bounding_box([5.mm, top], width: 60.mm) do
  pdf.text "Monetar puncte de colectare", align: :center
end
pdf.bounding_box([75.mm, top], width: 70.mm) do
  pdf.text "Mişcări marfă (valoric)", align: :center
end
pdf.bounding_box([155.mm, top], width: 120.mm) do
  pdf.text "Sume reţinute (de virat)", align: :center
end
top -= 5.mm
pdf.bounding_box([5.mm, top], width: 30.mm) do
  pdf.text "Sold iniţial"
  pdf.text "Avansuri pct."
  pdf.text "Plătit achiziţii"
  pdf.text "Alte plăţi (PV)"
  pdf.text "Sold final"
end
pdf.bounding_box([35.mm, top], width: 30.mm) do
  pdf.text "%.2f" % mny['Id'][0], align: :right
  pdf.text "%.2f" % mny['Id'][1], align: :right
  pdf.text "%.2f" % mny['Id'][5], align: :right
  pdf.text "%.2f" % mny['Id'][2], align: :right
  pdf.text "%.2f" % mny['Id'][7], align: :right
end
pdf.bounding_box([75.mm, top], width: 40.mm) do
  pdf.text "Stoc iniţial"
  pdf.text "Intrări facturi"
  pdf.text "Intrări transfer gestiune"
  pdf.text "Intrări achiziţii"
  pdf.text "Ieşiri transfer gestiune"
  pdf.text "Ieşiri val. cumpărare"
  pdf.text "Ieşiri val. vânzare"
  pdf.text "Ieşiri casare"
  pdf.text "Stoc final"
end
pdf.bounding_box([115.mm, top], width: 30.mm) do
  ins = Wstm::FreightIn
  outs= Wstm::FreightOut
  stks= Wstm::FreightStock
  pdf.text "%.2f" % stks.sum_stks(*date_strt,{what: :val}), align: :right
  pdf.text "%.2f" % ins.where(:doc_grn.ne => nil).nonin.sum_ins(*date_strt,{what: :val}), align: :right
  #pdf.text "%.2f" % ins.where(:doc_grn.ne => nil).nonin(false).sum_ins(*date_strt,{what: :val}), align: :right
  pdf.text "%.2f" % ins.or({:doc_grn.ne => nil},{:doc_sor.ne => nil}).nonin(false).sum_ins(*date_strt,{what: :val}), align: :right
  pdf.text "%.2f" % ins.where(:doc_exp.ne => nil).sum_ins(*date_strt,{what: :val}), align: :right
  #pdf.text "%.2f" % outs.where(:doc_dln.ne => nil).nonin(false).sum_outs(*date_strt,{what: :val}), align: :right
  pdf.text "%.2f" % outs.or({:doc_dln.ne => nil},{:doc_sor.ne => nil}).nonin(false).sum_outs(*date_strt,{what: :val}), align: :right
  pdf.text "%.2f" % outs.where(:doc_dln.ne => nil).nonin.sum_outs(*date_strt,{what: :val}), align: :right
  pdf.text "%.2f" % outs.where(:doc_dln.ne => nil).nonin.sum_outs(*date_strt,{what: :val_invoice}), align: :right
  pdf.text "%.2f" % outs.where(:doc_cas.ne => nil).sum_outs(*date_strt,{what: :val}), align: :right
  pdf.text "%.2f" % stks.sum_stks(*date_next,{what: :val}), align: :right
end
pdf.bounding_box([155.mm, top], width: 55.mm) do
  pdf.text "Sursa"
  pdf.text "Taxă mediu 3% (fier)"
  pdf.text "Taxă mediu 3% (neferoase)"
  pdf.text "Taxă mediu 3% (baterii)"
  pdf.text "Total 3% pe surse"
  pdf.text " "
  pdf.text "Taxă mediu 3% de virat"
  pdf.text "Impozit venit 16% de virat"
end
pdf.bounding_box([210.mm, top], width: 25.mm) do
  pdf.text "APP",align: :right
  ins = Wstm::FreightIn.where(:doc_exp.ne => nil).monthly(*date_strt)
  pdf.text "%.2f" % (ins.by_key('3011').each_with_object([]){|f,a| a << (f.pu * f.qu * 0.03)}.sum || 0), align: :right
  pdf.text "%.2f" % (ins.where(:id_stats.in => ['3101','3201','3202','3401','3301','3501','3601','3602,3701']).each_with_object([]){|f,a| a << (f.pu * f.qu * 0.03)}.sum || 0), align: :right
  pdf.text "%.2f" % (ins.by_key('4001').where(:doc_exp.ne => nil).each_with_object([]){|f,a| a << (f.pu * f.qu * 0.03)}.sum || 0), align: :right
  pdf.text "<b>#{"%.2f" % mny['Id'][3]}</b>", align: :right, inline_format: true
  pdf.text " "
  pdf.text "<b>#{"%.2f" % (mny['Id'][3] + Wstm::Grn.nonin.monthly(*date_strt).sum(:sum_003))}</b>", align: :right, inline_format: true
  pdf.text "<b>#{"%.2f" % mny['Id'][4]}</b>", align: :right, inline_format: true
end
pdf.bounding_box([235.mm, top], width: 25.mm) do
  ins = Wstm::FreightIn.where(:doc_grn.ne => nil).monthly(*date_strt).nonin
  pdf.text "Firme",align: :right
  pdf.text "%.2f" % (ins.by_key('3011').each_with_object([]){|f,a| a << (f.pu * f.qu * 0.03) if f.doc.supplr.p03}.sum || 0), align: :right
  pdf.text "%.2f" % (ins.where(:id_stats.in => ['3101','3201','3202','3401','3301','3501','3601','3602,3701']).each_with_object([]){|f,a| a << (f.pu * f.qu * 0.03) if f.doc.supplr.p03}.sum || 0), align: :right
  pdf.text "%.2f" % (ins.by_key('4001').each_with_object([]){|f,a| a << (f.pu * f.qu * 0.03) if f.doc.supplr.p03}.sum || 0), align: :right
  pdf.text "<b>#{"%.2f" % (Wstm::Grn.nonin.monthly(*date_strt).sum(:sum_003) || 0)}</b>", align: :right, inline_format: true
end
pdf.render()
