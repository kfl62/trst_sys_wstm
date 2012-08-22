class TrstPartner
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,                :type => Array,         :default => ["ShortName","FullName","OfficialName"]
  field :identities,          :type => Hash,          :default => {:caen => "xxx",:chambcom => "J",:fiscal => "RO",:account => "xxx",:itm => "xxx",:internet => "xxx.xxx.xxx.xxx",:cod => "XXX"}
  field :contact,             :type => Hash,          :default => {:phone => "xxxx",:fax => "xxx",:email => "xx@xxx.xxx",:website => "xxxx"}
  field :about,               :type => Hash,          :default => {:scope => "Scope ...?...", :descript => "Descript ...?..."}
  field :client,              :type => Boolean,       :default => true
  field :supplier,            :type => Boolean,       :default => true
  field :transporter,         :type => Boolean,       :default => true
  field :firm,                :type => Boolean,       :default => false
  field :p03,                 :type => Boolean,       :default => true

  embeds_many :addresses,       :class_name => "TrstPartnerAddress"
  embeds_many :units,           :class_name => "TrstPartnerUnit"

  class << self
    def export
      ownfirm = Trst::Firm.first
      Trst::Firm.delete_all
      wp = Wstm::PartnerFirm.new(
        name: ownfirm.name,
        identities: ownfirm.identities,
        contact: ownfirm.contact,
        about: ownfirm.about,
        p03: false,
        firm: true,
        addresses: ownfirm.addresses,
        persons: ownfirm.persons,
        delegates: ownfirm.delegates
      ) do |p_id|
        p_id._id = ownfirm.id
      end
      wp.save
      ownfirm.units.each do |u|
        wp.units.create(
          role:     'pos',
          name:     u['name'],
          slug:     u['slug'],
          chief:    u['chief'],
          env_auth: u['env_auth'],
          main:     u['main']
        ) do |u_id|
          u_id._id = u['_id']
        end
      end
      ownfirm.persons.each do |person|
        if person['name'] != 'FirstName LastName'
          wp.people.new(
            id_pn: person['id_pn'],
            name_frst: person['name'].split(' ')[0].titleize.gsub(' ','-'),
            name_last: person['name'].split(' ')[1].titleize.gsub(' ','-'),
            other: person['other'],
            id_doc: {"type" => 'CI', "sr" => person["id_sr"], "nr" => person["id_nr"], "by" => person["id_by"], "on" => person["id_on"]}
          ) do |pp|
            pp._id = person['_id']
            pp['role'] = 'contactp'
            pp['email'] = person['email']
            pp['phone'] = person['phone']
            pp.save(validate: false)
          end
        end
      end
      ownfirm.unset(:persons)
      ownfirm.delegates.each do |person|
        if person['name'] != 'FirstName LastName'
          wp.people.new(
            id_pn: person['id_pn'],
            name_frst: person['name'].split(' ')[0].titleize.gsub(' ','-'),
            name_last: person['name'].split(' ')[1].titleize.gsub(' ','-'),
            other: person['other'],
            id_doc: {"type" => 'CI', "sr" => person["id_sr"], "nr" => person["id_nr"], "by" => person["id_by"], "on" => person["id_on"]}
          ) do |pp|
            pp._id = person['_id']
            pp['role'] = 'delegate'
            pp['email'] = person['email']
            pp['phone'] = person['phone']
            pp.save(validate: false)
          end
        end
      end
      ownfirm.unset(:delegates)
    end
  end

  def export
    wp = Wstm::PartnerFirm.new(
      name: name,
      identities: identities,
      contact: contact,
      about: about,
      client: client,
      supplier: supplier,
      transporter: transporter,
      p03: p03,
      firm: firm,
      addresses: addresses,
      units: units
    ) do |p_id|
      p_id._id = id
    end
    wp.save
    wp.set(:persons,has_attribute?(:persons) ? persons : [])
    wp.set(:delegates,has_attribute?(:delegates) ? delegates : [])
    wp.set(:departments,has_attribute?(:departments) ? departments : [])
    if wp.persons.length > 0
      wp.persons.each do |person|
        if person['name'] != 'FirstName LastName'
          wp.people.new(
            id_pn: person['id_pn'],
            name_frst: person['name'].split(' ')[0].titleize.gsub(' ','-'),
            name_last: person['name'].split(' ')[1].titleize.gsub(' ','-'),
            other: person['other'],
            id_doc: {"type" => 'CI', "sr" => person["id_sr"], "nr" => person["id_nr"], "by" => person["id_by"], "on" => person["id_on"]}
          ) do |pp|
            pp._id = person['_id']
            pp['role'] = 'contactp'
            pp['email'] = person['email']
            pp['phone'] = person['phone']
            pp.save(validate: false)
          end
        end
      end
    end
    wp.unset(:persons)
    if wp.delegates.length > 0
      wp.delegates.each do |person|
        if person['name'] != 'FirstName LastName'
          wp.people.new(
            id_pn: person['id_pn'],
            name_frst: person['name'].split(' ')[0].titleize.gsub(' ','-'),
            name_last: person['name'].split(' ')[1].titleize.gsub(' ','-'),
            other: person['other'],
            id_doc: {"type" => 'CI', "sr" => person["id_sr"], "nr" => person["id_nr"], "by" => person["id_by"], "on" => person["id_on"]}
          ) do |pp|
            pp._id = person['_id']
            pp['role'] = 'delegate'
            pp['email'] = person['email']
            pp['phone'] = person['phone']
            pp.save(validate: false)
          end
        end
      end
    end
    wp.unset(:delegates)
    wp.units.where(:name => /ShortName/).delete_all
    wp.units.where(:role => nil).each{|u| u.set(:role,'pos')}
    if wp.departments.length > 0
      wp.departments .each do |unit|
        unless unit['name'][0] =~ /ShortName/
          wp.units.new(
            role: 'dprt',
            name: unit['name'],
            slug: unit['name'][0].upcase[0,4]
          ) do |ppu|
            ppu_id = unit['_id']
            ppu.save
          end
        end
      end
    end
    wp.unset(:departments)
  end
end

class TrstPartnerAddress
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,      :default => "Main address"
  field :city,      :default => "Cluj-Napoca"
  field :street,    :default => "Xxx"
  field :nr,        :default => "xxx"
  field :bl,        :default => "__"
  field :sc,        :default => "__"
  field :et,        :default => "__"
  field :ap,        :default => "__"
  field :state,     :default => "Cluj"
  field :country,   :default => "Romania"
  field :zip,       :default => "xxxxxx"

  embedded_in :trstpartner, :class_name => "TrstPartner", :inverse_of => :addresses
end

class TrstPartnerUnit
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,          :type => Array,     :default => ["ShortName","FullName"]
  field :slug,          :type => String
  field :chief,         :type => String,    :default => "Lastname Firstname"
  field :env_auth,      :type => String
  field :main,          :type => Boolean,   :default => false

  embedded_in :partner,   :class_name => "TrstPartner",         :inverse_of => :units
end
