#! /bin/bash
mkdir -p logs

fn_check_log_err()
{
#function to check if any oracle error occured in last sql execution
var_logname=$1
var_ora_err=""
var_ora_err=`grep "Traceback (most recent call last):" $var_logname`

if [ ! -z "$var_ora_err" ]; then
echo "PAAR Code Failed with error . Please check the logfile " $var_logname
exit
fi
}

#
for pyfile in 00_cons_four_week_prods  01_Coupon_KPI 02_FOP_KPI_0123_combined


do
    EXECUTER_MEMORY="12G"
    CORES="8"
    MEMORY_OVERHEAD="2048"
    
    if [ "$pyfile" = "00_cons_four_week_prods" ]; then 
        EXECUTER_MEMORY="12G"
    elif [ "$pyfile" = "01_Coupon_KPI" ]; then 
        EXECUTER_MEMORY="16G" CORES="10" MEMORY_OVERHEAD="20G"
    elif [ "$pyfile" = "02_FOP_KPI_0123_combined" ]; then 
        EXECUTER_MEMORY="16G" CORES="10" MEMORY_OVERHEAD="20G"
       
    fi
    spark-submit --master yarn --deploy-mode client --name="Monoprix_Ideal_Offer_Pool $pyfile" --driver-memory=16G --conf spark.dynamicAllocation.maxExecutors=80   --conf spark.dynamicAllocation.minExecutors=40 --executor-memory=$EXECUTER_MEMORY --executor-cores=$CORES --conf spark.shuffle.service.enabled=true --conf spark.driver.maxResultSize=8G --conf spark.sql.shuffle.partitions=1000  --conf spark.yarn.driver.memoryOverhead=$MEMORY_OVERHEAD --conf spark.yarn.executor.memoryOverhead=$MEMORY_OVERHEAD $pyfile.py > logs/$pyfile.log
    fn_check_log_err logs/$pyfile.log
    echo "$pyfile"
    echo "$EXECUTER_MEMORY"
    echo ""
    echo ""
done
