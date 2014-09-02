# encoding: utf-8
# Template for Wstm::Hmrs::EmployeeIlc#pdf

def firm
  Wstm::PartnerFirm.find_by(firm: true)
end
def address
  firm.addresses.first
end
case params[:fn].split('_')[0]
when 'CIM'
  copies = ["1. pentru Salariat", "2. pentru Angajator"]
  cim = @object.ilc
  id_doc_type = 'Cărţii de Identitate'
  id_doc_type = 'Buletinului de Identitate' if @object.id_doc['type'] == 'BI'
  id_doc_type = 'Paşaportului' if @object.id_doc['type'] == 'PS'
  pdf = Prawn::Document.new(
    page_size: 'A4',
    page_layout: :portrait,
    skip_page_creation: true,
    margin: [10.mm,10.mm,10.mm,20.mm],
    info: {
      Title: "Contract Individual de Muncă",
      Author: "kfl62",
      Subject: "Formular \"Contract Individual de Muncă\"",
      Keywords: "#{firm.name[1]} Contract Individual Muncă",
      Creator: "http://#{firm.name[0].downcase}.trst.ro (using Sinatra, Prawn)",
      CreationDate: Time.now
  })
  pdf.font_families.update(
    'Verdana' => {bold: 'public/stylesheets/fonts/verdanab.ttf',
                  italic: 'public/stylesheets/fonts/verdanai.ttf',
                  bold_italic: 'public/stylesheets/fonts/verdanaz.ttf',
                  normal: 'public/stylesheets/fonts/verdana.ttf'}
  )
  2.times do |n|
    pdf.start_new_page(template: "public/images/wstm/pdf/ilc_0.pdf")
    pdf.font 'Verdana'
    pdf.font_size = 8
    pdf.text firm.name[2]
    pdf.move_up 8
    pdf.text "Exemplarul nr.#{copies[n]}", size: 8, align: :right
    pdf.text "CIF #{firm.identities['fiscal']}"
    pdf.text "str. #{address.street}, nr. #{address.nr}, bl. #{address.bl}, sc. #{address.sc}, et. #{address.et}, ap. #{address.ap}"
    pdf.text "#{address.city}, jud. #{address.state}"
    pdf.text address.country
    pdf.text_box cim.drtn == 0 ? "Durata Nedeterminată" : "Durata Determinată",
      at: [0.mm, pdf.bounds.top - 85], width: 190.mm, align: :center, size: 11, style: :bold
    pdf.text_box cim.name,
      at: [162, pdf.bounds.top - 124], width: 120, align: :center, size: 9, style: :bold
    pdf.text_box firm.name[2].split(' ')[1..-1].join(' '),
      at: [170, pdf.bounds.top - 168], width: 140, align: :center, size: 9, style: :bold
    pdf.text_box address.street,
      at: [390, pdf.bounds.top - 168], width: 115, align: :center, size: 9, style: :bold
    pdf.text_box address.nr,
      at: [16, pdf.bounds.top - 184], width: 28, align: :center, size: 9, style: :bold
    pdf.text_box address.bl,
      at: [62, pdf.bounds.top - 184], width: 28, align: :center, size: 9, style: :bold
    pdf.text_box address.sc,
      at: [110, pdf.bounds.top - 184], width: 20, align: :center, size: 9, style: :bold
    pdf.text_box address.et,
      at: [150, pdf.bounds.top - 184], width: 20, align: :center, size: 9, style: :bold
    pdf.text_box address.ap,
      at: [195, pdf.bounds.top - 184], width: 20, align: :center, size: 9, style: :bold
    pdf.text_box address.city,
      at: [235, pdf.bounds.top - 184], width: 80, align: :center, size: 9, style: :bold
    pdf.text_box address.state,
      at: [335, pdf.bounds.top - 184], width: 65, align: :center, size: 9, style: :bold
    pdf.text_box address.zip,
      at: [455, pdf.bounds.top - 184], width: 55, align: :center, size: 9, style: :bold
    pdf.text_box address.state,
      at: [85, pdf.bounds.top - 201], width: 45, align: :center, size: 9, style: :bold
    pdf.text_box firm.identities['chambcom'],
      at: [197, pdf.bounds.top - 201], width: 95, align: :center, size: 9, style: :bold
    pdf.text_box firm.identities['fiscal'],
      at: [323, pdf.bounds.top - 201], width: 80, align: :center, size: 9, style: :bold
    pdf.text_box firm.contact['phone'],
      at: [424, pdf.bounds.top - 201], width: 85, align: :center, size: 9, style: :bold
    pdf.text_box firm.people.find_by(role: 'admin').name,
      at: [105, pdf.bounds.top - 218], width: 90, align: :center, size: 9, style: :bold
    pdf.text_box 'Administrator',
      at: [265, pdf.bounds.top - 218], width: 115, align: :center, size: 9, style: :bold
    pdf.text_box @object.name,
      at: [130, pdf.bounds.top - 266], width: 160, align: :center, size: 9, style: :bold
    pdf.text_box @object.address.street,
      at: [390, pdf.bounds.top - 266], width: 115, align: :center, size: 9, style: :bold
    pdf.text_box @object.address.nr,
      at: [16, pdf.bounds.top - 283], width: 28, align: :center, size: 9, style: :bold
    pdf.text_box @object.address.bl,
      at: [62, pdf.bounds.top - 283], width: 28, align: :center, size: 9, style: :bold
    pdf.text_box @object.address.sc,
      at: [110, pdf.bounds.top - 283], width: 20, align: :center, size: 9, style: :bold
    pdf.text_box @object.address.et,
      at: [150, pdf.bounds.top - 283], width: 20, align: :center, size: 9, style: :bold
    pdf.text_box @object.address.ap,
      at: [195, pdf.bounds.top - 283], width: 20, align: :center, size: 9, style: :bold
    pdf.text_box @object.address.city,
      at: [235, pdf.bounds.top - 283], width: 80, align: :center, size: 9, style: :bold
    pdf.text_box @object.address.state,
      at: [335, pdf.bounds.top - 283], width: 65, align: :center, size: 9, style: :bold
    pdf.text_box @object.address.zip,
      at: [455, pdf.bounds.top - 283], width: 55, align: :center, size: 9, style: :bold
    pdf.text_box @object.address.zip,
      at: [455, pdf.bounds.top - 283], width: 55, align: :center, size: 9, style: :bold
    pdf.text_box id_doc_type,
      at: [60, pdf.bounds.top - 300], width: 155, align: :center, size: 9, style: :bold
    pdf.text_box @object.id_doc['sr'],
      at: [230, pdf.bounds.top - 300], width: 25, align: :center, size: 9, style: :bold
    pdf.text_box @object.id_doc['nr'],
      at: [272, pdf.bounds.top - 300], width: 60, align: :center, size: 9, style: :bold
    pdf.text_box @object.id_doc['by'],
      at: [387, pdf.bounds.top - 300], width: 120, align: :center, size: 9, style: :bold
    pdf.text_box @object.id_doc['on'],
      at: [50, pdf.bounds.top - 316], width: 70, align: :center, size: 9, style: :bold
    pdf.text_box @object.id_pn,
      at: [145, pdf.bounds.top - 316], width: 95, align: :center, size: 9, style: :bold
    pdf.text_box '---',
      at: [16, pdf.bounds.top - 333], width: 30, align: :center, size: 9, style: :bold
    pdf.text_box '---',
      at: [70, pdf.bounds.top - 333], width: 45, align: :center, size: 9, style: :bold
    pdf.text_box '---',
      at: [160, pdf.bounds.top - 333], width: 65, align: :center, size: 9, style: :bold
    pdf.text_box cim.objct,
      at: [28, pdf.bounds.top - 402], width: 475, align: :center, size: 11, style: :bold
    pdf.text_box cim.drtn == 0 ? @object.name : '---',
      at: [205, pdf.bounds.top - 469], width: 145, align: :center, size: 9, style: :bold
    pdf.text_box cim.drtn == 0 ? cim.start.to_s : '---',
      at: [40, pdf.bounds.top - 485], width: 65, align: :center, size: 9, style: :bold
    pdf.text_box cim.drtn == 0 ? '---' : cim.drtn.to_s,
      at: [116, pdf.bounds.top - 502], width: 20, align: :center, size: 9, style: :bold
    pdf.text_box cim.drtn == 0 ? '---' : cim.start.to_s,
      at: [292, pdf.bounds.top - 502], width: 78, align: :center, size: 9, style: :bold
    pdf.text_box cim.drtn == 0 ? '---' : (cim.start + cim.drtn.month).to_s,
      at: [428, pdf.bounds.top - 502], width: 78, align: :center, size: 9, style: :bold
    pdf.text_box cim.wrkplc,
      at: [390, pdf.bounds.top - 584], width: 110, align: :center, size: 9, style: :bold
    pdf.text_box '---',
      at: [366, pdf.bounds.top - 606], width: 134, align: :center, size: 9, style: :bold
    pdf.text_box cim.cor,
      at: [118, pdf.bounds.top - 650], width: 175, align: :center, size: 9, style: :bold
    pdf.start_new_page(template: "public/images/wstm/pdf/ilc_1.pdf")
    pdf.text_box cim.wrkhrs == 8 ? '8' : '-',
      at: [275, pdf.bounds.top - 116], width: 20, align: :center, size: 9, style: :bold
    pdf.text_box cim.wrkhrs == 8 ? '40' : '-',
      at: [328, pdf.bounds.top - 116], width: 27, align: :center, size: 9, style: :bold
    pdf.text_box cim.wrkhrs == 8 ? cim.wrkprg : '---',
      at: [323, pdf.bounds.top - 132], width: 80, align: :center, size: 9, style: :bold
    pdf.text_box cim.wrkhrs == 8 ? '-' : cim.wrkhrs.to_s,
      at: [154, pdf.bounds.top - 181], width: 20, align: :center, size: 9, style: :bold
    pdf.text_box cim.wrkhrs == 8 ? '-' : (cim.wrkhrs * 5).to_s,
      at: [210, pdf.bounds.top - 181], width: 27, align: :center, size: 9, style: :bold
    pdf.text_box cim.wrkhrs == 8 ? '---' : cim.wrkprg,
      at: [323, pdf.bounds.top - 197], width: 80, align: :center, size: 9, style: :bold
    pdf.text_box cim.lieve.to_s,
      at: [240, pdf.bounds.top - 301], width: 27, align: :center, size: 9, style: :bold
    pdf.text_box '-',
      at: [305, pdf.bounds.top - 334], width: 27, align: :center, size: 9, style: :bold
    pdf.text_box cim.slry.to_s,
      at: [167, pdf.bounds.top - 373], width: 60, align: :center, size: 9, style: :bold
    [405,421,437,454,470,574,590,606,623].each do |y|
      pdf.text_box '- Conform ROI -', at: [300, pdf.bounds.top - y], size: 9, style: :bold
    end
    pdf.text_box '- Conform ROI -', at: [390, pdf.bounds.top - 639], size: 9, style: :bold
    pdf.text_box cim.pydys,
      at: [210, pdf.bounds.top - 536], width: 300, align: :center, size: 9, style: :bold
    pdf.text_box cim.prbtn.to_s,
      at: [162, pdf.bounds.top - 679], width: 27, align: :center, size: 9, style: :bold
    pdf.text_box cim.pdmss.to_s,
      at: [259, pdf.bounds.top - 696], width: 27, align: :center, size: 9, style: :bold
    pdf.text_box cim.prsgn.to_s,
      at: [248, pdf.bounds.top - 712], width: 27, align: :center, size: 9, style: :bold
    pdf.start_new_page(template: "public/images/wstm/pdf/ilc_2.pdf")
    pdf.text_box cim.ccm,
      at: [170, pdf.bounds.top - 483], width: 70, align: :center, size: 9, style: :bold
    pdf.text_box cim.ccm.length > 3 ? address.state : '-',
      at: [455, pdf.bounds.top - 483], width: 40, align: :center, size: 9, style: :bold
    pdf.text_box firm.name[2],
      at: [28, pdf.bounds.top - 625], width: 140, align: :center, size: 9, style: :bold
    pdf.text_box @object.name,
      at: [326, pdf.bounds.top - 625], width: 140, align: :center, size: 9, style: :bold
    pdf.text_box firm.people.find_by(role: 'admin').name,
      at: [28, pdf.bounds.top - 658], width: 140, align: :center, size: 9, style: :bold
    # pdf.stroke do
    #   pdf.rectangle [28, pdf.bounds.top - 658], 140, 10
    # end
  end
