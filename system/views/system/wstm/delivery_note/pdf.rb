# encoding: utf-8
# Template for Wstm::DeliveryNote#pdf

def firm
  Wstm::PartnerFirm.find_by(firm: true)
end
def missing(length = 20, with = '_')
  '_'.ljust(length,with)
end
def firm_unit_details
  name = @object.unit.name[1]  rescue missing
  enva = @object.unit.env_auth rescue missing
  [name,enva]
end
def client_unit_details
  unit = @object.client.units.find_by(main: true) || @object.client.units.first
  name = unit.name[1]  rescue missing
  enva = unit.env_auth rescue missing
  trna = unit.trn_auth rescue ''
  [name,enva,trna]
end
def freights
  @object.freights.each_with_object({}) do |f,h|
    key = f.id_stats
    if h[key].nil?
      h[key] = [f.freight.name, f.freight.code[0], f.qu]
    else
      h[key][2] += f.qu
    end
  end
end
def box_content(pdf,top,left)
  pdf.bounding_box([left,top], width: 130.mm, height: 14) do
    pdf.text "Formular de încărcare-descărcare deşeuri nepericuloase", style: :bold, size: 10, align: :center, valign: :center
    top -= 14
  end
  pdf.bounding_box([left,top], width: 130.mm, height: 14) do
    pdf.indent 10.mm do
      pdf.text "Serie şi număr: #{@object.name} din #{@object.id_date.to_s}", style: :bold, size: 8, valign: :center
    end
    pdf.stroke_bounds
    top -= 14
  end
  pdf.bounding_box([left,top], width: 110.mm, height: 14) do
    pdf.text "Caracteristici deşeuri", style: :bold, size: 8, align: :center, valign: :center
    pdf.stroke_bounds
    top -= 14
  end
  pdf.bounding_box([left,top], width: 80.mm, height: 14) do
    pdf.text "Denumire", style: :bold, size: 8, align: :center, valign: :center
    pdf.stroke_bounds
  end
  pdf.bounding_box([left + 80.mm,top], width: 30.mm, height: 14) do
    pdf.text "Cod", style: :bold, size: 8, align: :center, valign: :center
    pdf.stroke_bounds
  end
  pdf.bounding_box([left + 110.mm,top + 14 ], width: 20.mm, height: 28) do
    pdf.move_down 6
    pdf.text "Cantitate", style: :bold, size: 8, align: :center
    pdf.text "-kg-", style: :bold, size: 8, align: :center
    pdf.stroke_bounds
    top -= 14
  end
  pdf.bounding_box([left,top], width: 80.mm, height: 56) do
    # Freight
    pdf.move_down 4
    pdf.indent 10.mm do
      fsize = freights.count > 6 ? 6 : 8
      freights.values.each_with_index do |f,i|
        pdf.text "#{i + 1}.) Deşeuri #{f[0].downcase}",style: :bold,size: fsize
      end
    end
    pdf.stroke_bounds
  end
  pdf.bounding_box([left + 80.mm,top], width: 30.mm, height: 56) do
    # Cod
    pdf.move_down 4
    fsize = freights.count > 6 ? 6 : 8
    freights.values.each_with_index do |f,i|
      pdf.text "-#{f[1]}-", style: :bold,align: :center,size: fsize
    end
    pdf.stroke_bounds
  end
  pdf.bounding_box([left + 110.mm,top], width: 20.mm, height: 56) do
    # Quantity
    pdf.move_down 4
    pdf.indent 0,3.mm do
      fsize = freights.count > 6 ? 6 : 8
      freights.values.each_with_index do |f,i|
        pdf.text "%.2f" % f[2].round(2), style: :bold,align: :right,size: fsize
      end
    end
    pdf.stroke_bounds
    top -= 56
  end
  pdf.bounding_box([left,top], width: 130.mm, height: 14) do
    pdf.text "Destinat", style: :bold, size: 8, align: :center, valign: :center
    pdf.stroke_bounds
    top -= 14
  end
  pdf.bounding_box([left,top], width: 130.mm, height: 28) do
    pdf.text "Colectării |_| Stocării temp. |_| Tratării |_| Valorificării |_| Eliminării |_|", style: :bold, size: 8, align: :center, valign: :center
    pdf.stroke_bounds
    top -= 28
  end
  pdf.bounding_box([left,top], width: 130.mm, height: 14) do
    pdf.text "Documente însoţitoare", style: :bold, size: 8, align: :center, valign: :center
    pdf.stroke_bounds
    top -= 14
  end
  pdf.bounding_box([left,top], width: 65.mm, height: 14) do
    pdf.text "Încărcare", style: :bold, size: 8, align: :center, valign: :center
    pdf.stroke_bounds
  end
  pdf.bounding_box([left + 65.mm,top], width: 65.mm, height: 14) do
    pdf.text "Descărcare", style: :bold, size: 8, align: :center, valign: :center
    pdf.stroke_bounds
    top -= 14
  end
  pdf.bounding_box([left,top], width: 65.mm, height: 28) do
    # id_main_doc
    pdf.text "AE nr. #{@object.doc_name}/#{@object.id_date.to_s}", style: :bold, size: 8, align: :center, valign: :center
    pdf.stroke_bounds
  end
  pdf.bounding_box([left + 65.mm,top], width: 65.mm, height: 28) do
    pdf.stroke_bounds
    top -= 28
  end
  pdf.bounding_box([left,top], width: 130.mm, height: 14) do
    pdf.text "Date identificare expeditor", style: :bold, size: 8, align: :center, valign: :center
    pdf.stroke_bounds
    top -= 14
  end
  pdf.bounding_box([left,top], width: 130.mm, height: 56) do
    pdf.bounding_box([5.mm, 50], width: 25.mm) do
      pdf.text "Firma:", style: :bold, size: 8
      pdf.text "CCI:", style: :bold, size: 8,leading: 2
      pdf.text "CUI:", style: :bold, size: 8,leading: 2
      pdf.text "Punct de lucru:", style: :bold, size: 8,leading: 2
      pdf.text "Aut. mediu:", style: :bold, size: 8,leading: 2
    end
    pdf.bounding_box([30.mm, 50], width: 105.mm) do
      pdf.text firm.name[2], style: :bold, size: 8
      pdf.text firm.identities['chambcom'], style: :bold, size: 8,leading: 2
      pdf.text firm.identities['fiscal'], style: :bold, size: 8,leading: 2
      pdf.text firm_unit_details[0], style: :bold, size: 8,leading: 2
      pdf.text firm_unit_details[1], style: :bold, size: 8,leading: 2
    end
    pdf.stroke_bounds
    top -= 56
  end
  pdf.bounding_box([left,top], width: 130.mm, height: 42) do
    pdf.bounding_box([0.mm,30], width: 80.mm) do
      pdf.text "Gestionar\n#{ @object.signed_by.name}", style: :bold, size: 8, align: :center
    end
    pdf.bounding_box([80.mm,25], width: 50.mm) do
      pdf.indent 0,3.mm do
        pdf.text "Semnătură/Ştampilă", style: :bold, size: 8, align: :right
      end
    end
    pdf.stroke_bounds
    top -= 42
  end
  pdf.bounding_box([left,top], width: 130.mm, height: 14) do
    pdf.text "Date identificare destinatar", style: :bold, size: 8, align: :center, valign: :center
    pdf.stroke_bounds
    top -= 14
  end
  pdf.bounding_box([left,top], width: 130.mm, height: 56) do
    pdf.bounding_box([5.mm, 50], width: 25.mm) do
      pdf.text "Firma:", style: :bold, size: 8
      pdf.text "CCI:", style: :bold, size: 8,leading: 2
      pdf.text "CUI:", style: :bold, size: 8,leading: 2
      pdf.text "Punct de lucru:", style: :bold, size: 8,leading: 2
      pdf.text "Aut. mediu:", style: :bold, size: 8,leading: 2
    end
    pdf.bounding_box([30.mm, 50], width: 105.mm) do
      pdf.text @object.client.name[2], style: :bold, size: 8
      pdf.text @object.client.identities['chambcom'], style: :bold, size: 8,leading: 2
      pdf.text @object.client.identities['fiscal'], style: :bold, size: 8,leading: 2
      pdf.text client_unit_details[0], style: :bold, size: 8,leading: 2
      pdf.text client_unit_details[1], style: :bold, size: 8,leading: 2
    end
    pdf.stroke_bounds
    top -= 56
  end
  pdf.bounding_box([left,top], width: 130.mm, height: 42) do
    pdf.indent 0,3.mm do
      pdf.text "Semnătură/Ştampilă", style: :bold, size: 8, align: :right, valign: :center
    end
    pdf.stroke_bounds
    top -= 42
  end
  pdf.bounding_box([left,top], width: 130.mm, height: 14) do
    pdf.stroke_bounds
    pdf.text "Date identificare transportator", style: :bold, size: 8, align: :center, valign: :center
    top -= 14
  end
  pdf.bounding_box([left,top], width: 130.mm, height: 56) do
    pdf.bounding_box([5.mm, 50], width: 25.mm) do
      pdf.text "Firma:", style: :bold, size: 8
      pdf.text "Delegat:", style: :bold, size: 8,leading: 2
      pdf.text "CNP:", style: :bold, size: 8,leading: 2
      pdf.text "Auto Nr:", style: :bold, size: 8,leading: 2
      pdf.text "Licenţa de tran", style: :bold, size: 8,leading: 2
    end
    pdf.bounding_box([30.mm, 50], width: 105.mm) do
      pdf.text @object.transp.name[2], style: :bold, size: 8
      pdf.text @object.transp_d.name, style: :bold, size: 8,leading: 2
      pdf.text @object.transp_d.id_pn, style: :bold, size: 8,leading: 2
      pdf.text @object.doc_plat.upcase, style: :bold, size: 8,leading: 2
      pdf.text "sport expiră la date de: #{client_unit_details[2]}", style: :bold, size: 8,leading: 2
    end
    pdf.stroke_bounds
    top -= 56
  end
  pdf.bounding_box([left,top], width: 130.mm, height: 42) do
    pdf.indent 0,3.mm do
      pdf.text "Semnătură/Ştampilă", style: :bold, size: 8, align: :right, valign: :center
    end
    pdf.stroke_bounds
  end
end

pdf = Prawn::Document.new(
  page_size: 'A4',
  page_layout: :landscape,
  margin: [0.mm],
  #background: "public/images/pdf/ae_a3.jpg",
  info: {
    Title: "Formular de încărcare-descărcare deşeuri nepericuloase",
    Author: "kfl62",
    Subject: "Formular \"Încărcare-descărcare deşeuri nepericuloase\"",
    Keywords: "#{firm.name[1].titleize} Formular de încărcare-descărcare deşeuri nepericuloase",
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

# Ex. 1
box_content(pdf,pdf.bounds.top - 10.mm,10.mm)
# Ex. 2
box_content(pdf,pdf.bounds.top - 10.mm,160.mm)

pdf.stroke_line(148.mm,5.mm,148.mm,10.mm)
pdf.stroke_line(148.mm,200.mm,148.mm,205.mm)

pdf.render()
