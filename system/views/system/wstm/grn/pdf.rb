# encoding: utf-8
# Template for Wstm::Grn#pdf

def firm
  Wstm::PartnerFirm.find_by(firm: true)
end
def supplier(o = nil)
  o ||= @object
  Wstm::PartnerFirm.find(o.supplr_id)
end
def unit(o = nil)
  o ||= @object
  firm.units.find(o.unit_id)
end
def signed_by(o = nil)
  o ||= @object
  unit.chief.include?(o.signed_by.name) ? o.signed_by.name : unit.chief.split(',').first
end
def delegate(o = nil)
  o ||= @object
  Wstm::PartnerFirm.find(o.transp_id).people.find(o.transp_d_id)
end
def payment(o = nil)
  o ||= @object
  if o.id_intern
    r = ['Nu este cazul.','Transfer intern!']
  else
    if o.doc_type == 'MIN'
      r = ['Nu este cazul.','PV fără valoare!']
    elsif o.doc_type == 'DN'
      r = ['Nu este cazul.','Se va completa la facturare!']
    elsif o.doc_type == 'INV'
      r = o.doc_inv.pyms_list
    else
      r = ['-']
    end
  end
  r.join("\n")
end
def table_data(o = nil)
  o ||= @object
  data, sum_100 = {}, o.sum_100
  if o.id_intern
    o.dlns.each do |dn|
      dn.freights.each do |f|
        k = f.key
        if data[k].nil?
          data[k] = [f.freight.name,f.um,f.qu,f.pu,f.val,["#{dn.doc_name} #{ "%.2f" % f.qu}"]]
        else
          data[k][2] += f.qu
          data[k][4] += f.val
          data[k][5] << ["#{dn.doc_name} #{ "%.2f" % f.qu}"]
        end
      end
    end
    data = data.values.sort.each_with_index{|r,i| r.unshift("#{i + 1}.")}
    data.map!{|r| [r[0],r[1],r[2],"%.2f" % r[3],"%.2f" % r[4],"%.2f" % r[5],r[6].join('; ')]}
    data.push(["","TOTAL","","","","%.2f" % sum_100,""])
  else
    o.freights.each do |f|
      k = f.key
      if data[k].nil?
        data[k] = [f.freight.name,f.um,f.qu,f.pu,f.val]
      else
        data[k][2] += f.qu
        data[k][4] += f.val
      end
    end
    data = data.values.sort.each_with_index{|r,i| r.unshift("#{i + 1}.")}
    data.map!{|r| [r[0],r[1],r[2],"%.2f" % r[3],"%.2f" % r[4],"%.2f" % r[5],""]}
    data.push(["","TOTAL","","","","%.2f" % sum_100,""])
  end
  data
end
pdf = Prawn::Document.new(
  page_size: 'A4',
  page_layout: :landscape,
  skip_page_creation: true,
  margin: [0.mm],
  info: {
    Title: "Notă de recepţie",
    Author: "kfl62",
    Subject: "Formular \"Notă de recepţie\"",
    Keywords: "#{firm.name[1]} Notă de recepţie ",
    Creator: "http://#{firm.name[0].downcase}.trst.ro (using Sinatra, Prawn)",
    CreationDate: Time.now
  }
)
pdf.font_families.update(
  'Verdana' => {bold: 'public/stylesheets/fonts/verdanab.ttf',
                italic: 'public/stylesheets/fonts/verdanai.ttf',
                bold_italic: 'public/stylesheets/fonts/verdanaz.ttf',
                normal: 'public/stylesheets/fonts/verdana.ttf'})
data = table_data(@object)
if data.length > 16
  data_ext= data[17..-1]
  data    = data[0..16]
end unless data.length == 17
pdf.start_new_page(template: "public/images/wstm/pdf/grn.pdf")
pdf.font 'Verdana'
pdf.text_box firm.name[2],
             at: [33.mm, pdf.bounds.top - 8.mm], style: :bold
