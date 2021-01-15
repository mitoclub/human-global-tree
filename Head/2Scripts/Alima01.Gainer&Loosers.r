rm(list=ls(all=TRUE))

indata = read.csv("../../Body/2Derived/fulltreeCodons.csv", header = TRUE, sep = ";")

data = data[data$note == 'normal',] # filter out everything except protein-coding mutations:
table(data$ancestral_aa)
VecOfNormalAa = unique(data$ancestral_aa); length(VecOfNormalAa)
table(data$derived_aa) # Ambiguous, Asn/Asp, Gln/Glu, Leu/Ile => why all noisy AA only among derived? All of them are on external branches?
data = data[data$derived_aa %in% VecOfNormalAa,]

#### mutations are only a t g c;  Derive Subst and Context (two before and two after)
# Subst
ExtractThird<-function(x) {unlist(strsplit(x,''))[3]}
data$temp1 = apply(as.matrix(data$ancestor),1,FUN = ExtractThird); data = data[data$temp1 %in% c('A','T','G','C'),]
data$temp2 = apply(as.matrix(data$descendant),1,FUN = ExtractThird); data = data[data$temp2 %in% c('A','T','G','C'),]
data$Subst = paste(data$temp1,data$temp2,sep='')
table(data$Subst)

# FILTER FOR THE SAME BACKGROUND (Pos1Anc == Pos1Der; Pos5Anc == Pos5Der; ):
# very first (first) and very last (fifth) should be the same (important for codons - we will garantie, that in the codon there is only one substitution)
nrow(data) # 292532
ExtractFirst<-function(x) {unlist(strsplit(x,''))[1]}
data$Pos1Anc = apply(as.matrix(data$ancestor),1,FUN = ExtractFirst);   data = data[data$Pos1Anc %in% c('a','t','g','c'),]
data$Pos1Der = apply(as.matrix(data$descendant),1,FUN = ExtractFirst); data = data[data$Pos1Der %in% c('a','t','g','c'),]
data=data[data$Pos1Anc == data$Pos1Der,]; nrow(data)

ExtractFifth<-function(x) {unlist(strsplit(x,''))[5]}
data$Pos5Anc = apply(as.matrix(data$ancestor),1,FUN = ExtractFifth);   data = data[data$Pos5Anc %in% c('a','t','g','c'),]
data$Pos5Der = apply(as.matrix(data$descendant),1,FUN = ExtractFifth); data = data[data$Pos5Der %in% c('a','t','g','c'),]
data=data[data$Pos5Anc == data$Pos5Der,]; nrow(data)

# Context
ExtractSecond<-function(x) {unlist(strsplit(x,''))[2]}
data$Pos2Anc = apply(as.matrix(data$ancestor),1,FUN = ExtractSecond); data = data[data$Pos2Anc %in% c('a','t','g','c'),]
data$Pos2Der = apply(as.matrix(data$descendant),1,FUN = ExtractSecond); data = data[data$Pos2Der %in% c('a','t','g','c'),]
data=data[data$Pos2Anc == data$Pos2Der,]

ExtractFourth<-function(x) {unlist(strsplit(x,''))[4]}
data$Pos4Anc = apply(as.matrix(data$ancestor),1,FUN = ExtractFourth); data = data[data$Pos4Anc %in% c('a','t','g','c'),]
data$Pos4Der = apply(as.matrix(data$descendant),1,FUN = ExtractFourth); data = data[data$Pos4Der %in% c('a','t','g','c'),]
data=data[data$Pos4Anc == data$Pos4Der,]

data$Context = paste(toupper(data$Pos2Anc),data$temp1,toupper(data$Pos4Anc),sep='')

#### filter out synonymous
data <- subset(data, synonymous == "non-synonymous" & derived_aa != "Ambiguous" & derived_aa != "Asn/Asp" & derived_aa != "Gln/Glu" & derived_aa != "Leu/Ile" & gene_info != "mRNA_ND6")  #убираю лишнее
table(data$derived_aa)

## DERIVE SUBSTITUTION MATRIX

data$FromTo = paste(data$ancestral_aa,data$derived_aa,sep = '>')

FromTo = data.frame(table(data$FromTo))
names(FromTo) = c('FromAncestralToDerived', 'NumberOfEvents')
nrow(FromTo) # 236, but totally there are 21*21 possibilities
AllAa = data.frame(unique(data$ancestral_aa)); length(AllAa) # including stop


aa_count <- table(as.character(interaction(data$ancestral_aa, data$derived_aa))) 
aa_count

m <- matrix(nrow = 21, ncol = 21)   #horizontal - ancestral_aa, vertical - derived_aa
rownames(m) <- c('Gly', 'Ala', 'Val', 'Ile', 'Leu', 'Pro', 'Ser', 'Thr', 'Cys', 'Met', 
                 'Asp', 'Asn', 'Glu', 'Gln', 'Lys', 'Arg', 'His', 'Phe', 'Tyr', 'Trp', 'Stop')
