#!/bin/bash


. ./cmd.sh
. ./path.sh
mfccdir=`pwd`/mfcc
dir=exp/nnet_a
tree_dir=exp/chain/tree_sp

# steps/make_mfcc.sh --nj 1 --cmd "$train_cmd" data/test exp/make_mfcc/test $mfccdir || exit 1;

# steps/compute_cmvn_stats.sh data/test exp/make_mfcc/test $mfccdir

utils/mkgraph.sh data/lang_blind_exam $tree_dir $tree_dir/graph_blind_exam

# steps/online/nnet3/decode.sh --acwt 1.0 --post-decode-acwt 10.0 --nj 1 --cmd "$decode_cmd" $tree_dir/graph data/test $tree_dir/decode

#steps/online/nnet2/decode.sh --config conf/decode.config --cmd "$decode_cmd" --nj 1 exp/graph data/test_simple_pbx_kaviraju ${dir}_online/decode_simple_pbx_kaviraju
