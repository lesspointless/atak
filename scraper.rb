require 'scraperwiki'
require 'rest-client'
require 'json'

# API
# https://www.digitalnemesto.sk/DmApi/

API_URL = 'https://www.digitalnemesto.sk/DmApi/json/reply'.freeze
DOC_TYPES = [{ key: 'FakturyDodavatelske', unique_id: 'FakturaId', sqlite_tr: 'SumaFaktSDph' },
             { key: 'FakturyOdberatelske', unique_id: 'FakturaId', sqlite_tr: 'SumaFaktSDph' },
             { key: 'zmluvy', unique_id: 'ZmluvaId', sqlite_tr: 'SumaSdph' },
             { key: 'objednavkyDosle', unique_id: 'ObjednavkaId', sqlite_tr: 'SumaSdph' }].freeze
ORG_URL = 'https://www.digitalnemesto.sk/DmApi/json/reply/Organizacie'.freeze

def documents(org)
  DOC_TYPES.each do |doc|
    p "--> #{org['mesto']} : #{doc[:key]}"
    items = JSON.parse(RestClient.post("#{API_URL}/#{doc[:key]}", OrganizaciaId: org['id'], Year: 0))
    items['Data'].each do |item|
      # sqlite true || false
      item[doc[:sqlite_tr]] | item[doc[:sqlite_tr]] = item[doc[:sqlite_tr]].to_s
      ScraperWiki.save([doc[:unique_id]], item.merge(org), table_name = doc[:key])
    end
  end
end

def orgs
  orgs = JSON.parse(RestClient.get(ORG_URL))
  orgs['Data'].each do |org|
    ScraperWiki.save(['OrganizaciaId'], org, table_name = 'Organizacie')
    documents('id' => org['OrganizaciaId'], 'mesto' => org['NazovObec'])
  end
end

p Time.now
orgs
p Time.now