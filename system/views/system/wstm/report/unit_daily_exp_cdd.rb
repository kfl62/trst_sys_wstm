# encoding: utf-8
# Template for Document cumulativ APP.pdf
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

def freight_name(name)
  ary = name.split(" ")
  case ary.length
   when 1
     ary[0][0..3].upcase
   when 2
     ary[0][0..1].upcase + ary[1][0..1].upcase
   when 3
     ary[0][0..1].upcase + ary[1][0].upcase + ary[2][0].upcase
   else
     "ERR"
   end
end

def client_name(client)
  n = client.name[0..17] << (client.name.length > 17 ? '.' : '')
  t = "Str.#{client.address.street} nr.#{client.address.nr},#{client.address.city}"
  txt = t[0..35] << (t.length > 35 ? '.' : '')
  "#{n} (#{client.id_pn})" +
  "\n#{txt}"
end

def check_header(hl,fs)
  fs.each do |f, col_name|
    col_name = "#{freight_name(f.freight.name)}_#{"%.2f" % f.pu}"
    hl.push(col_name) unless hl.include?(col_name)
  end
  hl.length < 17 ? true : false
end

pdf = Prawn::Document.new(
  :page_size => 'A4',
  :page_layout => :landscape,
  :skip_page_creation => true,
  :margin => [10.mm,5.mm],
  :info => {
    :Title => "Document Cumulativ",
    :Author => "kfl62",
    :Subject => "Formular \"Document cumulativ APP\"",
    :Keywords => "#{firm.name[1]} Document Cumulativ Primire Plată",
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
  header,hl,data,header_extra,data_extra,data_sum,sum_qu,sum_val,j,k = [],[],[],[],[],[],{},{},0,0
  period.times do |next_day|
    y,m,d  = date_start; d = d + next_day
    unit   = Wstm::PartnerFirm.unit_by_unit_id(unit_id)
    header,hl,data,header_extra,data_extra,data_sum,sum_qu,sum_val,j,k = [],[],[],[],[],[],{},{},0,0
    # Parse db for data
    apps = Wstm::Expenditure.where(unit_id: unit_id, id_date: Date.new(y,m,d))
    if apps.count > 0
      sum_100 = apps.sum(:sum_100)
      sum_003 = apps.sum(:sum_003)
      sum_016 = apps.sum(:sum_016)
      sum_out = apps.sum(:sum_out)

      apps.asc(:name).each_with_index do |a,i|
        h = Hash.new
        if check_header(hl, a.freights)
          data[j] = ["#{i + 1}.","#{client_name(a.client)}","#{a.name.gsub(/[_,-]/,' ')}"]
          a.freights.each do |f; col_name|
            col_name = "#{freight_name(f.freight.name)}_#{"%.2f" % f.pu}"
            hl.push(col_name) unless hl.include?(col_name)
            header.push(col_name) unless header.include?(col_name)
            h[col_name] = "%.2f" % f.qu
            sum_qu[col_name].nil? ? sum_qu[col_name] = f.qu : sum_qu[col_name] += f.qu
            sum_val[col_name].nil? ? sum_val[col_name] = (f.qu * f.pu).round(2) : sum_val[col_name] += (f.qu * f.pu).round(2)
          end
          data[j].push(h)
          data[j].push("%.2f" % a.sum_100,"%.2f" % a.sum_out)
          j += 1
        else
          data_extra[k] = ["#{i + 1}.","#{client_name(a.client)}","#{a.name.gsub(/[_,-]/,' ')}"]
          a.freights.asc(:name).each do |f; col_name|
            col_name = "#{freight_name(f.freight.name)}_#{"%.2f" % f.pu}"
            hl.push(col_name) unless hl.include?(col_name)
            header_extra.push(col_name) unless header_extra.include?(col_name)
            h[col_name] = "%.2f" % f.qu
            sum_qu[col_name].nil? ? sum_qu[col_name] = f.qu : sum_qu[col_name] += f.qu
            sum_val[col_name].nil? ? sum_val[col_name] = (f.qu * f.pu).round(2) : sum_val[col_name] += (f.qu * f.pu).round(2)
          end
          data_extra[k].push(h)
          data_extra[k].push("%.2f" % a.sum_100,"%.2f" % a.sum_out)
          k += 1
        end
      end
      header_sum = (header + header_extra).uniq.sort
      data_sum.push(header_sum,sum_qu,sum_val)
      # Main table
      header.sort!
      data.each do |d|
        ary = header.map do |h|
          if d[3].has_key? h
            d[3][h]
          else
            ""
          end
        end
        d[3] = ary
        d.flatten!
      end
      header.unshift("Nr","Nume (CNP)\nAdresa", "Nr. Adeverinţă")
      header.map!{|h| h.gsub('_',"\n")}
      header.push("Valoare","Achitat")
      data.unshift(header)
      data.each do |d|
        (21 - d.length).times {d.insert(-3," ")}
      end
      # Extra table
      unless header_extra.empty?
        header_extra.sort!
        data_extra.each do |d|
          ary = header_extra.map do |h|
            if d[3].has_key? h
              d[3][h]
            else
              ""
            end
          end
          d[3] = ary
          d.flatten!
        end
        header_extra.unshift("Nr","Nume (CNP)\nAdresa", "Nr. Adeverinţă")
        header_extra.map!{|h| h.gsub('_',"\n")}
        header_extra.push("Valoare","Achitat")
        data_extra.unshift(header_extra)
        data_extra.each do |d|
          (21 - d.length).times {d.insert(-3," ")}
        end
      end
      # Total table
      data_sum[1..2].each_with_index do |d,i|
        ary = data_sum[0].map do |h|
          if d.has_key? h
            "%.2f" % d[h]
          else
            ""
          end
        end
        data_sum[i + 1] = ary
      end
      ["Total","Cantitativ","Valoric"].each_with_index{|d,i| data_sum[i].unshift(d)}
      data_sum[0].map! {|h| h.gsub('_'," ")}
      #pdf.start_new_page
      pdf.create_stamp("pg_header_#{next_unit}_#{next_day}") do
        pdf.bounding_box([pdf.bounds.left, pdf.bounds.top], :width  => pdf.bounds.width) do
          pdf.font 'Verdana'
          pdf.font_size 8 do
            pdf.text unit.firm.name[2]
            pdf.text unit.name[1]
          end
          pdf.move_up 12
          pdf.font_size 12 do
            pdf.text "Document cumulativ nr.______ din #{Date.new(y,m,d).to_s}", :align => :center, :style => :bold
          end
        end
      end
      pdf.start_new_page
      pdf.font 'Verdana'
      pdf.stamp("pg_header_#{next_unit}_#{next_day}")
      pdf.bounding_box([pdf.bounds.left, pdf.bounds.top - 10.mm], :width  => pdf.bounds.width) do
        pdf.table(data, :header => true,:column_widths => [7.mm, 53.mm, 20.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 14.mm, 14.mm]) do
          pdf.font_size 7
          row(0).style(:align => :center)
          column(0).rows(1..100).style(:align => :right, :padding => [6,3,4,2])
          column(1..2).rows(1..100).style(:padding => [2,0,2,5])
          column(3..21).rows(1..100).style(:align => :right,:padding => [6,2,0,0])
        end
        unless header_extra.empty?
          pdf.move_down 5.mm
          unless data.length == 25
            pdf.text "Numărul de sortimente depăşeşte lăţimea max. a tabelului! Continuare în pg. urmatoare..."
            pdf.start_new_page
            pdf.stamp("pg_header_#{next_unit}_#{next_day}")
          end
          pdf.table(data_extra, :header => true,:column_widths => [7.mm, 53.mm, 20.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 14.mm, 14.mm]) do
            pdf.font_size 7
            row(0).style(:align => :center)
            column(0).rows(1..100).style(:align => :right, :padding => [6,3,4,2])
            column(1..2).rows(1..100).style(:padding => [2,0,2,5])
            column(3..21).rows(1..100).style(:align => :right,:padding => [6,2,0,0])
          end
        end
        pdf.move_down 5.mm
        if hl.length > 17
        else
          table_sum = pdf.make_table(data_sum, :header => true) do
            pdf.font_size 7
            [25.mm, *[14.mm]*data_sum[0].length].each_with_index do |w,i|
              column(i).width = w
            end
            row(0).style(:align => :center)
            column(0).rows(1..5).style(:padding => [3,5])
            column(1..(data_sum[0].length)).rows(1..5).style(:align => :right, :padding => [3,3])
          end
        end
        if pdf.y - table_sum.height < 30.mm
          pdf.start_new_page
          pdf.stamp("pg_header_#{next_unit}_#{next_day}")
        end
        table_sum.draw
        pdf.move_down 5.mm
        pdf.font_size 8
        pdf.text "În data de #{Date.new(y,m,d).to_s} din total rulaj <b>#{"%.2f" % sum_100}</b> RON s-au reţinut <b>#{"%.2f" % sum_003}</b> RON (3% Taxă mediu), <b>#{"%.2f" % sum_016}</b> RON (16% impozit) şi s-a achitat în numerar <b>#{"%.2f" % sum_out}</b> RON.", :inline_format => true
      end
    end
  end
end
pdf.render()
