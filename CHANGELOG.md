## v0.3.0

release date: **2014-xx-xx**

* **feature v0.2.7.20**,
   - feature date: **2014-05-06**
   - bump version v0.2.7.20
   - update CHANGELOG
   - assets js, `Wstm.desk.delivery_note` ugly result for select2 formatResult #1
   - assets js, `Wstm.desk.grn` ugly result for select2 formatResult #1
   - assets js, `Wstm.desk.invoice` ugly result for select2 formatResult #1

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
