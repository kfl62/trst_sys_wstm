## v1.0.1

* release date: **2018-03-18**
   - bump version v1.0.1
   - update CHANGELOG
   - views: `Wstm::PartnerPerson` _form.haml bugfix
   - views: `Wstm::Sorting` filter.haml default sort order

## v1.0.0

* release date: **2018-03-11**
   - bump version v1.0.0
   - update CHANGELOG

* **feature v0.3.1.25**
   - feature date: **2017-12-29**
   - bump version v0.3.1.25
   - update CHANGELOG
   - images: `100644`
   - minor changes `Wstm::Invoice`

* **feature v0.3.1.24**
   - feature date: **2016-10-21**
   - bump version v0.3.1.24
   - update CHANGELOG
   - all, `Wstm::PartnerFirm` review, forgotten stuff :)
   - all, `Wstm::PartnerPerson` review, cleanup `js`
   - config: updated year
   - models: `Wstm::Expenditure` added 2016 condition to `sum_freights_exp`
   - all, `Wstm::User` review, cleanup `js`
   - assets: js; `desk.js` no change, but recompiled

* **feature v0.3.1.23**
   - feature date: **2016-10-09**
   - bump version v0.3.1.23
   - update CHANGELOG
   - all except js, `Wstm::Stock` review
   - all except js, `Wstm::Sorting` review
   - all except js, `Wstm::PartnerPerson` review
   - all except js, `Wstm::PartnerFirm` review
   - all except js, `Wstm::Invoice` review
   - all except js, `Wstm::Grn` review
   - all except js, `Wstm::Expanditure` review
   - all except js, `Wstm::DeliveryNote` review
   - all except js, `Wstm::Sorting` review
   - all except js, `Wstm::Cassation` review
   - all except js, `Wstm::Cache` review