colnames(m) <- c('Gly', 'Ala', 'Val', 'Ile', 'Leu', 'Pro', 'Ser', 'Thr', 'Cys', 'Met', 
                 'Asp', 'Asn', 'Glu', 'Gln', 'Lys', 'Arg', 'His', 'Phe', 'Tyr', 'Trp', 'Stop')

m['Gly', 'Ala'] <- aa_count['Gly.Ala']  
m['Gly', 'Val'] <- aa_count['Gly.Val']
m['Gly', 'Ile'] <- aa_count['Gly.Ile']
m['Gly', 'Leu'] <- aa_count['Gly.Leu']
m['Gly', 'Pro'] <- aa_count['Gly.Pro']
m['Gly', 'Ser'] <- aa_count['Gly.Ser']
m['Gly', 'Thr'] <- aa_count['Gly.Thr']
m['Gly', 'Cys'] <- aa_count['Gly.Cys']
m['Gly', 'Met'] <- aa_count['Gly.Met']
m['Gly', 'Asp'] <- aa_count['Gly.Asp']
m['Gly', 'Asn'] <- aa_count['Gly.Asn']
m['Gly', 'Glu'] <- aa_count['Gly.Glu']
m['Gly', 'Gln'] <- aa_count['Gly.Gln']
m['Gly', 'Lys'] <- aa_count['Gly.Lys']
m['Gly', 'Arg'] <- aa_count['Gly.Arg']
m['Gly', 'His'] <- aa_count['Gly.His']
m['Gly', 'Phe'] <- aa_count['Gly.Phe']
m['Gly', 'Tyr'] <- aa_count['Gly.Tyr']
m['Gly', 'Trp'] <- aa_count['Gly.Trp']
m['Gly', 'Stop'] <- aa_count['Gly.Stop']

m['Ala', 'Gly'] <- aa_count['Ala.Gly']
m['Ala', 'Val'] <- aa_count['Ala.Val']
m['Ala', 'Ile'] <- aa_count['Ala.Ile']
m['Ala', 'Leu'] <- aa_count['Ala.Leu']
m['Ala', 'Pro'] <- aa_count['Ala.Pro']
m['Ala', 'Ser'] <- aa_count['Ala.Ser']
m['Ala', 'Thr'] <- aa_count['Ala.Thr']
m['Ala', 'Cys'] <- aa_count['Ala.Cys']
m['Ala', 'Met'] <- aa_count['Ala.Met']
m['Ala', 'Asp'] <- aa_count['Ala.Asp']
m['Ala', 'Asn'] <- aa_count['Ala.Asn']
m['Ala', 'Glu'] <- aa_count['Ala.Glu']
m['Ala', 'Gln'] <- aa_count['Ala.Gln']
m['Ala', 'Lys'] <- aa_count['Ala.Lys']
m['Ala', 'Arg'] <- aa_count['Ala.Arg']
m['Ala', 'His'] <- aa_count['Ala.His']
m['Ala', 'Phe'] <- aa_count['Ala.Phe']
m['Ala', 'Tyr'] <- aa_count['Ala.Tyr']
m['Ala', 'Trp'] <- aa_count['Ala.Trp']
m['Ala', 'Stop'] <- aa_count['Ala.Stop']

m['Val', 'Gly'] <- aa_count['Val.Gly']
m['Val', 'Ala'] <- aa_count['Val.Ala']
m['Val', 'Ile'] <- aa_count['Val.Ile']
m['Val', 'Leu'] <- aa_count['Val.Leu']
m['Val', 'Pro'] <- aa_count['Val.Pro']
m['Val', 'Ser'] <- aa_count['Val.Ser']
m['Val', 'Thr'] <- aa_count['Val.Thr']
m['Val', 'Cys'] <- aa_count['Val.Cys']
m['Val', 'Met'] <- aa_count['Val.Met']
m['Val', 'Asp'] <- aa_count['Val.Asp']
m['Val', 'Asn'] <- aa_count['Val.Asn']
m['Val', 'Glu'] <- aa_count['Val.Glu']
m['Val', 'Gln'] <- aa_count['Val.Gln']
m['Val', 'Lys'] <- aa_count['Val.Lys']
m['Val', 'Arg'] <- aa_count['Val.Arg']
m['Val', 'His'] <- aa_count['Val.His']
m['Val', 'Phe'] <- aa_count['Val.Phe']
m['Val', 'Tyr'] <- aa_count['Val.Tyr']
m['Val', 'Trp'] <- aa_count['Val.Trp']
m['Val', 'Stop'] <- aa_count['Val.Stop']

