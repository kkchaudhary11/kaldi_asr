#!/bin/bash

#Replace <lang_fst2> with your lang directory name which is created using myfst.sh 
#lang=lang_fst2
#decode_cmd=run.pl

sen=900
gauss=9000

x=test
mfccdir=mfcc
#utils/mkgraph.sh --mono data/$lang exp/mono exp/mono/graph_new || exit 1;
#steps/decode.sh --nj 4 --cmd run.pl \
#        exp/mono/graph_new data/test exp/mono/decode || exit 1;

#########    tr1 #############

#utils/mkgraph.sh data/$lang exp/tri1_${sen}_${gauss} exp/tri1_${sen}_${gauss}/graph_fst || exit 1;
#steps/decode.sh --nj "$decode_nj" --cmd "$decode_cmd" \
# exp/tri1_${sen}_${gauss}/graph_fst data/test exp/tri1_${sen}_${gauss}/decode || exit 1;



#steps/make_mfcc.sh --cmd run.pl --nj 2 data/$x exp/make_mfcc/$x $mfccdir || exit 1;
#steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x $mfccdir || exit 1;





###########  tr2  alone  ########
utils/mkgraph.sh data/lang_dist exp/tri2_${sen}_${gauss} exp/tri2_${sen}_${gauss}/graph_dist || exit 1;
#steps/decode.sh --nj 4 --cmd run.pl \
#exp/tri2_${sen}_${gauss}/graph_mandi data/$x exp/tri2_${sen}_${gauss}/decode_mandi || exit 1;

