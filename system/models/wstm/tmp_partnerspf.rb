# encoding: utf-8
class TrstPartnersPf
  include Mongoid::Document
  include Mongoid::Timestamps

  field :id_pn,               :type => String
  field :name_last,           :type => String,        :default => "Last(Nume)"
  field :name_first,          :type => String,        :default => "First(Prenume)"
  field :identities,          :type => Hash,          :default => {:id_sr => "KX", :id_nr => "123456",:id_by => "SPCLEP Cluj-Napoca", :id_on => "1900-01-01"}
  field :address,             :type => Hash,          :default => {:city => "Cluj-Napoca", :street => "str.", :nr => "00", :bl => "-", :sc => "-", :et => "-", :ap => "-"}
  field :other,               :type => String,        :default => "Client"

  #has_many :apps, :class_name => "TrstAccExpenditure", :inverse_of => :client
  def export
    wpf = Wstm::PartnerPerson.new(
      id_pn: id_pn,
      name_last: name_last,
      name_frst: name_first,
      id_doc: {"type" => 'CI', "sr" => identities["id_sr"], "nr" => identities["id_nr"], "by" => identities["id_by"], "on" => identities["id_on"]}
      ) do |pf|
          pf._id = id
        end
    wpf.save
    wpf.address = Trst::Address.new(
      city:   address['city'],
      street: address['street'],
      nr:     address['nr'],
      bl:     address['bl'],
      sc:     address['sc'],
      et:     address['et'],
      ap:     address['ap']
    )
    wpf.save
  end
end