m['Ile', 'Gly'] <- aa_count['Ile.Gly']
m['Ile', 'Ala'] <- aa_count['Ile.Ala']
m['Ile', 'Val'] <- aa_count['Ile.Val']
m['Ile', 'Leu'] <- aa_count['Ile.Leu']
m['Ile', 'Pro'] <- aa_count['Ile.Pro']
m['Ile', 'Ser'] <- aa_count['Ile.Ser']
m['Ile', 'Thr'] <- aa_count['Ile.Thr']
m['Ile', 'Cys'] <- aa_count['Ile.Cys']
m['Ile', 'Met'] <- aa_count['Ile.Met']
m['Ile', 'Asp'] <- aa_count['Ile.Asp']
m['Ile', 'Asn'] <- aa_count['Ile.Asn']
m['Ile', 'Glu'] <- aa_count['Ile.Glu']
m['Ile', 'Gln'] <- aa_count['Ile.Gln']
m['Ile', 'Lys'] <- aa_count['Ile.Lys']
m['Ile', 'Arg'] <- aa_count['Ile.Arg']
m['Ile', 'His'] <- aa_count['Ile.His']
m['Ile', 'Phe'] <- aa_count['Ile.Phe']
m['Ile', 'Tyr'] <- aa_count['Ile.Tyr']
m['Ile', 'Trp'] <- aa_count['Ile.Trp']
m['Ile', 'Stop'] <- aa_count['Ile.Stop']

m['Leu', 'Gly'] <- aa_count['Leu.Gly']
m['Leu', 'Ala'] <- aa_count['Leu.Ala']
m['Leu', 'Val'] <- aa_count['Leu.Val']
m['Leu', 'Ile'] <- aa_count['Leu.Ile']
m['Leu', 'Pro'] <- aa_count['Leu.Pro']
m['Leu', 'Ser'] <- aa_count['Leu.Ser']
m['Leu', 'Thr'] <- aa_count['Leu.Thr']
m['Leu', 'Cys'] <- aa_count['Leu.Cys']
m['Leu', 'Met'] <- aa_count['Leu.Met']
m['Leu', 'Asp'] <- aa_count['Leu.Asp']
m['Leu', 'Asn'] <- aa_count['Leu.Asn']
m['Leu', 'Glu'] <- aa_count['Leu.Glu']
m['Leu', 'Gln'] <- aa_count['Leu.Gln']
m['Leu', 'Lys'] <- aa_count['Leu.Lys']
m['Leu', 'Arg'] <- aa_count['Leu.Arg']
m['Leu', 'His'] <- aa_count['Leu.His']
m['Leu', 'Phe'] <- aa_count['Leu.Phe']
m['Leu', 'Tyr'] <- aa_count['Leu.Tyr']
m['Leu', 'Trp'] <- aa_count['Leu.Trp']
m['Leu', 'Stop'] <- aa_count['Leu.Stop']

m['Pro', 'Gly'] <- aa_count['Pro.Gly']
m['Pro', 'Ala'] <- aa_count['Pro.Ala']
m['Pro', 'Val'] <- aa_count['Pro.Val']
m['Pro', 'Ile'] <- aa_count['Pro.Ile']
m['Pro', 'Leu'] <- aa_count['Pro.Leu']
m['Pro', 'Ser'] <- aa_count['Pro.Ser']
m['Pro', 'Thr'] <- aa_count['Pro.Thr']
m['Pro', 'Cys'] <- aa_count['Pro.Cys']
m['Pro', 'Met'] <- aa_count['Pro.Met']
m['Pro', 'Asp'] <- aa_count['Pro.Asp']
m['Pro', 'Asn'] <- aa_count['Pro.Asn']
m['Pro', 'Glu'] <- aa_count['Pro.Glu']
m['Pro', 'Gln'] <- aa_count['Pro.Gln']
m['Pro', 'Lys'] <- aa_count['Pro.Lys']
m['Pro', 'Arg'] <- aa_count['Pro.Arg']
m['Pro', 'His'] <- aa_count['Pro.His']
m['Pro', 'Phe'] <- aa_count['Pro.Phe']
m['Pro', 'Tyr'] <- aa_count['Pro.Tyr']
m['Pro', 'Trp'] <- aa_count['Pro.Trp']
m['Pro', 'Stop'] <- aa_count['Pro.Stop']

