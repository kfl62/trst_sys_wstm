# encoding: utf-8

def firm
  Wstm::PartnerFirm.find_by(firm: true)
end

def signed_by(o = nil)
  o ||= @object
  o.signed_by.name
end

if @object.dlns.empty?
  # Template for Wstm::Grn#pdf
  def supplier(o = nil)
    o ||= @object
    Wstm::PartnerFirm.find(o.client_id)
  end
  def delegate(o = nil)
    o ||= @object
    supplier(o).people.find(o.client_d_id)
  end
  def table_data(o = nil)
    o ||= @object
    data, sum_100 = {}, o.sum_100
    o.grns.asc(:doc_name).each do |grn|
      grn.freights.each do |f|
        k = f.key
        if data[k].nil?
          data[k] = [f.freight.name,f.um,f.qu,f.pu,f.val,["#{grn.doc_name} #{ "%.2f" % f.qu}"]]
        else
          data[k][2] += f.qu
          data[k][4] += f.val
          data[k][5] << ["#{grn.doc_name} #{ "%.2f" % f.qu}"]
        end
      end
    end
    data = data.values.sort.each_with_index{|r,i| r.unshift("#{i + 1}.")}
    data.map!{|r| [r[0],r[1],r[2],"%.2f" % r[3],"%.2f" % r[4],"%.2f" % r[5],r[6].join('; ')]}
    data.push(["","TOTAL","","","","%.2f" % sum_100,""])
  end
  pdf = Prawn::Document.new(
    page_size: 'A4',
    page_layout: :landscape,
    margin: [0.mm],
    skip_page_creation: true,
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
  pdf.start_new_page(template: "public/images/wstm/pdf/grn.pdf")
  pdf.font 'Verdana'
  pdf.text_box firm.name[2],
               at: [33.mm, pdf.bounds.top - 8.mm], style: :bold
  # pdf.text_box "Nr.intern #{@object.name}",
  #              at: [175.mm, pdf.bounds.top - 13.mm], size: 8
  pdf.text_box @object.id_date.to_s,
               at: [235.mm, pdf.bounds.top - 8.mm], size: 10, style: :bold
  pdf.text_box "AE nr: #{@object.grns.map(&:doc_name).join(', ')}",
               at: [16.mm, pdf.bounds.top - 30.mm], width: 91.mm, size: 8
  pdf.text_box supplier.name[2],
               at: [140.mm, pdf.bounds.top - 30.mm], width: 44.mm, align: :center, size: 9
  pdf.text_box "#{supplier.identities["fiscal"] rescue '-'}",
               at: [183.mm, pdf.bounds.top - 30.mm], width: 38.mm, align: :center, size: 9
  pdf.text_box @object.pyms_list.join("\n"),
                at: [222.mm, pdf.bounds.top - 29.mm], width: 63.mm, align: :left, size: 8
  pdf.text_box "#{delegate.name rescue 'Fără delegat'}",
               at: [43.mm, pdf.bounds.top - 48.mm], width: 92.mm, align: :center, size: 10
  pdf.text_box "Nu este cazul (document cumulat)",
               at: [175.mm, pdf.bounds.top - 48.mm], width: 105.mm, align: :center, size: 9
  pdf.text_box signed_by,
               at: [195.mm, 12.mm], size: 10
  pdf.text_box signed_by,
               at: [250.mm, 12.mm], size: 10
  pdf.bounding_box([15.mm, pdf.bounds.top - 70.mm], :width  => pdf.bounds.width) do
    data = table_data(@object)
    pdf.table(data, cell_style: {borders: []}, column_widths: [12.mm,60.mm,12.mm,25.mm,25.mm,25.mm,120.mm]) do
      pdf.font_size = 9
      column(0).style(align: :right, padding: [5,10,5,0])
      column(2).style(align: :center)
      column(3..5).style(align: :right)
      row(data.length - 1).columns(1).style(align: :center)
      (0..data.length - 1).each do |i|
        if data[i].last.length > 160
          row(i).columns(6).style(size: 7,height: 14.mm, padding: [2,0,0,5])
        else data[i].last.split('; ').length > 10
          row(i).columns(6).style(size: 7,height: 7.mm, padding: [2,0,0,5])
        end
      end
    end
  end
else
  # Template for Wstm::Invoice#pdf
  pdf = Prawn::Document.new(
    page_size: 'A4',
    page_layout: :portrait,
    margin: [10.mm],
    info: {
      Title: "Facturare",
      Author: "kfl62",
      Subject: "Formular \"Facturare\"",
      Keywords: "#{firm.name[1].titleize} Facturare",
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
  pdf.text 'Încă nu este gata..., Anexaţi formularul completat manual!'
end
pdf.render()
