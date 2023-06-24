s|<pages[^>]*>|<score><scoreDef><staffGrp><staffDef n="1" lines="5"/></staffGrp></scoreDef>|g
s|</page>||g
s|<page[^>]*>||g
s|<system[^>]*>|<section><measure>|g
s|</system>|</measure></section>|g
s|</pages>|</score>|g
s/dur="longa"/dur="long"/g
s/dur="brevis"/dur="breve"/g
s/dur="semibrevis"/dur="1"/g
s/dur="minima"/dur="2"/g
s/dur="semiminima"/dur="4"/g
s/dur="fusa"/dur="8"/g
s/dur="semifusa"/dur="16"/g
s/[[:space:]]ulx="[0-9]*"//g
s/[[:space:]]uly="[0-9]*"//g
s/meiversion="2013"/meiversion="3.0.0"/g
s|<?xml-model[^>]*>|<?xml-model href="https://music-encoding.org/schema/3.0.0/mei-all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>\n<?xml-model href="https://music-encoding.org/schema/3.0.0/mei-all.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>\n|