m['Ser', 'Gly'] <- aa_count['Ser.Gly']
m['Ser', 'Ala'] <- aa_count['Ser.Ala']
m['Ser', 'Val'] <- aa_count['Ser.Val']
m['Ser', 'Ile'] <- aa_count['Ser.Ile']
m['Ser', 'Leu'] <- aa_count['Ser.Leu']
m['Ser', 'Pro'] <- aa_count['Ser.Pro']
m['Ser', 'Thr'] <- aa_count['Ser.Thr']
m['Ser', 'Cys'] <- aa_count['Ser.Cys']
m['Ser', 'Met'] <- aa_count['Ser.Met']
m['Ser', 'Asp'] <- aa_count['Ser.Asp']
m['Ser', 'Asn'] <- aa_count['Ser.Asn']
m['Ser', 'Glu'] <- aa_count['Ser.Glu']
m['Ser', 'Gln'] <- aa_count['Ser.Gln']
m['Ser', 'Lys'] <- aa_count['Ser.Lys']
m['Ser', 'Arg'] <- aa_count['Ser.Arg']
m['Ser', 'His'] <- aa_count['Ser.His']
m['Ser', 'Phe'] <- aa_count['Ser.Phe']
m['Ser', 'Tyr'] <- aa_count['Ser.Tyr']
m['Ser', 'Trp'] <- aa_count['Ser.Trp']
m['Ser', 'Stop'] <- aa_count['Ser.Stop']

m['Thr', 'Gly'] <- aa_count['Thr.Gly']
m['Thr', 'Ala'] <- aa_count['Thr.Ala']
m['Thr', 'Val'] <- aa_count['Thr.Val']
m['Thr', 'Ile'] <- aa_count['Thr.Ile']
m['Thr', 'Leu'] <- aa_count['Thr.Leu']
m['Thr', 'Pro'] <- aa_count['Thr.Pro']
m['Thr', 'Ser'] <- aa_count['Thr.Ser']
m['Thr', 'Cys'] <- aa_count['Thr.Cys']
m['Thr', 'Met'] <- aa_count['Thr.Met']
m['Thr', 'Asp'] <- aa_count['Thr.Asp']
m['Thr', 'Asn'] <- aa_count['Thr.Asn']
m['Thr', 'Glu'] <- aa_count['Thr.Glu']
m['Thr', 'Gln'] <- aa_count['Thr.Gln']
m['Thr', 'Lys'] <- aa_count['Thr.Lys']
m['Thr', 'Arg'] <- aa_count['Thr.Arg']
m['Thr', 'His'] <- aa_count['Thr.His']
m['Thr', 'Phe'] <- aa_count['Thr.Phe']
m['Thr', 'Tyr'] <- aa_count['Thr.Tyr']
m['Thr', 'Trp'] <- aa_count['Thr.Trp']
m['Thr', 'Stop'] <- aa_count['Thr.Stop']

m['Cys', 'Gly'] <- aa_count['Cys.Gly']
m['Cys', 'Ala'] <- aa_count['Cys.Ala']
m['Cys', 'Val'] <- aa_count['Cys.Val']
m['Cys', 'Ile'] <- aa_count['Cys.Ile']
m['Cys', 'Leu'] <- aa_count['Cys.Leu']
m['Cys', 'Pro'] <- aa_count['Cys.Pro']
m['Cys', 'Ser'] <- aa_count['Cys.Ser']
m['Cys', 'Thr'] <- aa_count['Cys.Thr']
m['Cys', 'Met'] <- aa_count['Cys.Met']
m['Cys', 'Asp'] <- aa_count['Cys.Asp']
m['Cys', 'Asn'] <- aa_count['Cys.Asn']
m['Cys', 'Glu'] <- aa_count['Cys.Glu']
m['Cys', 'Gln'] <- aa_count['Cys.Gln']
m['Cys', 'Lys'] <- aa_count['Cys.Lys']
m['Cys', 'Arg'] <- aa_count['Cys.Arg']
m['Cys', 'His'] <- aa_count['Cys.His']
m['Cys', 'Phe'] <- aa_count['Cys.Phe']
m['Cys', 'Tyr'] <- aa_count['Cys.Tyr']
m['Cys', 'Trp'] <- aa_count['Cys.Trp']
m['Cys', 'Stop'] <- aa_count['Cys.Stop']

m['Met', 'Gly'] <- aa_count['Met.Gly']
m['Met', 'Ala'] <- aa_count['Met.Ala']
m['Met', 'Val'] <- aa_count['Met.Val']
m['Met', 'Ile'] <- aa_count['Met.Ile']
m['Met', 'Leu'] <- aa_count['Met.Leu']
m['Met', 'Pro'] <- aa_count['Met.Pro']
m['Met', 'Ser'] <- aa_count['Met.Ser']
m['Met', 'Thr'] <- aa_count['Met.Thr']
m['Met', 'Cys'] <- aa_count['Met.Cys']
m['Met', 'Asp'] <- aa_count['Met.Asp']
m['Met', 'Asn'] <- aa_count['Met.Asn']
m['Met', 'Glu'] <- aa_count['Met.Glu']
m['Met', 'Gln'] <- aa_count['Met.Gln']
m['Met', 'Lys'] <- aa_count['Met.Lys']
m['Met', 'Arg'] <- aa_count['Met.Arg']
m['Met', 'His'] <- aa_count['Met.His']
m['Met', 'Phe'] <- aa_count['Met.Phe']
m['Met', 'Tyr'] <- aa_count['Met.Tyr']
m['Met', 'Trp'] <- aa_count['Met.Trp']
m['Gly', 'Stop'] <- aa_count['Gly.Stop']

