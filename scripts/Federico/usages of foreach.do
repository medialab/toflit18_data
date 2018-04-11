foreach v of varlist entrees sorties abbeville aigueperse aixenprovence albi angers angoulême annonay arles arras aubenas avignon ayen bayeux bayonne béziers billom bordeaux boulognesurmer brioude brivelagaillarde buislesbaronnies caen cany carcassonne castelnaudary castres chartres chateaudun chateaugontier chaumontenvexin cordes dole douai draguignan foix gonesse grenade grenoble issoire langres lavaur lehavre lepuyenvelay lille limoges lyon magnyenvexin maringues marseille meulan montauban montpellier narbonne orléans pamiers paris poitiers pontoise pontsaintesprit puylaurens reims rennes revel romans rouen saintaffrique saintbrieuc saintetienne tarasconsurariège toulouse treignac tulle valence viclecomte villeneuvedeberg {
gen l`v'=ln(`v')
}
l`v'=ln(`v')
}

foreach var of varlist lentrees lsorties labbeville laigueperse laixenprovence lalbi langers langoulême lannonay larles larras laubenas lavignon layen lbayeux lbayonne lbéziers lbillom lbordeaux lboulognesurmer lbrioude lbrivelagaillarde lbuislesbaronnies lcaen lcany lcarcassonne lcastelnaudary lcastres lchartres lchateaudun lchateaugontier lchaumontenvexin lcordes ldole ldouai ldraguignan lfoix lgonesse lgrenade lgrenoble lissoire llangres llavaur llehavre llepuyenvelay llille llimoges llyon lmagnyenvexin lmaringues lmarseille lmeulan lmontauban lmontpellier lnarbonne lorléans lpamiers lparis lpoitiers lpontoise lpontsaintesprit lpuylaurens lreims lrennes lrevel lromans lrouen lsaintaffrique lsaintbrieuc lsaintetienne ltarasconsurariège ltoulouse ltreignac ltulle lvalence lviclecomte lvilleneuvedeberg {
  misstable sum `var'
  if r(K_uniq) < 30 drop `var' 
  }
  
  
  foreach v of varlist lentrees lsorties labbeville laigueperse laixenprovence lalbi langers lannonay larles laubenas lavignon layen lbayeux lbéziers lbordeaux lboulognesurmer lbrioude lbuislesbaronnies lcarcassonne lcastelnaudary lcastres lchartres lchateaudun lchateaugontier lchaumontenvexin lcordes ldole ldouai ldraguignan lfoix lgonesse lgrenade lgrenoble lissoire llangres llavaur llepuyenvelay llille llimoges llyon lmagnyenvexin lmaringues lmarseille lmeulan lmontauban lorléans lpamiers lparis lpoitiers lpontoise lpontsaintesprit lpuylaurens lreims lrennes lrevel lromans lrouen lsaintaffrique lsaintbrieuc lsaintetienne ltarasconsurariège ltoulouse ltreignac ltulle lviclecomte lvilleneuvedeberg {
gen d`v'=`v'-L.`v'
}

foreach var of varlist dlentrees dlsorties dlabbeville dlaigueperse dlaixenprovence dlalbi dlangers dlannonay dlarles dlaubenas dlavignon dlayen dlbayeux dlbéziers dlbordeaux dlboulognesurmer dlbrioude dlbuislesbaronnies dlcarcassonne dlcastelnaudary dlcastres dlchartres dlchateaudun dlchateaugontier dlchaumontenvexin dlcordes dldole dldouai dldraguignan dlfoix dlgonesse dlgrenade dlgrenoble dlissoire dllangres dllavaur dllepuyenvelay dllille dllimoges dllyon dlmagnyenvexin dlmaringues dlmarseille dlmeulan dlmontauban dlorléans dlpamiers dlparis dlpoitiers dlpontoise dlpontsaintesprit dlpuylaurens dlreims dlrennes dlrevel dlromans dlrouen dlsaintaffrique dlsaintbrieuc dlsaintetienne dltarasconsurariège dltoulouse dltreignac dltulle dlviclecomte dlvilleneuvedeberg {
  misstable sum `var'
  if r(K_uniq) < 30 drop `var' 
  }
