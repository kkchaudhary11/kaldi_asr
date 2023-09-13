# script to update the existing graph with new words
# 2 files are required 
# 1. new_words 
# 2. new_words_lex
# input $1 requires graph name

if [ $# -ne 3 ]
  then
    printf "requires 3 parameters : \n 1. graph_name\n 2. new_words file \n 3. new_words_lexicon_expension file \n"
    exit 1
fi

rm -rf data/lang_$1
rm -rf data/local/tmp
rm -rf data/local/lang_$1
rm -f data/local/dict/lexiconp.txt
rm -rf exp/chain/tree_sp/graph_$1

sed -i '/^$/d' new_words

while IFS= read -r line
do
  echo "<s> $line </s>" >> data/local/plain-text/text_c1
done < $2

awk -i inplace '!seen[$0]++' data/local/plain-text/text_c1

sed -i '/^$/d' data/local/plain-text/text_c1

sed -i '/^$/d' new_words_lex

while IFS= read -r line
do
  echo "$line" >> data/local/dict/lexicon.txt
done < $3

awk -i inplace '!seen[$0]++' data/local/dict/lexicon.txt

sed -i '/^$/d' data/local/dict/lexicon.txt

./create_lm.sh

./make_graph_nnet3.sh