m['Asp', 'Gly'] <- aa_count['Asp.Gly']
m['Asp', 'Ala'] <- aa_count['Asp.Ala']
m['Asp', 'Val'] <- aa_count['Asp.Val']
m['Asp', 'Ile'] <- aa_count['Asp.Ile']
m['Asp', 'Leu'] <- aa_count['Asp.Leu']
m['Asp', 'Pro'] <- aa_count['Asp.Pro']
m['Asp', 'Ser'] <- aa_count['Asp.Ser']
m['Asp', 'Thr'] <- aa_count['Asp.Thr']
m['Asp', 'Cys'] <- aa_count['Asp.Cys']
m['Asp', 'Met'] <- aa_count['Asp.Met']
m['Asp', 'Asn'] <- aa_count['Asp.Asn']
m['Asp', 'Glu'] <- aa_count['Asp.Glu']
m['Asp', 'Gln'] <- aa_count['Asp.Gln']
m['Asp', 'Lys'] <- aa_count['Asp.Lys']
m['Asp', 'Arg'] <- aa_count['Asp.Arg']
m['Asp', 'His'] <- aa_count['Asp.His']
m['Asp', 'Phe'] <- aa_count['Asp.Phe']
m['Asp', 'Tyr'] <- aa_count['Asp.Tyr']
m['Asp', 'Trp'] <- aa_count['Asp.Trp']
m['Asp', 'Stop'] <- aa_count['Asp.Stop']

m['Asn', 'Gly'] <- aa_count['Asn.Gly']
m['Asn', 'Ala'] <- aa_count['Asn.Ala']
m['Asn', 'Val'] <- aa_count['Asn.Val']
m['Asn', 'Ile'] <- aa_count['Asn.Ile']
m['Asn', 'Leu'] <- aa_count['Asn.Leu']
m['Asn', 'Pro'] <- aa_count['Asn.Pro']
m['Asn', 'Ser'] <- aa_count['Asn.Ser']
m['Asn', 'Thr'] <- aa_count['Asn.Thr']
m['Asn', 'Cys'] <- aa_count['Asn.Cys']
m['Asn', 'Met'] <- aa_count['Asn.Met']
m['Asn', 'Asp'] <- aa_count['Asn.Asp']
m['Asn', 'Glu'] <- aa_count['Asn.Glu']
m['Asn', 'Gln'] <- aa_count['Asn.Gln']
m['Asn', 'Lys'] <- aa_count['Asn.Lys']
m['Asn', 'Arg'] <- aa_count['Asn.Arg']
m['Asn', 'His'] <- aa_count['Asn.His']
m['Asn', 'Phe'] <- aa_count['Asn.Phe']
m['Asn', 'Tyr'] <- aa_count['Asn.Tyr']
m['Asn', 'Trp'] <- aa_count['Asn.Trp']
m['Asn', 'Stop'] <- aa_count['Asn.Stop']

m['Glu', 'Gly'] <- aa_count['Glu.Gly']
m['Glu', 'Ala'] <- aa_count['Glu.Ala']
m['Glu', 'Val'] <- aa_count['Glu.Val']
m['Glu', 'Ile'] <- aa_count['Glu.Ile']
m['Glu', 'Leu'] <- aa_count['Glu.Leu']
m['Glu', 'Pro'] <- aa_count['Glu.Pro']
m['Glu', 'Ser'] <- aa_count['Glu.Ser']
m['Glu', 'Thr'] <- aa_count['Glu.Thr']
m['Glu', 'Cys'] <- aa_count['Glu.Cys']
m['Glu', 'Met'] <- aa_count['Glu.Met']
m['Glu', 'Asp'] <- aa_count['Glu.Asp']
m['Glu', 'Asn'] <- aa_count['Glu.Asn']
m['Glu', 'Gln'] <- aa_count['Glu.Gln']
m['Glu', 'Lys'] <- aa_count['Glu.Lys']
m['Glu', 'Arg'] <- aa_count['Glu.Arg']
m['Glu', 'His'] <- aa_count['Glu.His']
m['Glu', 'Phe'] <- aa_count['Glu.Phe']
m['Glu', 'Tyr'] <- aa_count['Glu.Tyr']
m['Glu', 'Trp'] <- aa_count['Glu.Trp']
m['Glu', 'Stop'] <- aa_count['Glu.Stop']

