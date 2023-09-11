#!/bin/bash -u

. path.sh

# change kaldi path
KALDI_ROOT=/home/kkc/kaldi

mkdir data/local/tmp
utils/prepare_lang.sh data/local/dict '!SIL' data/local/lang data/lang
# Create the phone bigram LM
# change irstlm path
export IRSTLM=/home/kkc/kaldi/tools/irstlm
(
  [ -z "$IRSTLM" ] && \
    error_exit "LM building wo'nt work without setting the IRSTLM env variable"
  $IRSTLM/bin/build-lm.sh -i data/local/plain-text/text_c1 -n 2 -o data/local/tmp/lm_phone_bg.ilm.gz
  $IRSTLM/bin/compile-lm --text="yes" data/local/tmp/lm_phone_bg.ilm.gz data/local/tmp/lm_phone_bg.ilm.lm
	
) >& data/prepare_lm.log

cat data/local/tmp/lm_phone_bg.ilm.lm | grep -v unk | gzip -c > data/lang/lm_phone_bg.arpa.gz 

gunzip -c data/lang/lm_phone_bg.arpa.gz | utils/find_arpa_oovs.pl data/lang/words.txt  > data/local/tmp/oov.txt

gunzip -c data/lang/lm_phone_bg.arpa.gz | grep -v '<s> <s>' | grep -v '<s> </s>' | grep -v '</s> </s>' | grep -v 'sil' | arpa2fst - | fstprint | utils/remove_oovs.pl data/local/tmp/oov.txt | utils/eps2disambig.pl | utils/s2eps.pl | fstcompile --isymbols=data/lang/words.txt --osymbols=data/lang/words.txt --keep_isymbols=false --keep_osymbols=false | fstrmepsilon > data/lang/G.fst
$KALDI_ROOT/src/fstbin/fstisstochastic data/lang/G.fst
