#!/bin/sh
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

# read yaml file
eval $(parse_yaml config.yml "CONF_")

# access yaml content
eval path_targetedCustFinal=$CONF_path_targetedCustFinal 
echo $path_targetedCustFinal
eval path_withLotFinal=$CONF_path_withLotFinal 
echo $path_withLotFinal
eval path_withStoreCodeFinal=$CONF_path_withStoreCodeFinal
echo $path_withStoreCodeFinal
eval path_transactionStore=$CONF_path_transactionStore
echo $path_transactionStore

# echo path_targetedCustFinal $CONF_path_targetedCustFinal 
# echo path_withLotFinal $CONF_path_withLotFinal 
# echo path_withStoreCodeFinal $CONF_path_withStoreCodeFinal 
# echo path_transactionStore $CONF_path_transactionStore 
## declare an array variable
declare -a list_path=(path_targetedCustFinal path_withLotFinal path_withStoreCodeFinal path_transactionStore)

python3 - <<here
import os

for item in "${list_path[@]}";
do 
    os.environ[item] = item
    os.system('echo $item')
    gsutil -m rm $item; 
done
here