m['Gln', 'Gly'] <- aa_count['Gln.Gly']
m['Gln', 'Ala'] <- aa_count['Gln.Ala']
m['Gln', 'Val'] <- aa_count['Gln.Val']
m['Gln', 'Ile'] <- aa_count['Gln.Ile']
m['Gln', 'Leu'] <- aa_count['Gln.Leu']
m['Gln', 'Pro'] <- aa_count['Gln.Pro']
m['Gln', 'Ser'] <- aa_count['Gln.Ser']
m['Gln', 'Thr'] <- aa_count['Gln.Thr']
m['Gln', 'Cys'] <- aa_count['Gln.Cys']
m['Gln', 'Met'] <- aa_count['Gln.Met']
m['Gln', 'Asp'] <- aa_count['Gln.Asp']
m['Gln', 'Asn'] <- aa_count['Gln.Asn']
m['Gln', 'Glu'] <- aa_count['Gln.Glu']
m['Gln', 'Lys'] <- aa_count['Gln.Lys']
m['Gln', 'Arg'] <- aa_count['Gln.Arg']
m['Gln', 'His'] <- aa_count['Gln.His']
m['Gln', 'Phe'] <- aa_count['Gln.Phe']
m['Gln', 'Tyr'] <- aa_count['Gln.Tyr']
m['Gln', 'Trp'] <- aa_count['Gln.Trp']
m['Gln', 'Stop'] <- aa_count['Gln.Stop']

m['Lys', 'Gly'] <- aa_count['Lys.Gly']
m['Lys', 'Ala'] <- aa_count['Lys.Ala']
m['Lys', 'Val'] <- aa_count['Lys.Val']
m['Lys', 'Ile'] <- aa_count['Lys.Ile']
m['Lys', 'Leu'] <- aa_count['Lys.Leu']
m['Lys', 'Pro'] <- aa_count['Lys.Pro']
m['Lys', 'Ser'] <- aa_count['Lys.Ser']
m['Lys', 'Thr'] <- aa_count['Lys.Thr']
m['Lys', 'Cys'] <- aa_count['Lys.Cys']
m['Lys', 'Met'] <- aa_count['Lys.Met']
m['Lys', 'Asp'] <- aa_count['Lys.Asp']
m['Lys', 'Asn'] <- aa_count['Lys.Asn']
m['Lys', 'Glu'] <- aa_count['Lys.Glu']
m['Lys', 'Gln'] <- aa_count['Lys.Gln']
m['Lys', 'Arg'] <- aa_count['Lys.Arg']
m['Lys', 'His'] <- aa_count['Lys.His']
m['Lys', 'Phe'] <- aa_count['Lys.Phe']
m['Lys', 'Tyr'] <- aa_count['Lys.Tyr']
m['Lys', 'Trp'] <- aa_count['Lys.Trp']
m['Lys', 'Stop'] <- aa_count['Lys.Stop']

m['Arg', 'Gly'] <- aa_count['Arg.Gly']
m['Arg', 'Ala'] <- aa_count['Arg.Ala']
m['Arg', 'Val'] <- aa_count['Arg.Val']
m['Arg', 'Ile'] <- aa_count['Arg.Ile']
m['Arg', 'Leu'] <- aa_count['Arg.Leu']
m['Arg', 'Pro'] <- aa_count['Arg.Pro']
m['Arg', 'Ser'] <- aa_count['Arg.Ser']
m['Arg', 'Thr'] <- aa_count['Arg.Thr']
m['Arg', 'Cys'] <- aa_count['Arg.Cys']
m['Arg', 'Met'] <- aa_count['Arg.Met']
m['Arg', 'Asp'] <- aa_count['Arg.Asp']
m['Arg', 'Asn'] <- aa_count['Arg.Asn']
m['Arg', 'Glu'] <- aa_count['Arg.Glu']
m['Arg', 'Gln'] <- aa_count['Arg.Gln']
m['Arg', 'Lys'] <- aa_count['Arg.Lys']
m['Arg', 'His'] <- aa_count['Arg.His']
m['Arg', 'Phe'] <- aa_count['Arg.Phe']
m['Arg', 'Tyr'] <- aa_count['Arg.Tyr']
m['Arg', 'Trp'] <- aa_count['Arg.Trp']
m['Arg', 'Stop'] <- aa_count['Arg.Stop']

