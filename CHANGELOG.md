## v0.3.0

release date: **2014-xx-xx**

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