* **feature v0.3.1.22**
   - feature date: **2016-10-05**
   - bump version v0.3.1.22
   - update CHANGELOG
   - views: `Wstm::PartnerPerson` CRUD final
   - views: `Wstm::PartnerFirm` CRUD final
   - views: `Wstm::Freight` CRUD final
   - views: `Wstm::Stock` CRUD final
   - views: `Wstm::Sorting` fix 'hidden' duplicate
   - views: `Wstm::Shared` CRUD final
   - views: `Wstm::Sorting` CRUD final
   - assets: js, `Wstm.desk.sorting` cleanup, add on Enter keypress & [#31][#31]
   - assets: js, `Wstm.desk.sorting` typo (cut/paste) (:

* **feature v0.3.1.21**
   - feature date: **2016-10-03**
   - bump version v0.3.1.21
   - update CHANGELOG
   - views: `Wstm::Invoice` CRUD final
   - assets: js, `Wstm.desk.Invoice` cleanup, & [#31][#31]
   - views: `Wstm::Grn` CRUD final
   - assets: js, `Wstm.desk.grn` cleanup, add on Enter keypress & [#31][#31]
   - i18n: `Wstm::Cassation` minor changes
   - views: `Wstm::Expanditure` CRUD final
   - assets: js, `Wstm.desk.expenditure` cleanup,  add on Enter keypress & [#31][#31]

* **feature v0.3.1.20**
   - feature date: **2016-09-27**
   - bump version v0.3.1.20
   - update CHANGELOG
   - views: `Wstm::Sorting` forgotten class :(
   - views: `Wstm::DeliveryNote` CRUD final
   - assets: js, `Wstm.desk.delivery_note` cleanup,  add on Enter keypress & [#31][#31]
   - views: `Wstm::Sorting` {tag: {data: {mark: 'resize'} issue
   - views: `Wstm::Cassation` CRUD final
   - assets: js, `Wstm.desk.cassation` add on Enter keypress
   - i18n: `Wstm::Cassation` complete translation
   - views: `Wstm::Cache_book` CRUD final
   - views: `Wstm::Cache` CRUD final

* **feature v0.3.1.19**
   - feature date: **2016-09-24**
   - bump version v0.3.1.19
   - update CHANGELOG
   - assets: js, `Wstm.desk.stock` cleanup, r_path & [#31][#31]
   - i18n: `Wstm::Stock` minor changes
   - views: `Wstm::Stock` CRUD [#30][#30]
   - i18n: `wstm` forgotten `no_freight_stock`
   - views: `Wstm::Sorting` typo `_show.haml`
   - assets: `*.js` add r_path, :( forgotten
   - assets: `*.js` delete temp. fieles

* **feature v0.3.1.18**
   - feature date: **2016-09-23**
   - bump version v0.3.1.18
   - update CHANGELOG
   - assets: js, `Wstm.desk.sorting` cleanup, [#31][#31]]
   - i18n: `Wstm::Sorting` minor changes
   - views: `Wstm::Sorting` CRUD [#30][#30]]
   - views: shared `_select_unit` minor changes
   - assets: `*.js` delete temp. fieles
   - views: `Wstm::Cassation`, remove unneeded markdown
   - views: `Wstm::Cassation` CRUD, move styling to %tfoot

* **feature v0.3.1.17**
   - feature date: **2016-09-19**
   - bump version v0.3.1.17
   - update CHANGELOG
   - assets: js, `Wstm.desk.invoice` started rewriting
   - i18n: `Wstm::Invoice` minor changes
   - views: `Wstm::Freight` CRUD [#30][#30]]
   - views: shared `_select_params` new methods `inv_client`, `inv_supplr`
   - views: `_query_supplr_grn`, `_query_client_dln` minor changes
   - assets: js, `desk_partner_firm`, change <-> click event

* **feature v0.3.1.16**
   - feature date: **2016-09-12**
   - bump version v0.3.1.16
   - update CHANGELOG
   - views: `_query_client_dln` rework, ...
   - views: `_query_supplr_grn` forgotten styling :
   - views: shared `_select_params` new method `stats_client`

* **feature v0.3.1.15**
   - feature date: **2016-09-11**
   - bump version v0.3.1.15
   - update CHANGELOG
   - assets: js, `desk_partner_firm`, adapt ...
   - reworked `_query_supplr_grn.haml`
   - ad new method to `_select_params`, `stats_supplr`
   - rename `_query_supplier_grn` to `_query_supplr_grn`
   - delete temp. files

* **feature v0.3.1.14**
   - feature date: **2016-09-01**
   - bump version v0.3.1.14
   - update CHANGELOG
   - views: `Wstm::Grn` CRUD update
   - views: `Wstm::Grn` unneeded delete
   - assets: js, `Wstm.desk.grn` cleanup, r_path & [#31][#31]
   - views: `Wstm::DeliveryNote` _doc_add_line, typo
   - views: `Wstm::Expenditure` create, typo

* **feature v0.3.1.13**
   - feature date: **2016-08-29**
   - bump version v0.3.1.13
   - update CHANGELOG
   - assets: js, `Wstm.desk.partner_firm` cleanup, r_path & [#31][#31]
   - i18n: `wstm.partner_firm` missing, typo
   - views: `Wstm::ParnerFirm` CRUD update
   - views: `Wstm::ParnerFirm` unneeded delete
   - views: `Wstm::ParnerFirm::Address` update
   - views: `Wstm::ParnerFirm::Bank` update
   - views: `Wstm::ParnerFirm::Person` update
   - views: `Wstm::ParnerFirm::Unit` update

* **feature v0.3.1.12**
   - feature date: **2016-08-27**
   - bump version v0.3.1.12
   - update CHANGELOG
   - assets: js, `Wstm.desk.partner_person` cleanup, r_path & [#31]
   - views: `Wstm::PartnerPerson` CRUD update
   - views: remove unnecessary files
   - reports: upgrade prawn, `report.haml` new version"
   - remove unneeded `desk_report` files
   - models: `Wstm::FreightIn` update (law changed)
   - expenditure, update (law changed)
   - translation typo

* **feature v0.3.1.11**
   - feature date: **2016-08-17**
   - bump version v0.3.1.11
   - update CHANGELOG
   - assets:js, `Wstm.desk.cache` prepare for update, tmp
   - views:`Wstm::DeliveryNote` typo, improve readability
   - views:`Wstm::CacheBook.filter` typo
   - views:`Wstm::Cache.query` minor bugfix, rewrite
   - models:`Wstm::Freights` improve readabily
   - assets:js, `Wstm.desk.cache` cleanup, rebuild"

* **feature v0.3.1.10**
   - feature date: **2015-12-14**
   - bump version v0.3.1.10
   - update CHANGELOG
   - views `Wstm::DeliveryNotes` uniformization
   - views `Wstm::Expenditures` uniformization
   - views `Wstm::Freights` uniformization
   - `Wstm::Grn` prepare for update
   - `Wstm::Freight` minor changes
   - views `shared/_select_params` typo

* **feature v0.3.1.9**
   - feature date: **2014-10-11**
   - bump version v0.3.1.9
   - update CHANGELOG
   - views `Wstm::Freight` queries [#34][#34]
   - views `Wstm::Freight` CRUD [#30][#30]
   - assets js, `Wstm.desk.freight` cleanup, r_path & [#31][#31]
   - models `Wstm::Freight` handle_field_type_array, code


* **feature v0.3.1.8**
   - feature date: **2014-10-10**
   - bump version v0.3.1.8
   - update CHANGELOG
   - assest js, `Wstm.desk.cassation|delevery_note` fix [#33][#33]


* **feature v0.3.1.7**
   - feature date: **2014-10-10**
   - bump version v0.3.1.7
   - update CHANGELOG
   - views `Wstm::Expenditure` CRUD [#30][#30]
   - assets js, `Wstm.desk.expenditure` cleanup & [#31][#31]
   - i18n `Wstm::Expenditure` add missing
   - models `Wstm::FreightIn` add methods
   - models `Wstm::Freight` rewrite `#options_for_exp` see [#32][#32]


* **feature v0.3.1.6**
   - feature date: **2014-10-08**
   - bump version v0.3.1.6
   - update CHANGELOG
   - views `Wstm::Cassation`use standard outgoing
   - assets js, `Wstm.desk.cassation` use standard outgoing
   - models `Wstm::FreightOut` cassation is normal outgoing


* **feature v0.3.1.5**
   - feature date: **2014-10-08**
   - bump version v0.3.1.5
   - update CHANGELOG
   - views `Wstm::DeliveryNote` CRUD [#30][#30]
   - i18n `Wstm::DeliveryNote` related
   - assets js, `Wstm.desk.delivery_note` cleanup & [#31][#31]
   - models `Wstm::FreightOut` dynamic fileds issue see [#28][#28]
   - models `Wstm::Freight` rewrite `#options_for_dln` fix [#32][#32]


* **feature v0.3.1.4**
   - feature date: **2014-09-30**
   - bump version v0.3.1.4
   - update CHANGELOG
   - views `Wstm::Cassation` CRUD [#30][#30]
   - i18n `Trst::Cassation` related
   - assets css, `wstm` update TODO ...
   - assets js, `Wstm.desk.cassation` cleanup & [#31][#31]
   - views `Wstm::CacheBook` CRUD [#30][#30]
   - assets js, `Wstm.desk.cache_book` delete print & [#31][#31]
   - assets js, `Wstm.desk.cache_book` cleanup & [#31][#31]
   - views `Wstm::Cache` CRUD [#30][#30]
   - assets js, `Wstm.desk.cache` cleanup & [#31][#31]
   - views `shared/_system_unit` class -> data-mark
   - assets js, cleanup, review, rewrite common files [#31][#31]


* **feature v0.3.1.3**
   - feature date: **2014-09-25**
   - bump version v0.3.1.3
   - update CHANGELOG
   - views `Wstm::CacheBook` CRUD [#30][#30]
   - views `wstm/shared` partials [#30][#30]
   - assets js, `Wstm.desk` update `.scrollHeader` [#31][#31]
   - assets js, `Wstm.desk.cache_book` cleanup & [#31][#31]


* **feature v0.3.1.2**
   - feature date: **2014-09-22**
   - bump version v0.3.1.2
   - update CHANGELOG
   - assets js, `Wstm.desk` add `$.datepicker` [#31][#31]
   - views `Wstm::Cache` CRUD [#30][#30]
   - views `wstm/shared` partials [#30][#30]
   - assets js, `Wstm.desk.cache` cleanup & [#31][#31]


* **feature v0.3.1.1**
   - feature date: **2014-09-20**
   - bump version v0.3.1.1
   - update CHANGELOG
   - views check for `Document#freights_list` fix [#29][#29]
   - views check for `um` fix [#28][#28]
   - views atomic `set,push etc.` TODO should be handled in model, [#27][#27]
   - models final retouch fix [#25][#25]
   - models atomic `set,push etc.`
   - views pdf templates `BSON::ObjectId` issue
   - models `Wstm::PartnerPerson|Hmrs|PartnerFirm` remove `auto_search` Class-method


## v0.3.1 - hotfix-

* release date: **2014-09-18**
   - bump version v0.3.1
   - update CHANGELOG
   - views `report.haml` typo, fix [#26][#26]


## v0.3.0

* release date: **2014-09-17**
   - bump version v0.3.0
   - update CHANGELOG


* **feature v0.2.996**, v0.3.0 preparation
   - feature date: **2014-09-16**
   - bump version v0.2.996
   - update CHANGELOG
   - views retouch, span.warning, [issue #16][#16]
   - views retouch, span.info, [issue #16][#16]
   - views retouch, td= label, [issue #16][#16]
   - views retouch, td.ce=, [issue #16][#16]
   - views retouch, cellspacing, [issue #16][#16]
   - views `Wstm::CacheBook` filter, fix [issue #24][#24]


* **feature v0.2.995**, v0.3.0 preparation fix [issue #16][#16]
   - feature date: **2014-09-11**
   - bump version v0.2.995
   - update CHANGELOG
   - assets css, `wstm` TODO -> `application`
   - views `Wstm::CacheBook` cleanup
   - assets js, `Wstm.desk.cache_book` add r_path
   - views `Wstm::Stock`CRUD, [issue #16][#16]
   - views `Wstm::User`query, [issue #16][#16]
   - views `Wstm::PartnerPerson` CRUD, [issue #16][#16]
   - views `Wstm::PartnerFirm` CRUD, [issue #16][#16]
   - views `Wstm::Invoice` CRUD, [issue #16][#16]
   - assets js, `Wstm.desk.invoice` update
   - views `Wstm::Grn` CRUD, [issue #16][#16]
   - assets js, `Wstm.desk.grn` update
   - views `Wstm::Freight` CRUD, [issue #16][#16]
   - assets js, `Wstm.desk.freight` update
   - views `Wstm::Expenditure` CRUD, [issue #16][#16]
   - assets js, `Wstm.desk.expenditure` update
   - views `Wstm::DeliveryNote` CRUD, [issue #16][#16]
   - assets js, `Wstm.desk.delivery_note` update
   - views `Wstm::Cassation` CRUD, [issue #16][#16]
   - assets js, `Wstm.desk.cassation` update
   - views `Wstm::CacheBook` CRUD, [issue #16][#16]
   - assets js, `Wstm.desk.cache` update, rewrite
   - views `Wstm::CacheBook` CRUD, [issue #16][#16]
   - assets js, `Wstm.desk.cache` update, rewrite
   - views `Wstm::CacheBook` CRUD, [issue #16][#16]
   - assets js, `Wstm.desk.cache` update, rewrite
   - views `shared_select.haml` new partial, fix issue [issue #17][#17]
   - views `Wstm::Cache` CRUD, [issue #16][#16]
   - assets js, `Wstm.desk.cache` update, rewrite
   - views all, cleanup, remove `.hidden`, `{cellspacing: 0}`


* **feature v0.2.994**, v0.3.0 preparation
   - feature date: **2014-09-02**
   - bump version v0.2.994
   - update CHANGELOG
   - views all CRUD, use `td_buttonset`, [kfl62/trst_sys_sinatra#23][trst_main#23]
   - views pdf templates, fix [issue #15][#15]


* **feature v0.2.993**, v0.3.0 preparation
   - feature date: **2014-08-26**
   - bump version v0.2.993
   - update CHANGELOG
   - assets js, cleanup, `main.js` update, fix [issue #14][#14]


* **feature v0.2.992**,, v0.3.0 preparation, fix [issue #13][#13]
   - feature date: **2014-08-21**
   - bump version v0.2.992
   - update CHANGELOG
   - config `firm.yml` update
   - assets css,  use unique style in modules [kfl62/trst_sys_sinatra#12][trst_main#12]
   - views `layout`, use unique layout in `public` controller [kfl62/trst_sys_sinatra#15][trst_main#15]


* **feature v0.2.991**, v0.3.0 preparation
   - feature date: **2014-06-13**
   - bump version v0.2.991
   - update CHANGELOG
   - views `Wstm::PartnerFirm` query partials update
   - models `Wstm::Stock` inherit from `Trst`, only overwrite
   - models `Wstm::Payment` inherit from `Trst`, only overwrite
   - views `Wstm::Sorting` renamed field
   - i18n `Wstm::Sorting` renamed field
   - models `Wstm::Sorting` inherit from `Trst`, only overwrite
   - views `Wstm::Invoice` renamed field
   - i18n `Wstm::Invoice` renamed field
   - models `Wstm::Invoice` inherit from `Trst`, only overwrite
   - models `Wstm::Grn` inherit from `Trst`, only overwrite
   - models `Wstm::Freight|In|Out|Stock` update to current version from `Trst`
   - models `Wstm::Expenditure` inherit from `Trst`, only overwrite
   - views `Wstm::DeliveryNote` renamed field
   - models `Wstm::DeliveryNote` inherit from `Trst`, only overwrite
   - views `Wstm::Cassation` renamed field
   - i18n `Wstm::Cassation` renamed field
   - models `Wstm::Cassation` inherit from `Trst`, only overwrite
   - models `Wstm::CacheBook` inherit from `Trst`, only overwrite
   - models `Wstm::Cache` inherit from `Trst`, only overwrite


* **feature v0.2.990**, v0.3.0 preparation
   - feature date: **2014-06-06**
   - bump version v0.2.990
   - update CHANGELOG
   - views `Wstm::Freight`, query and reports, method name changed since inheriting
   - models `Wstm::Freight|In|Out|Stock` cleanup, inherit from `Trst`
   - models `Wstm::PartnerFirm|Person` cleanup, inherit from `Trst`


* **feature v0.2.7.27**, bugfix [issue #12][#12]
   - feature date: **2014-06-02**
   - bump version v0.2.7.27
   - update CHANGELOG
   - models all where appropriate fix [issue #12][#12]


* **feature v0.2.7.26**,
   - feature date: **2014-06-01**
   - bump version v0.2.7.26
   - update CHANGELOG
   - models `Wstm::FreightIn|Out|Stock` cleanup, fix [issue #10][#10]
   - models `Wstm::PartnerFirm::Unit` add relations [issue #10][#10], `#validate?` [issue #9][#9]
   - models `Wstm::Stock` cleanup, index
   - models `Wstm::Sorting` cleanup, index
   - models `Wstm::Grn` cleanup, index
   - models `Wstm::Expenditure` cleanup, index
   - models `Wstm::DeliveryNote` cleanup, index
   - models `Wstm::Cassation` cleanup, index
   - models `Wstm::Cache` cleanup, index
   - models `Wstm::PartnerPerson` move validation [kfl62/trst_sys_sinatra#6][trst_main#6]


* **feature v0.2.7.25**, bugfix [issue #8][#8], optimizations
   - feature date: **2014-05-29**
   - bump version v0.2.7.25
   - update CHANGELOG
   - views: report, fix [issue #8][#8]
   - models `Wstm::PartnerFirm|Freight` optimizations


* **feature v0.2.7.24**, bugfix [issue #7][#7]
   - feature date: **2014-05-26**
   - bump version v0.2.7.24
   - update CHANGELOG
   - assets js, `Trst.desk.delivery_note|grn|invoice` fix [issue #7][#7]


* **feature v0.2.7.23**, `Wstm::Grn` [issue #6][#6]
   - feature date: **2014-05-11**
   - bump version v0.2.7.23
   - update CHANGELOG
   - assets js, `Wstm.desk.grn` modified, [issue #6][#6]
   - views `Wstm::Grn` CRUD `create` modified, fix [issue #6][#6]
   - models: all relevant, modify considering [issue #5][#5]


* **feature v0.2.7.22**, `Clns::PartnerFirm::Bank`,  [issue #4][#4],  [issue #5][#5]
   - feature date: **2014-05-10**
   - bump version v0.2.7.22
   - update CHANGELOG
   - views `Wstm::PartnerFirm::Unit` rearrange CRUD, [issue #5][#5]
   - views `Wstm::PartnerFirm::Person` rearrange CRUD, [issue #5][#5]
   - views `Wstm::PartnerFirm::Address` rearrange CRUD, [issue #5][#5]
   - views `Wstm::PartnerFirm::Bank` CRUD, [issue #4][#4]
   - views `Wstm::PartnerFirm` partial `_show.haml` add tab for banks
   - i18n `partner_firm.yml` translationa related to [issue #4][#4]
   - models `Wstm::PartnerFirm` embed `Wstm::PartnerFirm::Bank`, fix [issue #4][#4], rename embeddeds fix [issue #5][#5]


* **feature v0.2.7.21**, duplicates, [issue #2][#2]
   - feature date: **2014-05-06**
   - bump version v0.2.7.21
   - update CHANGELOG
   - i18n `wstm.yml` translate duplicate document warnings
   - views `Wstm::DeliveryNote` check for duplicate documents
   - views `Wstm::Grn` check for duplicate documents


* **feature v0.2.7.20**, [issue #1][#1]
   - feature date: **2014-05-06**
   - bump version v0.2.7.20
   - update CHANGELOG
   - assets js, `Wstm.desk.delivery_note` ugly result for select2 formatResult [issue #1][#1]
   - assets js, `Wstm.desk.grn` ugly result for select2 formatResult [issue #1][#1]
   - assets js, `Wstm.desk.invoice` ugly result for select2 formatResult [issue #1][#1]


* **feature v0.2.7.19**, Storekeeper statistics, bugfix
   - feature date: **2014-05-01**
   - bump version v0.2.7.19
   - update CHANGELOG
   - views `Wstm::User` pdf skeleton
   - views `Wstm::User` query bugfix, add print functionality
   - assets js, `Trst.desk.user`, rewrite
   - models `Wstm::User` statistics related...
   - views `Wstm::Cache` partial `_form`, nil value, bugfix


* **feature v0.2.7.18**, `Wstm::CacheBook` monthly report
   - feature date: **2014-04-30**
   - bump version v0.2.7.18
   - update CHANGELOG
   - rename `lib/version.rb` :(
   - views `report/cb_monthly.rb` skeleton
   - views `report.haml` handle `cb_monthly`
   - views `Cache::Book` pdf template, typo
   - i18n `wstm.yml` add translation


* **feature v0.2.7.17**, `Wstm::CacheBook` pdf template
   - feature date: **2014-04-25**
   - bump version v0.2.7.17
   - update CHANGELOG
   - assets js, printing functionality
   - views `pdf.rb` Prawn skeleton, templte
   - views , partials printing related changes
   - models `Wstm::CacheBook` alias name to pdf file_name


* **feature v0.2.7.16**, bugfix
   - feature date: **2014-04-24**
   - bump version v0.2.7.16
   - update CHANGELOG
   - views `Wstm::CacheBook` partial `_form.haml` ordering lines issue


* **feature v0.2.7.15**, bugfix
   - feature date: **2014-04-24**
   - bump version v0.2.7.15
   - update CHANGELOG
   - i18n `grn|invoice.yml` p03_select, bugfix


* **feature v0.2.7.14**,
   - feature date: **2014-04-22** bugfix
   - bump version v0.2.7.14
   - update CHANGELOG
   - views pdf template related to model `Trst::User#id_pn` in main module
   - i18n, views `partner_firm.yml` p03 duplicate, bugfix


* **feature v0.2.7.13**, `Wstm::CacheBook` CRUD
   - feature date: **2014-04-22**
   - bump version v0.2.7.13
   - update CHANGELOG
   - assets js, `Wstm.desk.cache_book` skeleton
   - assets js, `Wstm.desk.scrollHeader` reset functionality
   - assets css, font-awesome bugfix, base completions
   - views `Wstm::CacheBook` CRUD skeleton, for testing
   - i18n `cache_book.yml` initial translation
   - model `Wstm::CacheBook` and embedded model, skeleton


* **feature v0.2.7.12**, bugfix
   - feature date: **2014-04-16**
   - bump version v0.2.7.12
   - update CHANGELOG
   - views `Wstm::Expenditure` pdf template, CNP on new line, bugfix


* **feature v0.2.7.11**, bugfix
   - feature date: **2014-04-15**
   - bump version v0.2.7.11
   - update CHANGELOG
   - views `Wstm::Expenditure` pdf template, EMPTY document, bugfix
   - i18n `wstm.yml` typo


* **feature v0.2.7.10**, bugfix
   - feature date: **2014-04-14**
   - bump version v0.2.7.10
   - update CHANGELOG
   - views `Wstm::Expenditure` pdf template, justify paragraph, bugfix
   - reports `unit_plst` more than 15 lines, bugfix
   - i18n `wstm.yml` typo


* **feature v0.2.7.9**,legea 38/2014, bugfix
   - feature date: **2014-04-12**
   - bump version v0.2.7.9
   - update CHANGELOG
   - views,i18n `Wstm::Expenditure` Legea 38/2014
   - reports `unit_daily_exp` template, layout, stamp bugfix


* **feature v0.2.7.8**, monthly reports wrong id_stats, bugfix
   - feature date: **2014-03-01**
   - bump version v0.2.7.8
   - update CHANGELOG
   - monthly reports reports wrong id_stats :(, bugfix


* **feature v0.2.7.7**, monthly reports, recap.
   - feature date: **2014-03-01**
   - bump version v0.2.7.7
   - update CHANGELOG
   - monthly reports, recap. starts on new page


* **feature v0.2.7.6**, bugfix, update prawn, `Wstm::Expenditure` all in one daily report
   - feature date: **2014-02-28**
   - bump version v0.2.7.6
   - update CHANGELOG
   - views reports pdf templates, ruby 2 hash syntax, updated prawn caused modifications
   - i18n, views `Wstm::Expenditure` all in one daily report, related changes
   - templates, backgrounds cleanup, new ones
   - models `Wstm::PartnerFirmUnit` create_stock, id_date bugfix


* **feature v0.2.7.5**, `Wstm::PartnerPerson` query partner, regarding expenditures
   - feature date: **2014-01-25**
   - bump version v0.2.7.5
   - update CHANGELOG
   - views `Wstm::PartnerPerson` add partials for queries
   - assets js, `Wstm.desk.partner_person` query related, rewrite
   - assets js, `Wstm.desk.template` finally, a template, hopefully useful
   - i18n `wstm,yml` new translation
   - models `Wstm::PartnerPerson|Expenditures` query partner related changes


* **feature v0.2.7.4**, mostly bugfixes
   - feature date: **2014-01-23**
   - bump version v0.2.7.4
   - update CHANGELOG
   - views `Wstm::Freight` `query.haml` missing data, bugfix
   - models `Wstm::ParnerFirm` `active?`, bugfix
   - models `Wstm::Freight` `handle_code`, bugfix


* **feature v0.2.7.3**, `Wstm::PartnerFirm` query, client, supplier, unit expenditures
   - feature date: **2014-01-13**
   - bump version v0.2.7.3
   - update CHANGELOG
   - views add partials for queries
   - assets css, `_dialog.sass` some styling
   - assets js, `Trst.desk.partner_firm` add client, supplier query related
   - i18n `partner_firm.yml` add table headers for queries


* **feature v0.2.7.2**, `Wstm::Freights` query, daily analytic
   - feature date: **2014-01-03**
   - bump version v0.2.7.2
   - update CHANGELOG
   - assets js, `Trst.desk.freight` prepare for daily analytic
   - views `query.haml`, add daily analytic TODO extract logic from view
   - i18n `freight.yml` add table header for daily analytic


* **feature v0.2.7.1**, mew year settings
   - feature date: **2014-01-02**
   - bump version v0.2.7.1
   - update CHANGELOG
   - update `config.yml`
   - views add 2014, ignore inactive units
   - assets js, `Trst.desk.freight` typo, duplicate in url
   - models improve `increment_name` method, where appropriate
   - models `Wstm::ParnerFirm::Unit` new methods `stock_create(y,m)`, `active?`
   - models `Wstm::Cache` ignore unit without cache
   - models `Wstm::Freight` some bugfixes, on query


## v0.2.7

release date: **2013-11-06**

* hotfix v0.2.7: `stock_accounting.rb` report firms p03 issue:
  `report/stock_accounting` firms p03 issue

## v0.2.6

release date: **2013-09-19**

* hotfix v0.2.6: `Trst::Cache#money_out` issue:
  `money_out` not properly handled in views
  `report/stock_stats` no data issue

## v0.2.5

release date: **2013-08-02**

* hotfix v0.2.5: `Wstm::Sorting` model issue:
  ensure that associated `from_freights` and `resl_freight`,
  has `id_intern: true` and `val: updated`

## v0.2.4

release date: **2013-07-26**

* hotfix v0.2.4: `Wstm.desk.invoice` select2 v3.4.1 `select2('disabled')` -> `select2('enable',false)`

## v0.2.3

release date: **2013-07-25**

* hotfix v0.2.3: expenditure on create, no freight selected issue

## v0.2.2

release date: **2013-07-24**

* views: update according patched main.js in TrustSys v0.2.4 (select2 $ui.dialog issue)

## v0.2.1

release date: **2013-07-22**

* hotfix v0.2.1: I forgot to update version :)

## v0.2.0

release date: **2013-07-20**

* update layout according to TrustSys (JQuery UI v.1.10.3)

* `public\javasctipts\wstm` add js (compiled coffeescripts) production ready

## v0.1.0

release date: **2013-07-18**

* Started using git-flow `git flow init`

* Added **CHANGELOG**

* Add version `lib/demo/version.rb`

[trst_main#23]: https://github.com/kfl62/trst_sys_sinatra/issues/23
[trst_main#15]: https://github.com/kfl62/trst_sys_sinatra/issues/15
[trst_main#12]: https://github.com/kfl62/trst_sys_sinatra/issues/12
[trst_main#6]: https://github.com/kfl62/trst_sys_sinatra/issues/6
[#1]: https://github.com/kfl62/trst_sys_wstm/issues/1
[#2]: https://github.com/kfl62/trst_sys_wstm/issues/2
[#3]: https://github.com/kfl62/trst_sys_wstm/issues/3
[#4]: https://github.com/kfl62/trst_sys_wstm/issues/4
[#5]: https://github.com/kfl62/trst_sys_wstm/issues/5
[#6]: https://github.com/kfl62/trst_sys_wstm/issues/6
[#7]: https://github.com/kfl62/trst_sys_wstm/issues/7
[#8]: https://github.com/kfl62/trst_sys_wstm/issues/8
[#9]: https://github.com/kfl62/trst_sys_wstm/issues/9
[#10]: https://github.com/kfl62/trst_sys_wstm/issues/10
[#11]: https://github.com/kfl62/trst_sys_wstm/issues/11
[#12]: https://github.com/kfl62/trst_sys_wstm/issues/12
[#13]: https://github.com/kfl62/trst_sys_wstm/issues/13
[#14]: https://github.com/kfl62/trst_sys_wstm/issues/14
[#15]: https://github.com/kfl62/trst_sys_wstm/issues/15
[#16]: https://github.com/kfl62/trst_sys_wstm/issues/16
[#17]: https://github.com/kfl62/trst_sys_wstm/issues/17
[#18]: https://github.com/kfl62/trst_sys_wstm/issues/18
[#19]: https://github.com/kfl62/trst_sys_wstm/issues/19
[#20]: https://github.com/kfl62/trst_sys_wstm/issues/20
[#21]: https://github.com/kfl62/trst_sys_wstm/issues/21
[#22]: https://github.com/kfl62/trst_sys_wstm/issues/22
[#23]: https://github.com/kfl62/trst_sys_wstm/issues/23
[#24]: https://github.com/kfl62/trst_sys_wstm/issues/24
[#25]: https://github.com/kfl62/trst_sys_wstm/issues/25
[#26]: https://github.com/kfl62/trst_sys_wstm/issues/26
[#27]: https://github.com/kfl62/trst_sys_wstm/issues/27
[#28]: https://github.com/kfl62/trst_sys_wstm/issues/28
[#29]: https://github.com/kfl62/trst_sys_wstm/issues/29
[#30]: https://github.com/kfl62/trst_sys_wstm/issues/30
[#31]: https://github.com/kfl62/trst_sys_wstm/issues/31
[#32]: https://github.com/kfl62/trst_sys_wstm/issues/32
[#33]: https://github.com/kfl62/trst_sys_wstm/issues/33
[#34]: https://github.com/kfl62/trst_sys_wstm/issues/34
[#35]: https://github.com/kfl62/trst_sys_wstm/issues/35
[#36]: https://github.com/kfl62/trst_sys_wstm/issues/36
[#37]: https://github.com/kfl62/trst_sys_wstm/issues/37
[#38]: https://github.com/kfl62/trst_sys_wstm/issues/38
[#39]: https://github.com/kfl62/trst_sys_wstm/issues/39
[#40]: https://github.com/kfl62/trst_sys_wstm/issues/40
[#41]: https://github.com/kfl62/trst_sys_wstm/issues/41
[#42]: https://github.com/kfl62/trst_sys_wstm/issues/42
[#43]: https://github.com/kfl62/trst_sys_wstm/issues/43
[#44]: https://github.com/kfl62/trst_sys_wstm/issues/44
[#45]: https://github.com/kfl62/trst_sys_wstm/issues/45
[#46]: https://github.com/kfl62/trst_sys_wstm/issues/46
[#47]: https://github.com/kfl62/trst_sys_wstm/issues/47
[#48]: https://github.com/kfl62/trst_sys_wstm/issues/48
[#49]: https://github.com/kfl62/trst_sys_wstm/issues/49
[#50]: https://github.com/kfl62/trst_sys_wstm/issues/50
