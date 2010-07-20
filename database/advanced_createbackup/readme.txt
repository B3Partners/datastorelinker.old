naderhand doen:
- verwijder inserts van niet-configuratie tabellen (zonder "type" achteraan hun naam) als de db niet leeg was voor het backuppen. Type-informatie moet blijven staan.
- verwijder alles tot het eerste CREATE-TABLE-commando.
Nu heb je SQL om in een bestaande DB (genaamd "datastorelinker") uit te voeren (voer hierna nog het Quartz sql-script uit voor je bewuste db-type).