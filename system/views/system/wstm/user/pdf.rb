# encoding: utf-8
# Template for Wstm::User#pdf
require 'prawn/measurement_extensions'
require "prawn/templates"

def firm
  Wstm::PartnerFirm.find_by(:firm => true)
end
def address
  firm.addresses.first
end
def unit
  user.unit
end
def user
  Wstm::User.find(params[:user_ids])
end
def work_stats_data
  y,m = params[:p_y].to_i,params[:p_m].to_i
  user.work_stats(y,m)
end
def daily_activity(d)
  data = []
  data << ["Ziau", "Login", "APP" ,"Valoare", "06-08", "08-10","10-12","12-14","14-16","16-18","18-20"]
  data += d.day.map{|a| [a[0],*a[1]]}
  data << [{content: 'Total', colspan: 2},*data.transpose.map{|x| x[1..-1].reduce :+ }[2..-1]]
  data.each{|a| a.map!{|x| x.is_a?(Float) ? "%.2f" % x : x}}
end

pdf = Prawn::Document.new(
  page_size: 'A4',
  page_layout: :portrait,
  skip_page_creation: true,
  margin: [10.mm],
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
pdf.start_new_page
pdf.font 'Verdana'
pdf.font_size 8 do
  pdf.text "#{firm.name[2]}"
  pdf.move_up 9
  pdf.text "Punct de lucru: #{unit.name[1]}", align: :right
  pdf.text "Nr.înreg.R.C. : #{firm.identities['chambcom']}"
  pdf.move_up 9
  pdf.text "Aut. de mediu: #{unit.env_auth.split(" ")[0]}", align: :right
  pdf.text "Cod fiscal (C.U.I) : #{firm.identities['fiscal']}"
  pdf.move_up 9
  pdf.text "Gestionar: #{user.name}", align: :right
  pdf.text "Str.#{address.street} nr.#{address.nr},bl.#{address.bl},sc.#{address.sc},ap.#{address.ap},"
  pdf.text 'Cluj-Napoca, judeţul Cluj'
end
pdf.move_down 5.mm
pdf.text "Statistică lunară #{I18n.l(work_stats_data.id_date,format: '%B, %Y')}", align: :center, size: 12, style: :bold
pdf.move_down 5.mm
pdf.table daily_activity(work_stats_data), cell_style: {size: 8}, position: :center do
  row(0).style(align: :center, background_color: "f9f9f9", padding:[5,5])
  column(2..3).rows(1..-1).style(align: :right)
  column(4..10).style(align: :center)
  row(-1).style(align: :center, background_color: "f9f9f9", padding:[5,5])
end
pdf.move_down 10.mm
pdf.text "Total zile lucrate <b>#{work_stats_data.wdy.to_i}</b>, media zilnică de bani achitați <b>#{"%.2f" % work_stats_data.avg}</b> lei... (Date suplimentare în curând)", inline_format: true, size: 9, align: :center
pdf.render()
