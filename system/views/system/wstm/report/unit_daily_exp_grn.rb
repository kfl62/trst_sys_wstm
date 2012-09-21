# encoding: utf-8
# Template for Nota de recepţie APP.pdf
require 'prawn/measurement_extensions'

period     = params[:period].to_i
unit_ids   = params[:unit_ids].split(',').map{|id| Moped::BSON::ObjectId(id)}
date_start = params[:date].split('-').map(&:to_i)

def firm
  Wstm::PartnerFirm.find_by(:firm => true)
end

def address
  firm.addresses.first
end

pdf = Prawn::Document.new(
  :page_size => 'A4',
  :page_layout => :landscape,
  :skip_page_creation => true,
  :background => "public/images/wstm/pdf/nir.jpg",
  :margin => [0.mm],
  :info => {
    :Title => "Notă de recepţie APP",
    :Author => "kfl62",
    :Subject => "Formular \"Notă de recepţie APP\"",
    :Keywords => "#{firm.name[1]} Notă Recepţie Primire Plată",
    :Creator => "http://#{firm.name[0].downcase}.trst.ro (using Sinatra, Prawn)",
    :CreationDate => Time.now
})
pdf.font_families.update(
  'Verdana' => {:bold => 'public/stylesheets/fonts/verdanab.ttf',
                :italic => 'public/stylesheets/fonts/verdanai.ttf',
                :bold_italic => 'public/stylesheets/fonts/verdanaz.ttf',
                :normal => 'public/stylesheets/fonts/verdana.ttf'}
)

unless Wstm::Expenditure.where(:unit_id.in => unit_ids).period(*date_start,period).count > 0
  pdf.start_new_page
  pdf.render()
end
unit_ids.each_with_index do |unit_id,next_unit|
  data = {}
  period.times do |next_day|
    y,m,d  = date_start; d = d + next_day
    unit   = Wstm::PartnerFirm.unit_by_unit_id(unit_id)
    data = {}
    # Parse db for data
    apps = Wstm::Expenditure.where(unit_id: unit_id, id_date: Date.new(y,m,d))
    if apps.count > 0
      signed_by =  unit.chief.include?(',') ? apps.last.signed_by.name : unit.chief
      sum_100 = apps.sum(:sum_100)
      apps.asc(:name).each do |a|
        a.freights.each do |f|
          key = "#{f.freight.id_stats}_#{f.pu}"
          if data[key].nil?
            data[key] = [f.freight.name, f.um, f.qu, f.pu, (f.pu * f.qu).round(2)]
          else
            data[key][2] += f.qu
            data[key][4] += (f.pu * f.qu).round(2)
          end
        end
      end
      data = data.values.sort.each_with_index { |d, i| d.unshift("#{i + 1}.") }
      data.map!{|e| [e[0],e[1],e[2],"%.2f" %e[3],"%.2f" %e[4],"%.2f" %e[5]]}
      data.push(["","TOTAL","","","","%.2f" %sum_100])
      # @todo
      pdf.start_new_page
      pdf.font 'Verdana'
      pdf.text_box unit.firm.name[2],
        :at => [33.mm, pdf.bounds.top - 8.mm], :size => 12, :style => :bold
      pdf.text_box "Pct. lucru: #{unit.name[1]}",
        :at => [33.mm, pdf.bounds.top - 13.mm], :size => 9
      pdf.text_box Date.new(y,m,d).to_s,
        :at => [228.mm, pdf.bounds.top - 7.mm], :size => 12, :style => :bold
      pdf.text_box "Document cumulativ",
        :at => [25.mm, pdf.bounds.top - 30.mm], :size => 10
      pdf.text_box Date.new(y,m,d).to_s,
        :at => [110.mm, pdf.bounds.top - 30.mm], :size => 10
      pdf.text_box "Adeverinţe Primire/Plată\nconf. Document cumulativ",
        :at => [230.mm, pdf.bounds.top - 29.mm], :size => 8, :leading => -1
      pdf.text_box "Nu este cazul",
        :at => [70.mm, pdf.bounds.top - 48.mm], :size => 10
      pdf.text_box "Nu este cazul",
        :at => [210.mm, pdf.bounds.top - 48.mm], :size => 10
      pdf.text_box signed_by,
        :at => [195.mm, 12.mm], :size => 10
      pdf.text_box signed_by,
        :at => [250.mm, 12.mm], :size => 10

      pdf.bounding_box([15.mm, pdf.bounds.top - 70.mm], :width  => pdf.bounds.width) do
        pdf.table(data, :cell_style => {:borders => []}, :column_widths => [12.mm,60.mm,10.mm,20.mm,20.mm,25.mm]) do
          pdf.font_size = 9
          column(0).style(:align => :right, :padding => [5,10,5,0])
          column(3..5).style(:align => :right)
          row(data.length-1).columns(1).style(:align => :center)
        end
      end
    end
  end
end
pdf.render()