m['His', 'Gly'] <- aa_count['His.Gly']
m['His', 'Ala'] <- aa_count['His.Ala']
m['His', 'Val'] <- aa_count['His.Val']
m['His', 'Ile'] <- aa_count['His.Ile']
m['His', 'Leu'] <- aa_count['His.Leu']
m['His', 'Pro'] <- aa_count['His.Pro']
m['His', 'Ser'] <- aa_count['His.Ser']
m['His', 'Thr'] <- aa_count['His.Thr']
m['His', 'Cys'] <- aa_count['His.Cys']
m['His', 'Met'] <- aa_count['His.Met']
m['His', 'Asp'] <- aa_count['His.Asp']
m['His', 'Asn'] <- aa_count['His.Asn']
m['His', 'Glu'] <- aa_count['His.Glu']
m['His', 'Gln'] <- aa_count['His.Gln']
m['His', 'Lys'] <- aa_count['His.Lys']
m['His', 'Arg'] <- aa_count['His.Arg']
m['His', 'Phe'] <- aa_count['His.Phe']
m['His', 'Tyr'] <- aa_count['His.Tyr']
m['His', 'Trp'] <- aa_count['His.Trp']
m['His', 'Stop'] <- aa_count['His.Stop']

m['Phe', 'Gly'] <- aa_count['Phe.Gly']
m['Phe', 'Ala'] <- aa_count['Phe.Ala']
m['Phe', 'Val'] <- aa_count['Phe.Val']
m['Phe', 'Ile'] <- aa_count['Phe.Ile']
m['Phe', 'Leu'] <- aa_count['Phe.Leu']
m['Phe', 'Pro'] <- aa_count['Phe.Pro']
m['Phe', 'Ser'] <- aa_count['Phe.Ser']
m['Phe', 'Thr'] <- aa_count['Phe.Thr']
m['Phe', 'Cys'] <- aa_count['Phe.Cys']
m['Phe', 'Met'] <- aa_count['Phe.Met']
m['Phe', 'Asp'] <- aa_count['Phe.Asp']
m['Phe', 'Asn'] <- aa_count['Phe.Asn']
m['Phe', 'Glu'] <- aa_count['Phe.Glu']
m['Phe', 'Gln'] <- aa_count['Phe.Gln']
m['Phe', 'Lys'] <- aa_count['Phe.Lys']
m['Phe', 'Arg'] <- aa_count['Phe.Arg']
m['Phe', 'His'] <- aa_count['Phe.His']
m['Phe', 'Tyr'] <- aa_count['Phe.Tyr']
m['Phe', 'Trp'] <- aa_count['Phe.Trp']
m['Phe', 'Stop'] <- aa_count['Phe.Stop']

m['Tyr', 'Gly'] <- aa_count['Tyr.Gly']
m['Tyr', 'Ala'] <- aa_count['Tyr.Ala']
m['Tyr', 'Val'] <- aa_count['Tyr.Val']
m['Tyr', 'Ile'] <- aa_count['Tyr.Ile']
m['Tyr', 'Leu'] <- aa_count['Tyr.Leu']
m['Tyr', 'Pro'] <- aa_count['Tyr.Pro']
m['Tyr', 'Ser'] <- aa_count['Tyr.Ser']
m['Tyr', 'Thr'] <- aa_count['Tyr.Thr']
m['Tyr', 'Cys'] <- aa_count['Tyr.Cys']
m['Tyr', 'Met'] <- aa_count['Tyr.Met']
m['Tyr', 'Asp'] <- aa_count['Tyr.Asp']
m['Tyr', 'Asn'] <- aa_count['Tyr.Asn']
m['Tyr', 'Glu'] <- aa_count['Tyr.Glu']
m['Tyr', 'Gln'] <- aa_count['Tyr.Gln']
m['Tyr', 'Lys'] <- aa_count['Tyr.Lys']
m['Tyr', 'Arg'] <- aa_count['Tyr.Arg']
m['Tyr', 'His'] <- aa_count['Tyr.His']
m['Tyr', 'Phe'] <- aa_count['Tyr.Phe']
m['Tyr', 'Trp'] <- aa_count['Tyr.Trp']
m['Tyr', 'Stop'] <- aa_count['Tyr.Stop']

m['Trp', 'Gly'] <- aa_count['Trp.Gly']
m['Trp', 'Ala'] <- aa_count['Trp.Ala']
m['Trp', 'Val'] <- aa_count['Trp.Val']
m['Trp', 'Ile'] <- aa_count['Trp.Ile']
m['Trp', 'Leu'] <- aa_count['Trp.Leu']
m['Trp', 'Pro'] <- aa_count['Trp.Pro']
m['Trp', 'Ser'] <- aa_count['Trp.Ser']
m['Trp', 'Thr'] <- aa_count['Trp.Thr']
m['Trp', 'Cys'] <- aa_count['Trp.Cys']
m['Trp', 'Met'] <- aa_count['Trp.Met']
m['Trp', 'Asp'] <- aa_count['Trp.Asp']
m['Trp', 'Asn'] <- aa_count['Trp.Asn']
m['Trp', 'Glu'] <- aa_count['Trp.Glu']
m['Trp', 'Gln'] <- aa_count['Trp.Gln']
m['Trp', 'Lys'] <- aa_count['Trp.Lys']
m['Trp', 'Arg'] <- aa_count['Trp.Arg']
m['Trp', 'His'] <- aa_count['Trp.His']
m['Trp', 'Phe'] <- aa_count['Trp.Phe']
m['Trp', 'Tyr'] <- aa_count['Trp.Tyr']
m['Trp', 'Stop'] <- aa_count['Trp.Stop'] 

