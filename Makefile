#countries in EESTEC
COUNTRIES = AUT BEL BIH CYP CYN CHE DEU ESP EST FIN FRA GEO GBR GRC HRV HUN ITA LTU LVA MKD MNE NLD POL PRT ROU RUS SRB SVN SWE TUR UNK

#countries outside Europe
OUT-EUROPE = 'GEO','TUR','BIH','CYN','MAR','DZA','TUN','LBY','EGY','LBN','SYR','ISR','SAU','IRN','IRQ','ARM','AZE','JOR','KAZ'

#cities in EESTEC
CITIES = 'Aachen','Amsterdam','Ankara','Antwerp','Athens','Banja Luka','Belgrade','Bucharest','Budapest','Cosenza','Craiova','Delft','East New Sarajevo','Eskisehir','Famagusta','Sosnowiec','Gdansk','Gliwice','Groningen','Hamburg','Helsinki','Istanbul','Izmir','Kaiserslautern','Ljubljana','Linkoping','Krakow','Kutaisi','Lille','Lisbon','Madrid','Maribor','Munich','Nantes','Novi Sad','Nis','Patras','Podgorica','Riga','Rijeka','Sarajevo','Sheffield','Skopje','St. Petersburg','Tampere','Tallinn','Trieste','Tuzla','Vienna','Vilnius','Warwick','Wroclaw','Xanthi','Zagreb','Zurich'


#location of geodata
SUBUNITS = http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/50m/cultural/ne_50m_admin_0_countries.zip
#SUBUNITS = http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_map_subunits.zip
#SUBUNITS2 = http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/50m/cultural/ne_50m_admin_0_map_subunits.zip #the first file is missing a part of Bosnia and Herzegovina
PLACES = http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_populated_places.zip
RIVERS = http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_rivers_lake_centerlines_scale_rank.zip

ROADS = http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_roads.zip


all: clean combined.json $(COUNTRIES) html-gen

clean:
	rm -rf json/*~ json/places.json json/subunits.json json/rivers.json json/roads.json json/combined.json *~ *.html style/eestec.css topo/subunits/* topo/places/* topo/rivers/* topo/roads/* style/*~

clean2:
	rm -rf json/combined.json *~ *.html style/eestec.css

release:
	rm -rf topo json/*~ json/places.json json/subunits.json json/rivers.json json/roads.json

$(COUNTRIES):
	echo ".subunit.$@ { fill: #f33; }" >> style/eestec.css

subunits.json: subunits-download 
	ogr2ogr \
	  -f GeoJSON \
	  -where "continent = 'Europe' or ADM0_A3 in ($(OUT-EUROPE))" \
	  json/subunits.json \
	  topo/subunits/ne_50m_admin_0_countries.shp


places.json: places-download
	ogr2ogr \
	  -f GeoJSON \
	  -where "nameascii in ($(CITIES))" \
	  json/places.json \
	  topo/places/ne_10m_populated_places.shp

rivers.json: rivers-download
	ogr2ogr \
	  -f GeoJSON \
	  json/rivers.json \
	  topo/rivers/ne_10m_rivers_lake_centerlines_scale_rank.shp

roads.json: roads-download
	ogr2ogr \
	  -f GeoJSON \
	  -where "scalerank < 6 and (continent = 'Europe' or sov_a3 IN ($(OUT-EUROPE)))" \
	  json/roads.json \
	  topo/roads/ne_10m_roads.shp

	  

combined.json: subunits.json places.json rivers.json #roads.json
	topojson \
	  --id-property adm0_a3 \
	  -p name=NAME \
	  -p name=NAMEASCII \
	  -o json/combined.json \
	  json/subunits.json \
	  json/places.json \
	  json/places_added.json \
	  json/rivers.json
	  #json/roads.json
	  

subunits-download:
	wget  -P "topo/subunits/" "$(SUBUNITS)"
	unzip "topo/subunits/*.zip" -d "topo/subunits"

places-download:
	wget -P "topo/places/" "$(PLACES)"
	unzip "topo/places/*.zip" -d "topo/places"

rivers-download:
	wget -P "topo/rivers/" "$(RIVERS)"
	unzip "topo/rivers/*.zip" -d "topo/rivers"

roads-download:
	wget -P "topo/roads/" "$(ROADS)"
	unzip "topo/roads/*.zip" -d "topo/roads"

html-gen:
	cp html/map.html.template map.html