# pdf.text_box "Nr.intern #{@object.name}",
#              at: [175.mm, pdf.bounds.top - 13.mm], size: 8
pdf.text_box @object.id_date.to_s,
             at: [235.mm, pdf.bounds.top - 8.mm], size: 10, style: :bold
if @object.id_intern
  pdf.text_box mat(@object,"doc_type_#{@object.doc_type}").concat(" #{@object.doc_name}"),
               at: [16.mm, pdf.bounds.top - 30.mm], width: 91.mm, size: 8
else
  pdf.text_box mat(@object,"doc_type_#{@object.doc_type}"),
               at: [13.mm, pdf.bounds.top - 30.mm], width: 63.mm, align: :center, size: 10
  pdf.text_box @object.doc_name,
               at: [75.mm, pdf.bounds.top - 30.mm], width: 28.mm, align: :center, size: 10
  pdf.text_box @object.doc_date.to_s,
               at: [100.mm, pdf.bounds.top - 30.mm], width: 37.mm, align: :center, size: 10
end
pdf.text_box supplier.name[2],
             at: [140.mm, pdf.bounds.top - 30.mm], width: 44.mm, align: :center, size: 9
pdf.text_box "#{supplier.identities["fiscal"] rescue '-'}",
             at: [183.mm, pdf.bounds.top - 30.mm], width: 38.mm, align: :center, size: 9
pdf.text_box payment(@object),
             at: [222.mm, pdf.bounds.top - 29.mm], width: 63.mm, align: :left, size: 8
pdf.text_box "#{delegate.name rescue 'Fără delegat'}",
             at: [43.mm, pdf.bounds.top - 48.mm], width: 92.mm, align: :center, size: 10
pdf.text_box "#{@object.doc_plat.upcase rescue '-'}",
             at: [175.mm, pdf.bounds.top - 48.mm], width: 105.mm, align: :center, size: 10
pdf.text_box signed_by,
             at: [195.mm, 12.mm], size: 10
pdf.text_box signed_by,
             at: [250.mm, 12.mm], size: 10
pdf.bounding_box([15.mm, pdf.bounds.top - 70.mm], :width  => pdf.bounds.width) do
  pdf.table(data, cell_style: {borders: []}, column_widths: [12.mm,60.mm,12.mm,25.mm,25.mm,25.mm,120.mm]) do
    pdf.font_size = 9
    column(0).style(align: :right, padding: [5,10,5,0])
    column(2).style(align: :center)
    column(3..5).style(align: :right)
    row(data.length - 1).columns(1).style(align: :center) unless data_ext
    (0..data.length - 1).each do |i|
      if data[i].last.length > 160
        row(i).columns(6).style(size: 7,height: 14.mm, padding: [2,0,0,5])
      else data[i].last.split('; ').length > 10
        row(i).columns(6).style(size: 7,height: 7.mm, padding: [2,0,0,5])
      end
    end
  end
end
if data_ext
  pdf.start_new_page(template: "public/images/wstm/pdf/grn.pdf",template_page: 2)
  pdf.bounding_box([15.mm, pdf.bounds.top - 30.mm], :width  => pdf.bounds.width) do
    pdf.table(data_ext, cell_style: {borders: []}, column_widths: [12.mm,60.mm,12.mm,25.mm,25.mm,25.mm]) do
      pdf.font_size = 9
      column(0).style(align: :right, padding: [5,10,5,0])
      column(2).style(align: :center)
      column(3..5).style(align: :right)
      row(data_ext.length-1).columns(1).style(align: :center)
      (0..data.length - 1).each do |i|
        if data[i].last.length > 160
          row(i).columns(6).style(size: 7,height: 14.mm, padding: [2,0,0,5])
        else data[i].last.split('; ').length > 10
          row(i).columns(6).style(size: 7,height: 7.mm, padding: [2,0,0,5])
        end
      end
    end
  end
end
pdf.render()