m['Stop', 'Gly'] <- aa_count['Stop.Gly']
m['Stop', 'Ala'] <- aa_count['Stop.Ala']
m['Stop', 'Val'] <- aa_count['Stop.Val']
m['Stop', 'Ile'] <- aa_count['Stop.Ile']
m['Stop', 'Leu'] <- aa_count['Stop.Leu']
m['Stop', 'Pro'] <- aa_count['Stop.Pro']
m['Stop', 'Ser'] <- aa_count['Stop.Ser']
m['Stop', 'Thr'] <- aa_count['Stop.Thr']
m['Stop', 'Cys'] <- aa_count['Stop.Cys']
m['Stop', 'Asn'] <- aa_count['Stop.Asn']
m['Stop', 'Asp'] <- aa_count['Stop.Asp']
m['Stop', 'Asn'] <- aa_count['Stop.Asn']
m['Stop', 'Glu'] <- aa_count['Stop.Glu']
m['Stop', 'Gln'] <- aa_count['Stop.Gln']
m['Stop', 'Lys'] <- aa_count['Stop.Lys']
m['Stop', 'Arg'] <- aa_count['Stop.Arg']
m['Stop', 'His'] <- aa_count['Stop.His']
m['Stop', 'Phe'] <- aa_count['Stop.Phe']
m['Stop', 'Tyr'] <- aa_count['Stop.Tyr']
m['Stop', 'Trp'] <- aa_count['Stop.Trp']

m[is.na(m)] <- 0  #NA to 0
write.table(m,"../../Body/3Results/Alima01.Gainer&LoosersMatrix.txt", sep = '\t')

pdf("../../Body/4Figures/Alima01.Gainer&Loosers.pdf")
heatmap(m, Colv = "Rowv", xlab = 'ancestral', ylab = 'derived')
dev.off()

#writing table ratio(anc/der): 
From <- colSums(m)
To <- rowSums(m) #horizontal
RatioFromTo <- From/To # the > , the more AA loser 

GorL <- matrix(c(From, To, RatioFromTo), nrow = 21, 
               dimnames = list(c('Gly', 'Ala', 'Val', 'Ile', 'Leu', 'Pro', 'Ser', 'Thr', 'Cys', 
                                 'Met', 'Asp', 'Asn', 'Glu', 'Gln', 'Lys', 'Arg', 'His', 'Phe', 
                                 'Tyr', 'Trp', 'Stop'), c('From', 'To', 'RatioFromTo')))
GorL = data.frame(GorL)
GorL = GorL[order(GorL$RatioFromTo),]

write.table(GorL,"../../Body/3Results/Alima01.Gainer&Loosers.txt", sep = '\t')


###### SEEKING CORR WITH KONDRASHOV: 
Kondrashov <- matrix(c(-0.0063, -0.0239, +0.0098, +0.0089, -0.0017, -0.0139, +0.0167, +0.0091, +0.0067, 
                       +0.0088, -0.0039, +0.0073, -0.0137, +0.0020, -0.0065, +0.0038, +0.0073, +0.0042, 
                       -0.0005, +0.0002, NA), nrow = 21, 
                     dimnames = list(c('Gly', 'Ala', 'Val', 'Ile', 'Leu', 'Pro', 'Ser', 'Thr', 
                                       'Cys', 'Met', 'Asp', 'Asn', 'Glu', 'Gln', 'Lys', 'Arg', 
                                       'His', 'Phe', 'Tyr', 'Trp', 'Stop'), 'rate of g/l'))
cor.test(RatioFromTo, Kondrashov, method = "spearman") # S = 974.87, p-value = 0.2551, rho = 0.2670177 

###### SEEKING CORR WITH RANG OF KONDRASHOV (universal trend): 
Kondrashov_rang <- matrix(c(17, 19, 9, 8, 13, 20, 4, 7, 1, 2, 15, 6, 18, 11, 16, 10, 3, 5, 14, 12, NA), nrow = 21, 
                          dimnames = list(c('Gly', 'Ala', 'Val', 'Ile', 'Leu', 'Pro', 'Ser', 'Thr', 
                                            'Cys', 'Met', 'Asp', 'Asn', 'Glu', 'Gln', 'Lys', 'Arg', 
                                            'His', 'Phe', 'Tyr', 'Trp', 'Stop'), 'rate of g/l'))
cor.test(RatioFromTo, Kondrashov_rang, method = "spearman") # S = 1666, p-value = 0.2813, rho = -0.2526316 

