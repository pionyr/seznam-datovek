#!/usr/bin/env bash
set -e

QUERY="Pionýr, z. s."
SEARCH_RESULTS="tmp-search.xml"
curl -s -o $SEARCH_RESULTS -d "<SearchSubjectRequest xmlns=\"http://seznam.gov.cz/ovm/ws/v1\"><Nazev>$QUERY</Nazev></SearchSubjectRequest>" -H 'Content-Type: application/xml' -X POST https://www.mojedatovaschranka.cz/sds/ws/call

xmlstarlet sel -N n="http://seznam.gov.cz/ovm/ws/v1" -t -v "//n:NazevOsoby[starts-with(.,'Pionýr,')]" <"$SEARCH_RESULTS" >>tmp-spolky.txt
xmlstarlet sel -N n="http://seznam.gov.cz/ovm/ws/v1" -t -v "//n:NazevOsoby[starts-with(.,'Pionýr,')]/following-sibling::n:ISDS" <"$SEARCH_RESULTS" >>tmp-ids.txt
xmlstarlet sel -N n="http://seznam.gov.cz/ovm/ws/v1" -t -v "//n:NazevOsoby[starts-with(.,'Pionýr,')]/../n:Ico" <$SEARCH_RESULTS >>tmp-ico.txt

# add newline at the end of each file
for FN in tmp-spolky.txt tmp-ids.txt tmp-ico.txt; do
  echo "" >>$FN
done
