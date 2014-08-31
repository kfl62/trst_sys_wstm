# encoding: utf-8
# Template for Document cumulativ APP.pdf

period     = params[:period].to_i
unit_ids   = params[:unit_ids].split(',').map{|id| Moped::BSON::ObjectId(id)}
date_start = params[:date].split('-').map(&:to_i)
ext        = params[:ext]

def firm
  Wstm::PartnerFirm.find_by(firm: true)
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
  skip_page_creation: true,
  info: {
    Title: "Notă de recepţie APP",
    Author: "kfl62",
    Subject: "Formular \"Notă de recepţie APP\"",
    Keywords: "#{firm.name[1]} Notă Recepţie Primire Plată",
    Creator: "http://#{firm.name[0].downcase}.trst.ro (using Sinatra, Prawn)",
    CreationDate: Time.now
})
pdf.font_families.update(
  'Verdana' => {bold: 'public/stylesheets/fonts/verdanab.ttf',
                italic: 'public/stylesheets/fonts/verdanai.ttf',
                bold_italic: 'public/stylesheets/fonts/verdanaz.ttf',
                normal: 'public/stylesheets/fonts/verdana.ttf'}
)

unless Wstm::Expenditure.where(:unit_id.in => unit_ids).period(*date_start,period).count > 0
  pdf.start_new_page
  pdf.render()
