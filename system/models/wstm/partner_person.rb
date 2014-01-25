# encoding: utf-8
module Wstm
  class PartnerPerson < Trst::Person

    embeds_one  :address,   class_name: 'Wstm::PartnerPersonAddress', cascade_callbacks: true
    has_many    :apps,      class_name: 'Wstm::Expenditure',          inverse_of: :client

    validates_uniqueness_of :id_pn, :unless => Proc.new{|p| p.id_pn == '-'}

    accepts_nested_attributes_for :address

    class << self
      # @todo
      def auto_search(params)
        default_sort.only(:id,:id_pn,:name_last,:name_frst)
        .or(id_pn: /\A#{params[:q]}/)
        .or(name_last: /\A#{params[:q]}/i)
        .or(name_frst: /\A#{params[:q]}/i)
        .each_with_object([]){|pf,a| a << {id: pf.id.to_s,text: "#{pf.id_pn.ljust(18)} #{pf.name}"}}
      end
      # @todo
      def apps_for_stats(*args)
        pid,y,m = *args
        if pid.blank?
          return [nil,nil,0,0]
        else
          ta = find(pid).apps
          if ta.count <= 1
            sa = ta
          else
            if m.to_i == 0
              sa = y.to_i == 0 ? ta : ta.yearly(y.to_i)
            else
              sa = y.to_i == 0 ? ta : ta.monthly(y.to_i,m.to_i)
            end
          end
        end
        [ta,sa,ta.try(:count) || 0,sa.try(:count) || 0]
      end
    end # Class methods
    # @todo
    def view_filter
      [id, name, id_pn]
    end
    # @todo
    def i18n_hash
      {
        id_pn: id_pn, name: name,
        city: address.city, street: address.street, nr: address.nr, bl: address.bl, sc: address.sc, et: address.et, ap: address.ap,
        dsr: id_doc["sr"], dnr: id_doc["nr"], dby: id_doc["by"], don: id_doc["on"]
      }
    end
  end # PartnerPerson

  class PartnerPersonAddress < Trst::Address

    field :name,    type: String,   default: 'Domiciliu'

    embedded_in :partner_person,  class_name: 'Wstm::PartnerPerson', inverse_of: :address

  end # PartnerPersonAddress
end # Wstm