when 'CIM-AA'
  copies = ["1. pentru Salariat", "2. pentru Angajator"]
  pdf = Prawn::Document.new(
    page_size: 'A4',
    page_layout: :portrait,
    skip_page_creation: true,
    margin: [10.mm,10.mm,10.mm,20.mm],
    info: {
      Title: "Act Adiţional",
      Author: "kfl62",
      Subject: "Formular \"Act Adiţional\"",
      Keywords: "#{firm.name[1]} Act Adiţional",
      Creator: "http://#{firm.name[0].downcase}.trst.ro (using Sinatra, Prawn)",
      CreationDate: Time.now
  })
  pdf.font_families.update(
    'Verdana' => {bold: 'public/stylesheets/fonts/verdanab.ttf',
                  italic: 'public/stylesheets/fonts/verdanai.ttf',
                  bold_italic: 'public/stylesheets/fonts/verdanaz.ttf',
                  normal: 'public/stylesheets/fonts/verdana.ttf'}
  )
  2.times do |n|
    pdf.start_new_page(template: "public/images/wstm/pdf/addendum.pdf")
    pdf.font 'Verdana'
    pdf.font_size = 8
    pdf.text firm.name[2]
    pdf.move_up 8
    pdf.text "Exemplarul nr.#{copies[n]}", size: 8, align: :right
    pdf.text "CIF #{firm.identities['fiscal']}"
    pdf.text "str. #{address.street}, nr. #{address.nr}, bl. #{address.bl}, sc. #{address.sc}, et. #{address.et}, ap. #{address.ap}"
    pdf.text "#{address.city}, jud. #{address.state}"
    pdf.text address.country
  end
end
pdf.render()