end
unit_ids.each_with_index do |unit_id,next_unit|
  data, data_ext = {}, []
  period.times do |next_day|
    y,m,d  = date_start; d = d + next_day
    unit   = Wstm::PartnerFirm.unit_by_unit_id(unit_id)
    # Parse db for data
    apps = Wstm::Expenditure.where(unit_id: unit_id, id_date: Date.new(y,m,d))
    if apps.count > 0
      sum_100 = apps.sum(:sum_100)
      sum_003 = apps.sum(:sum_003)
      sum_016 = apps.sum(:sum_016)
      sum_out = apps.sum(:sum_out)
      signed_by =  unit.chief.include?(',') ? apps.last.signed_by.name : unit.chief
      if ['grn', 'all'].include? ext
        data_grn_ext = []
        data_grn = apps.asc(:name).each_with_object({}) do |a,d|
          a.freights.each_with_object(d) do |f,d|
            key = "#{f.freight.id_stats}_#{f.pu}"
            if d[key].nil?
              d[key] = [f.freight.name, f.um, f.qu, f.pu, (f.pu * f.qu).round(2)]
            else
              d[key][2] += f.qu
              d[key][4] += (f.pu * f.qu).round(2)
            end
          end
        end
        data_grn = data_grn.values.sort.each_with_index { |d, i| d.unshift("#{i + 1}.") }
        data_grn.map!{|e| [e[0],e[1],e[2],"%.2f" %e[3],"%.2f" %e[4],"%.2f" %e[5]]}
        data_grn.push(["","TOTAL","","","","%.2f" %sum_100])
        if data_grn.length > 16
          data_grn_ext= data_grn[17..-1]
          data_grn    = data_grn[0..16]
        end unless data_grn.length == 17
        # @todo
        pdf.start_new_page(size: 'A4', layout: :landscape, margin:0, template: "public/images/wstm/pdf/grn.pdf")
        pdf.font 'Verdana'
        pdf.text_box unit.firm.name[2],
          at: [33.mm, pdf.bounds.top - 8.mm], size: 12, style: :bold
        pdf.text_box "Pct. lucru: #{unit.name[1]}",
          at: [33.mm, pdf.bounds.top - 13.mm], size: 9
        pdf.text_box Date.new(y,m,d).to_s,
          at: [235.mm, pdf.bounds.top - 8.mm], size: 12, style: :bold
        pdf.text_box "Document cumulativ",
          at: [25.mm, pdf.bounds.top - 30.mm], size: 10
        pdf.text_box Date.new(y,m,d).to_s,
          at: [110.mm, pdf.bounds.top - 30.mm], size: 10
        pdf.text_box "Adeverinţe Primire/Plată\nconf. Document cumulativ",
          at: [230.mm, pdf.bounds.top - 29.mm], size: 8, leading: -1
        pdf.text_box "Nu este cazul",
          at: [70.mm, pdf.bounds.top - 48.mm], size: 10
        pdf.text_box "Nu este cazul",
          at: [210.mm, pdf.bounds.top - 48.mm], size: 10
        pdf.text_box signed_by,
          at: [195.mm, 12.mm], size: 10
        pdf.text_box signed_by,
          at: [250.mm, 12.mm], size: 10
        pdf.bounding_box([15.mm, pdf.bounds.top - 70.mm], :width  => pdf.bounds.width) do
          pdf.table(data_grn, cell_style: {borders: []}, column_widths: [12.mm,60.mm,12.mm,25.mm,25.mm,25.mm]) do
            pdf.font_size = 9
            column(0).style(align: :right, padding: [5,10,5,0])
            column(2).style(align: :center)
            column(3..5).style(align: :right)
            row(data_grn.length-1).columns(1).style(align: :center) unless data_grn_ext.length > 0
          end
        end
        if data_grn_ext.length > 0
          pdf.start_new_page(size: 'A4', layout: :landscape, margin:0, template: "public/images/wstm/pdf/grn.pdf",template_page: 2)
          pdf.text_box signed_by, at: [195.mm, 12.mm], size: 10
          pdf.text_box signed_by, at: [250.mm, 12.mm], size: 10
          pdf.bounding_box([15.mm, pdf.bounds.top - 30.mm], :width  => pdf.bounds.width) do
            pdf.table(data_grn_ext, cell_style: {borders: []}, column_widths: [12.mm,60.mm,12.mm,25.mm,25.mm,25.mm]) do
              pdf.font_size = 9
              column(0).style(align: :right, padding: [5,10,5,0])
              column(2).style(align: :center)
              column(3..5).style(align: :right)
              row(data_grn_ext.length-1).columns(1).style(align: :center) unless data_ext.length > 0
            end
          end
        end
      end
      # unit_daily_exp_cdd
      if ['cdd', 'all'].include? ext
        header,header_ext,hl,data_cdd,data_cdd_ext,data_cdd_sum,sum_qu,sum_val,j,k = [],[],[],[],[],[],{},{},0,0
        apps.asc(:name).each_with_index do |a,i|
          h = Hash.new
          if check_header(hl, a.freights)
            data_cdd[j] = ["#{i + 1}.","#{client_name(a.client)}","#{a.name.gsub(/[_,-]/,' ')}"]
            a.freights.each do |f; col_name|
              col_name = "#{freight_name(f.freight.name)}_#{"%.2f" % f.pu}"
              hl.push(col_name) unless hl.include?(col_name)
              header.push(col_name) unless header.include?(col_name)
              h[col_name] = "%.2f" % f.qu
              sum_qu[col_name].nil? ? sum_qu[col_name] = f.qu : sum_qu[col_name] += f.qu
              sum_val[col_name].nil? ? sum_val[col_name] = (f.qu * f.pu).round(2) : sum_val[col_name] += (f.qu * f.pu).round(2)
            end
            data_cdd[j].push(h)
            data_cdd[j].push("%.2f" % a.sum_100,"%.2f" % a.sum_out)
            j += 1
          else
            data_cdd_ext[k] = ["#{i + 1}.","#{client_name(a.client)}","#{a.name.gsub(/[_,-]/,' ')}"]
            a.freights.asc(:name).each do |f; col_name|
              col_name = "#{freight_name(f.freight.name)}_#{"%.2f" % f.pu}"
              hl.push(col_name) unless hl.include?(col_name)
              header_ext.push(col_name) unless header_ext.include?(col_name)
              h[col_name] = "%.2f" % f.qu
              sum_qu[col_name].nil? ? sum_qu[col_name] = f.qu : sum_qu[col_name] += f.qu
              sum_val[col_name].nil? ? sum_val[col_name] = (f.qu * f.pu).round(2) : sum_val[col_name] += (f.qu * f.pu).round(2)
            end
            data_cdd_ext[k].push(h)
            data_cdd_ext[k].push("%.2f" % a.sum_100,"%.2f" % a.sum_out)
            k += 1
          end
        end
        header_sum = (header + header_ext).uniq.sort
        data_cdd_sum.push(header_sum,sum_qu,sum_val)
        # Main table
        header.sort!
        data_cdd.each do |d|
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
        data_cdd.unshift(header)
        data_cdd.each do |d|
          (21 - d.length).times {d.insert(-3," ")}
        end
        # Extra table
        unless header_ext.empty?
          header_ext.sort!
          data_cdd_ext.each do |d|
            ary = header_ext.map do |h|
              if d[3].has_key? h
                d[3][h]
              else
                ""
              end
            end
            d[3] = ary
            d.flatten!
          end
          header_ext.unshift("Nr","Nume (CNP)\nAdresa", "Nr. Adeverinţă")
          header_ext.map!{|h| h.gsub('_',"\n")}
          header_ext.push("Valoare","Achitat")
          data_cdd_ext.unshift(header_ext)
          data_cdd_ext.each do |d|
            (21 - d.length).times {d.insert(-3," ")}
          end
        end
        # Total table
        data_cdd_sum[1..2].each_with_index do |d,i|
          ary = data_cdd_sum[0].map do |h|
            if d.has_key? h
              "%.2f" % d[h]
            else
              ""
            end
          end
          data_cdd_sum[i + 1] = ary
        end
        ["Total","Cantitativ","Valoric"].each_with_index{|d,i| data_cdd_sum[i].unshift(d)}
        data_cdd_sum[0].map! {|h| h.gsub('_'," ")}
        pdf.create_stamp("pg_header_#{next_unit}_#{next_day}") do
          pdf.bounding_box([pdf.bounds.left + 7.mm, pdf.bounds.top - 10.mm], :width  => pdf.bounds.width) do
            pdf.font 'Verdana'
            pdf.font_size 8 do
              pdf.text unit.firm.name[2]
              pdf.text unit.name[1]
            end
            pdf.move_up 12
            pdf.font_size 12 do
              pdf.text "Document cumulativ nr.______ din #{Date.new(y,m,d).to_s}", align: :center, style: :bold
            end
          end
        end
        pdf.start_new_page(size: 'A4', layout: :landscape, margin: [0,0,10.mm,0])
        pdf.bounding_box([pdf.bounds.left + 7.mm, pdf.bounds.top - 10.mm], :width  => pdf.bounds.width) do
          pdf.font 'Verdana'
          pdf.font_size 8 do
            pdf.text unit.firm.name[2]
            pdf.text unit.name[1]
          end
          pdf.move_up 12
          pdf.font_size 12 do
            pdf.text "Document cumulativ nr.______ din #{Date.new(y,m,d).to_s}", align: :center, style: :bold
          end
        end
        pdf.bounding_box([pdf.bounds.left + 7.mm, pdf.bounds.top - 20.mm], :width  => pdf.bounds.width) do
          pdf.table(data_cdd, header: true,column_widths: [7.mm, 53.mm, 20.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 14.mm, 14.mm]) do
            pdf.font_size 7
            row(0).style(align: :center)
            column(0).rows(1..100).style(align: :right, padding: [6,3,4,2])
            column(1..2).rows(1..100).style(padding: [2,0,2,5])
            column(3..21).rows(1..100).style(align: :right,padding: [6,2,0,0])
          end
          unless header_ext.empty?
            pdf.move_down 5.mm
            if data_cdd_ext[0].length > 21
              pdf.text "Numărul de sortimente depăşeşte lăţimea max. a tabelului! Continuare în pg. urmatoare..."
              pdf.text "Din păcate numărul de sortimente depăşeşte lăţimea max. și a tabelului extins! Pentru a tipării tabelul sunați la inginerul de sistem!"
            else
              pdf.text "Numărul de sortimente depăşeşte lăţimea max. a tabelului! Continuare în pg. urmatoare..."
              pdf.start_new_page(size: 'A4', layout: :landscape, margin: [0,0,10.mm,0])
              pdf.table(data_cdd_ext, header: true,column_widths: [7.mm, 53.mm, 20.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 11.mm, 14.mm, 14.mm]) do
                pdf.font_size 7
                row(0).style(align: :center)
                column(0).rows(1..100).style(align: :right, padding: [6,3,4,2])
                column(1..2).rows(1..100).style(padding: [2,0,2,5])
                column(3..21).rows(1..100).style(align: :right,padding: [6,2,0,0])
              end
            end
          end
          pdf.move_down 5.mm
          if hl.length > 17
            table_sum = pdf.make_table(data_cdd_sum, header: true) do
              pdf.font_size 6
              [15.mm, *[12.mm]*data_cdd_sum[0].length].each_with_index do |w,i|
                column(i).width = w
              end
              row(0).style(align: :center)
              column(0).rows(1..5).style(padding: [3,5])
              column(1..(data_cdd_sum[0].length)).rows(1..5).style(align: :right, padding: [3,3])
            end
          else
            table_sum = pdf.make_table(data_cdd_sum, header: true) do
              pdf.font_size 7
              [16.mm, *[14.mm]*data_cdd_sum[0].length].each_with_index do |w,i|
                column(i).width = w
              end
              row(0).style(align: :center)
              column(0).rows(1..5).style(padding: [3,5])
              column(1..(data_cdd_sum[0].length)).rows(1..5).style(align: :right, padding: [3,3])
            end
          end
          if pdf.y - table_sum.height < 30.mm
            pdf.start_new_page(size: 'A4', layout: :landscape, margin: [0,0,10.mm,0])
          end
          table_sum.draw
          pdf.move_down 5.mm
          pdf.font_size 8
          pdf.text "În data de #{Date.new(y,m,d).to_s} din total rulaj <b>#{"%.2f" % sum_100}</b> RON s-au reţinut <b>#{"%.2f" % sum_003}</b> RON (3% Taxă mediu), <b>#{"%.2f" % sum_016}</b> RON (16% impozit) şi s-a achitat în numerar <b>#{"%.2f" % sum_out}</b> RON.", inline_format: true
        end
      end
    end
  end
end
pdf.render()
