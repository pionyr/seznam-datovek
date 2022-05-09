#!/usr/bin/env bash
set -e

# Workaround for API providing only 100 records at once - do multiple specific queries (and filter duplicates later)
INDEX=0
for QUERY in "Pionýr, z. s." "pionýrská skupina" "krajská organizace Pionýra" "Pražská organizace Pionýra"; do
  curl -s -o tmp-search-$INDEX.xml -d "<SearchSubjectRequest xmlns=\"http://seznam.gov.cz/ovm/ws/v1\"><Nazev>$QUERY</Nazev></SearchSubjectRequest>" -H 'Content-Type: application/xml' -X POST https://www.mojedatovaschranka.cz/sds/ws/call
  ((++INDEX))
done

for SEARCH_RESULTS in tmp-search-*.xml; do
  xmlstarlet sel -N n="http://seznam.gov.cz/ovm/ws/v1" -t -v "//n:NazevOsoby[starts-with(.,'Pion')]" <"$SEARCH_RESULTS" >>tmp-spolky.txt
  xmlstarlet sel -N n="http://seznam.gov.cz/ovm/ws/v1" -t -v "//n:NazevOsoby[starts-with(.,'Pion')]/following-sibling::n:ISDS" <"$SEARCH_RESULTS" >>tmp-ids.txt
  xmlstarlet sel -N n="http://seznam.gov.cz/ovm/ws/v1" -t -v "//n:NazevOsoby[starts-with(.,'Pion')]/../n:Ico" <$SEARCH_RESULTS >>tmp-ico.txt

  # add newline at the end of each file
  for FN in tmp-spolky.txt tmp-ids.txt tmp-ico.txt; do
    echo "" >>$FN
  done
done
